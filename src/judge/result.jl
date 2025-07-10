"""
    TopKSortedList

Helper type to store a certain number of key/value pairs, sorted in descending order by key.
"""
struct TopKSortedList{K, V}
    max_keys::Int
    entries::Vector{Tuple{K, V}}

    function TopKSortedList{K, V}(max_keys::Int) where {K, V}
        res = new{K, V}(max_keys, Tuple{K, V}[])
        sizehint!(res.entries, max_keys)
        return res
    end
end

function Base.insert!(lst::TopKSortedList{K, V}, key::K, value::V) where {K, V}
    i = 1
    while i <= length(lst.entries)
        # first index is the largest key
        if (key > lst.entries[i][1])
            insert!(lst.entries, i, (key, value))
            i = lst.max_keys
        end
        i += 1
    end

    if i <= lst.max_keys
        insert!(lst.entries, i, (key, value))
    end

    # trim back to max_keys size
    if (length(lst.entries) > lst.max_keys)
        pop!(lst.entries)
    end

    return lst
end

struct EpsilonBenchmarkResult
    epsilons::Vector{Int64}
    worst_arguments::TopKSortedList{Int64, Tuple}

    epsilon_limit::Int64
    function_name::String

    function EpsilonBenchmarkResult(function_name::AbstractString, epsilon_limit::Int64, max_values::Int64)
        return new(Int64[], TopKSortedList{Int64, Tuple}(max_values), epsilon_limit, function_name)
    end
end

function Base.insert!(eps::EpsilonBenchmarkResult, key::Int64, value::Tuple)
    if key >= eps.epsilon_limit
        insert!(eps.worst_arguments, key, value)
    end
    return push!(eps.epsilons, key)
end


function Base.show(io::IO, ::MIME"text/plain", bench_result::EpsilonBenchmarkResult)
    v = bench_result.epsilons

    if isempty(v)
        print(io, "No samples were collected.")
        return
    end

    # Summary statistics
    n = length(v)
    minval = minimum(v)
    maxval = maximum(v)
    med = round(median(v); digits = 3)
    meanval = round(mean(v); digits = 3)

    # Color helper
    function cstr(text, color)
        return Base.text_colors[color] * text * Base.text_colors[:normal]
    end

    @printf(io, "  %-9s %s\n", cstr("samples: ", :cyan), cstr(string(n), :bold))
    @printf(io, "  %-9s %s ε\n", cstr("minimum: ", :green), cstr(string(minval), :bold))
    @printf(io, "  %-9s %s ε\n", cstr("median:  ", :blue), cstr(string(med), :bold))
    @printf(io, "  %-9s %s ε\n", cstr("mean:    ", :magenta), cstr(string(meanval), :bold))
    @printf(io, "  %-9s %s ε\n", cstr("maximum: ", :red), cstr(string(maxval), :bold))

    if (isempty(bench_result.worst_arguments.entries))
        @printf(io, "\n  %s\n", cstr(string("no imprecisions > $(bench_result.epsilon_limit)ε found"), :bold))
        return nothing
    end

    @printf(io, "\n  %s:\n", cstr(string("largest imprecisions"), :bold))

    function _print_helper(io, value)
        first = true
        for v in value
            if (!first)
                print(io, " ")
            end
            if v isa Tuple
                print(io, "(")
                _print_helper(io, v)
                print(io, ")")
            elseif v isa Vector # TODO: still won't work for matrices etc.
                print(io, "[")
                _print_helper(io, v)
                print(io, "]")
            elseif v isa PrecisionCarrier
                print(io, "precify($(v.x))")
            else
                print(io, "$v")
            end
            print(io, ",")
            first = false
        end
        return
    end

    for (key, value) in bench_result.worst_arguments.entries
        print(io, "    $(bench_result.function_name)(")
        _print_helper(io, value)
        println(io, ") -> $key ε")
    end

    return nothing
end
