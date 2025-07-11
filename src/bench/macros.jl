"""
    @bench_epsilons(call_expr, args...)

Benchmark the epsilons of a given function call.

The first argument should be a function call, with variables from local context interpolated, and
arguments that should be sampled defined in a `ranges = begin ... end` block. In the `ranges` block,
every variable must be assigned a `Tuple` of a lower and an upper bound for values that should be
sampled.

```@example
using PrecisionCarriers

foo(x, y) = sqrt(x^2 - y^2)

@bench_epsilons foo(1.0, y) ranges = begin
    y = (0.5, 1.0)
end samples = 1000 epsilon_limit = 10
```

Returned is an object containing information about the benchmark results that can be displayed to
a terminal similar to BenchmarkTools' `@benchmark`.

Supported keyword arguments:
- `search_method`: How the sampling should be done. Supported are:
    - `:evenly_spaced`: Creates an evenly spaced grid across all ranges
    - `:random_search`: Randomly samples points in the given ranges.
    The default is `:evenly_spaced`.
- `samples`: The number of samples taken. Default: 10000
- `epsilon_limit`: Results with epsilons larger than this will be stored together with the arguments
  that produced the imprecise result. Default: 1000
- `keep_n_values`: Maximum number of imprecise results that will be stored.
"""
macro bench_epsilons(
        call_expr,
        args...
    )
    if !(call_expr isa Expr) || !(call_expr.head == :call)
        error("@bench_epsilons must be used with a function call as the first argument")
    end

    func = call_expr.args[1]                # original function
    func_args = call_expr.args[2:end]       # original arguments
    func_call_string = _build_function_call_string(call_expr)

    variables = Symbol[]
    _precify_args!(func_args, variables)

    kwargs = Dict{Symbol, Any}()

    # default values
    kwargs[:search_method] = :evenly_spaced # how to search the space
    kwargs[:samples] = 10000                # how many samples are taken
    kwargs[:epsilon_limit] = 1000           # the limit for imprecision in the results
    kwargs[:keep_n_values] = 5              # how many values with the worst imprecisions are kept

    kwargs[:ranges] = nothing               # the ranges expression

    for arg in args
        key = arg.args[1]
        val = arg.args[2]
        if !haskey(kwargs, key)
            error("got unknown keyword $key")
        end
        @debug "keyword argument $key = $val"
        if (val isa QuoteNode)
            kwargs[key] = val.value
        else
            kwargs[key] = val
        end
    end

    if isnothing(kwargs[:ranges])
        error("@bench_epsilons requires a `ranges = begin ... end` block")
    end

    range_block = kwargs[:ranges]
    if !(range_block isa Expr && range_block.head == :block)
        error("ranges= must be assigned a begin...end block")
    end

    ranges = Expr(:tuple)
    # i think this is evil
    resize!(ranges.args, length(variables))

    for statement in range_block.args
        if statement isa LineNumberNode
            continue  # Skip source line metadata
        end
        if !(statement isa Expr) ||
                !(statement.head == :(=)) ||
                !(length(statement.args) == 2) ||
                !(statement.args[2] isa Expr) ||
                !(statement.args[2].head == :tuple) ||
                !(length(statement.args[2].args) == 2)
            error("each line in the ranges block must be an assignment like `x = (a, b)`, got $statement")
        end
        var = statement.args[1]
        range_expr = statement.args[2]
        @debug "$var = $range_expr"
        index = findfirst(x -> x == var, variables)
        if (isnothing(index))
            @warn "found range for unused variable $var in ranges block, ignoring"
            continue
        end

        ranges.args[index] = Expr(:tuple, range_expr.args[1], range_expr.args[2])
    end

    var_expr = Expr(:tuple, variables...)

    # loop setup, independent of the search method
    call_setup = quote
        res = EpsilonBenchmarkResult($func_call_string, $(kwargs[:epsilon_limit]), $(kwargs[:keep_n_values]))
        sizehint!(res.epsilons, length(iter))
        c = 0
        prog = Progress(length(iter); dt = 1.0)
    end

    # call of the function and result handling, independent of the search method
    call_work = quote
        next!(prog)
        p = $(esc(func))($(func_args...))
        insert!(res, epsilons(p), $var_expr)
    end

    full_call = nothing
    if kwargs[:search_method] == :evenly_spaced
        full_call = quote
            let
                iter = PrecisionCarriers._grid_samples(($(ranges)), $(kwargs[:samples]))
                $call_setup
                for $var_expr in iter
                    $call_work
                end
                return res
            end
        end
    elseif kwargs[:search_method] == :random_search
        full_call = quote
            let
                iter = PrecisionCarriers._random_samples(($(ranges)), $(kwargs[:samples]))
                $call_setup
                for $var_expr in iter
                    $call_work
                end
                return res
            end
        end
    else
        error("unknown search method $(kwargs[:search_method])")
    end
    @debug full_call
    return full_call
end
