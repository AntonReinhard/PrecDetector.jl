"""
    _grid_samples(ranges::Tuple{Vararg{Tuple{<:Real, <:Real}}}, n::Integer)

Return an iterator generating approximately `n` evenly spaced samples over the Cartesian grid defined by `ranges`.
Each element of `ranges` must be a (lo, hi) tuple.

!!! note
    The actual number of samples generated is
    ```math
        \\lfloor n^{\\frac{1}{m}} \\rfloor ^ m
    ```
    where `m` is the dimensionality, i.e., number of ranges given.
"""
function _grid_samples(ranges::Tuple, n::Integer)
    m = length(ranges)
    # Determine how many points per dimension (uniform across all for now)
    k = floor(Int, n^(1 / m))  # approx. root to evenly distribute

    # Create linear ranges for each range
    axes = [range(lo, hi; length = k) for (lo, hi) in ranges]

    # Cartesian product of all axes
    return Iterators.product(axes...)
end

_rand_from_range(range::Tuple) = (rand() * (range[2] - range[1])) + range[1]
function _random_sample(ranges::Tuple, ::Integer)
    res = _rand_from_range.(ranges)
    return res
end

"""
    _random_samples(ranges::Tuple{Vararg{Tuple{<:Real, <:Real}}}, n::Integer)

Return an iterator generating `n` uniform randomly generated samples over the Cartesian grid defined by `ranges`.
Each element of `ranges` must be a (lo, hi) tuple.
"""
function _random_samples(ranges::Tuple, n::Integer)
    @debug "generating random samples from ranges: $ranges"
    f = Base.Fix1(_random_sample, ranges)
    return Iterators.map(f, 1:n)
end

"""
    _pseudo_random_samples(ranges::Tuple{Vararg{Tuple{<:Real, <:Real}}}, n::Integer)

Return an iterator generating `n` pseudo-randomly generated samples over the Cartesian grid defined by `ranges`.
Each element of `ranges` must be a (lo, hi) tuple.
This uses the package `Sobol.jl` to produce pseudorandom numbers within the given hypercube. The resulting
numbers are more predictable and evenly spaced than real randomness, which can be better to sample a high dimensional
space. Also, the generated samples are reproducible.
"""
function _pseudo_random_samples(ranges::Tuple, n::Integer)
    @debug "generating pseudorandom samples from ranges: $ranges"
    s = SobolSeq(getindex.(ranges, 1), getindex.(ranges, 2))
    return Iterators.take(s, n)
end

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
                c += 1
                str *= _build_function_call_string(arg)
                if c < length(func.args) || (c == 1 == length(func.args))
                    # handle commas for tuples
                    str *= ", "
                end
            end
            str *= ")"
        elseif func.head == :$ # escaped expression
            str = string(func.args[1])
        end
    elseif func isa Symbol
        str = string("precify(%s)")
    elseif func isa String
        str = "\"" * func * "\""
    elseif func isa AbstractFloat
        str = "$(typeof(func))(" * string(func) * ")"
    else
        str = string(func)
    end

    return str
end
