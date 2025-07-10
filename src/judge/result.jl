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

mutable struct EpsilonBenchmarkResult
    epsilons::Vector{Int64}
    total_samples::Int64
    worst_arguments::TopKSortedList{Int64, Tuple}

    epsilon_limit::Int64
    function_name::String

    no_inf_epsilons::Int64

    function EpsilonBenchmarkResult(function_name::AbstractString, epsilon_limit::Int64, max_values::Int64)
        return new(
            Int64[],    # epsilons vector
            0,          # total samples
            TopKSortedList{Int64, Tuple}(max_values),   # top k worst arguments
            epsilon_limit,  # limit for epsilons to be considered for worst arguments
            function_name,  # name of the function call for printing
            0               # number of infinite epsilons
        )
    end
end

function Base.insert!(eps::EpsilonBenchmarkResult, key::Int64, value::Tuple)
    eps.total_samples += 1

    if key >= eps.epsilon_limit
        insert!(eps.worst_arguments, key, value)
    end
    if key != typemax(Int64)
        push!(eps.epsilons, key)
    else
        eps.no_inf_epsilons += 1
    end

    return nothing
end


function Base.show(io::IO, ::MIME"text/plain", bench_result::EpsilonBenchmarkResult)
    v = bench_result.epsilons

    if isempty(v)
        print(io, "No samples were collected.")
        return
    end

    # Summary statistics
    minval = minimum(v)
    maxval = maximum(v)
    med = round(median(v); digits = 3)
    meanval = round(mean(v); digits = 3)

    # Color helper
    function cstr(text, color)
        return Base.text_colors[color] * text * Base.text_colors[:normal]
    end

    @printf(io, "  %-9s %s\n", cstr("samples: ", :cyan), cstr(string(bench_result.total_samples), :bold))
    @printf(io, "  %-9s %s ε\n", cstr("minimum: ", :green), cstr(string(minval), :bold))
    @printf(io, "  %-9s %s ε\n", cstr("median:  ", :blue), cstr(string(med), :bold))
    @printf(io, "  %-9s %s ε\n", cstr("mean:    ", :magenta), cstr(string(meanval), :bold))
    @printf(io, "  %-9s %s ε\n", cstr("maximum: ", :red), cstr(string(maxval), :bold))
    if bench_result.no_inf_epsilons != 0
        @printf(io, "  %-9s %s\n", cstr("samples with infinite ε:", :bold), string(bench_result.no_inf_epsilons))
    end

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
        print(io, ") -> ")
        _print_colored_epsilon(io, key)
        println("")
    end

    return nothing
end
