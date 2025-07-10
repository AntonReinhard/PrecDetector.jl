function _precify_args!(args, var_symbols)
    for i in eachindex(args)
        if typeof(args[i]) == Symbol
            push!(var_symbols, args[i])   # save the vars, need the order for correct interpolation when printing the results
            args[i] = Expr(:call, precify, args[i])  # precify non-symbol arguments
        elseif typeof(args[i]) == Expr
            if args[i].head == :tuple
                _precify_args!(args[i].args, var_symbols)
            elseif args[i].head == :call
                args[i].args[1] = esc(args[i].args[1])
                args[i].args[2:end] = _precify_args!(args[i].args[2:end], var_symbols)
            elseif args[i].head == :$
                args[i] = esc(args[i].args[1])
            end
        end
    end
    return args
end

function _build_function_call_string(func)
    # for a given expression of the function call, build the call string
    # such that the actually sampled values can be interpolated into it
    # yielding a valid call
    str = ""
    if func isa Expr
        if func.head == :call
            str = string(func.args[1]) * "(" # function name
            first = true
            for arg in func.args[2:end]
                if !first
                    str *= ", "
                end
                str *= _build_function_call_string(arg)
                first = false
            end
            str *= ")"
        elseif func.head == :tuple # tuple expression
            str = "("
            c = 0
            for arg in func.args
                str *= _build_function_call_string(arg)
                if c <= length(func.args) || (c == 1 == length(func.args))
                    # handle commas for tuples
                    str *= ", "
                end
                c += 1
            end
            str *= ")"
        elseif func.head == :$ # escaped expression
            str = string(func.args[1])
        end
    elseif func isa Symbol
        str = string("precify(%s)")
    else
        str = string(func)
    end

    return str
end

macro bench_epsilons(
        call_expr,
        args...
    )
    if !(call_expr.head == :call)
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
    kwargs[:epsilon_limit] = 1000           # the limit for imprecision in the results
    kwargs[:samples] = 10000                # how many samples are taken
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
        error("@bench_epsilons requires the a `ranges = begin ... end` block")
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
        if !(statement isa Expr && statement.head == :(=) && length(statement.args) == 2)
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
