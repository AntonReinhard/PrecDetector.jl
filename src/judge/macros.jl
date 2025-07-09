abstract type SearchMethod end

struct RandomSearch <: SearchMethod end
struct EvenlySpaced <: SearchMethod end

macro bench_epsilons(
        call_expr,                      # the call
        args...
    )
    if !(call_expr.head == :call)
        error("@bench_epsilons must be used with a function call as the first argument")
    end

    func = call_expr.args[1]                # original function
    func_args = call_expr.args[2:end]       # original arguments

    for i in eachindex(func_args)
        if typeof(func_args[i]) == Symbol
            func_args[i] = Expr(:call, precify, func_args[i])  # escape non-symbol arguments
        end
    end

    kwargs = Dict{Symbol, Any}()

    # default values
    kwargs[:search_method] = EvenlySpaced() # how to search the space
    kwargs[:epsilon_limit] = 1000           # the limit for imprecision in the results
    kwargs[:samples] = 10000                # how many samples are taken
    kwargs[:keep_n_values] = 10             # how many values with the worst imprecisions are kept

    kwargs[:ranges] = nothing               # the ranges expression

    for arg in args
        key = arg.args[1]
        val = arg.args[2]
        kwargs[key] = val
    end

    if isnothing(kwargs[:ranges])
        error("@bench_epsilons requires the a `ranges = begin ... end` block")
    end

    range_block = kwargs[:ranges]
    if !(range_block isa Expr && range_block.head == :block)
        error("ranges= must be assigned a begin...end block")
    end

    variables = Symbol[]
    ranges = Tuple{AbstractFloat, AbstractFloat}[]

    for statement in range_block.args
        if statement isa LineNumberNode
            continue  # Skip source line metadata
        end
        if !(statement isa Expr && statement.head == :(=) && length(statement.args) == 2)
            error("each line in the ranges block must be an assignment like `x = (a, b)`, got $statement")
        end
        var = statement.args[1]
        range_expr = statement.args[2]
        @debug "$var = $range_expr"
        push!(variables, var)
        push!(ranges, (range_expr.args[1], range_expr.args[2]))
    end

    var_expr = Expr(:tuple, variables...)

    if kwargs[:search_method] == EvenlySpaced()
        full_call = quote
            let
                iter = PrecisionCarriers._grid_samples(($(ranges...),), $(kwargs[:samples]))

                argument_types = precify(eltype(iter))
                res = EpsilonBenchmarkResult{argument_types}($(string(func)), $(kwargs[:epsilon_limit]), $(kwargs[:keep_n_values]))

                sizehint!(res.epsilons, length(iter))
                c = 0
                prog = Progress(length(iter); dt = 1.0)
                for $var_expr in iter
                    next!(prog)
                    p = $(esc(func))($(func_args...))
                    epsi = epsilons(p)
                    insert!(res, epsi, ($(func_args...),))
                end
                return res
            end
        end
        @debug full_call
        return full_call
    elseif kwargs[:search_method] == RandomSearch()
        throw("unimplemented")
    end

    error("unknown search method $(kwargs[:search_method])")
end
