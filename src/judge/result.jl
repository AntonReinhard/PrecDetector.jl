"""
    TopKSortedList

Helper type to store a certain number of key/value pairs, sorted in descending order by key.
"""
struct TopKSortedList{K, V}
    max_keys::Int
    entries::Vector{Tuple{K, V}}

    function TopKSortedList{K, V}(max_keys::Int) where {K, V}
        return new{K, V}(max_keys, Tuple{K, V}[])
    end
end

function Base.insert!(lst::TopKSortedList{K, V}, key::K, value::V) where {K, V}
    i = 1
    while i < length(lst.entries)
        # first index is the largest key
        if (key > lst.entries[i][1])
            insert!(lst.entries, i, (key, value))
            i = lst.max_keys
        end
        i += 1
    end

    if i < lst.max_keys
        insert!(lst.entries, i, (key, value))
    end

    # trim back to max_keys size
    if (length(lst.entries) > lst.max_keys)
        pop!(lst.entries)
    end

    return lst
end

struct EpsilonBenchmarkResult{ValuesT <: Tuple}
    epsilons::Vector{Int64}
    worst_arguments::TopKSortedList{Int64, ValuesT}

    epsilon_limit::Int64
    function_name::String

    function EpsilonBenchmarkResult{ValuesT}(function_name::AbstractString, epsilon_limit::Int64, max_values::Int64) where {ValuesT <: Tuple}
        return new{ValuesT}(Int64[], TopKSortedList{Int64, ValuesT}(max_values), epsilon_limit, function_name)
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
    med = median(v)
    meanval = round(Int, mean(v))

    # Color helper
    function cstr(text, color)
        return Base.text_colors[color] * text * Base.text_colors[:normal]
    end

    # Lines to print
    lines = [
        ("samples: ", n, :cyan),
        ("minimum: ", minval, :green),
        ("median:  ", med, :blue),
        ("mean:    ", meanval, :magenta),
        ("maximum: ", maxval, :red),
    ]

    for (label, value, color) in lines
        @printf(io, "  %-9s %s ε\n", cstr(label, color), cstr(rpad(string(value), 5), :bold))
    end

    if (isempty(bench_result.worst_arguments.entries))
        @printf(io, "\n  %s\n", cstr(string("no imprecisions > $(bench_result.epsilon_limit)ε found"), :bold))
        return nothing
    end

    @printf(io, "\n  %s:\n", cstr(string("largest imprecisions"), :bold))
    for (key, value) in bench_result.worst_arguments.entries
        print(io, "    $(bench_result.function_name)(")
        first = true
        for v in value
            if (!first)
                print(io, ", ")
            end
            print(io, "precify($(v.x))")
            first = false
        end
        println(io, ") -> $key ε")
    end

    return nothing
end
