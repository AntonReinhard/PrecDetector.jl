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
            i = lst.max_keys + 1
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

"""
    EpsilonBenchmarkResult

Result object returned by the [`@bench_epsilons`](@ref) macro. When `display`ed, it prints
a summary of the results, containing the minimum, median, mean, and maximum observed
epsilons, and a terminal-styled histogram.

## Fields:
- `epsilons`: A vector of all non-infinite collected epsilon samples. Infinite epsilons are
  excluded so that statistical measures do not get skewed.
- `total_samples`: The total number of collected samples.
- `worst_arguments`: Descending list of the top worst epsilons together with the respective
  arguments. Helpful for closer inspection of precision problems.
- `epsilon_limit`: The minimum number of epsilons a result must have to be considered for
  the worst arguments list.
- `call_string`: The call string of the function being benchmarked, with format specifiers
  to string-interpolate the values.
- `no_inf_epsilons`: Number of collected samples that gave infinite epsilons.
"""
mutable struct EpsilonBenchmarkResult
    epsilons::Vector{EpsT}
    total_samples::Int
    worst_arguments::TopKSortedList{EpsT, Tuple}
    epsilon_limit::EpsT
    call_string::String
    no_inf_epsilons::Int

    function EpsilonBenchmarkResult(call_string::AbstractString, epsilon_limit::EpsT, max_values::Int)
        return new(
            Int[],    # epsilons vector
            0,          # total samples
            TopKSortedList{EpsT, Tuple}(max_values),   # top k worst arguments
            epsilon_limit,  # limit for epsilons to be considered for worst arguments
            call_string,    # call string of the function call for printing
            0               # number of infinite epsilons
        )
    end
end

function Base.insert!(eps::EpsilonBenchmarkResult, key::EpsT, value::Tuple)
    eps.total_samples += 1

    if key >= eps.epsilon_limit
        insert!(eps.worst_arguments, key, value)
    end
    if key != EpsMax
        push!(eps.epsilons, key)
    else
        eps.no_inf_epsilons += 1
    end

    return nothing
end
