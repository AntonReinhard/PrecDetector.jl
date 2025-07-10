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

mutable struct EpsilonBenchmarkResult
    # list of all collected (non infinite) epsilons
    epsilons::Vector{Int64}

    # number of total samples collected
    total_samples::Int64

    # descending list of the top worst epsilons together with the respective arguments
    worst_arguments::TopKSortedList{Int64, Tuple}

    # the minimum epsilons of a result to be considered for the worst arguments list
    epsilon_limit::Int64

    # the call string of the function being benchmarked, with format specifiers to interpolate the values
    call_string::String

    # number of collected samples that gave infinite epsilons
    no_inf_epsilons::Int64

    function EpsilonBenchmarkResult(call_string::AbstractString, epsilon_limit::Int64, max_values::Int64)
        return new(
            Int64[],    # epsilons vector
            0,          # total samples
            TopKSortedList{Int64, Tuple}(max_values),   # top k worst arguments
            epsilon_limit,  # limit for epsilons to be considered for worst arguments
            call_string,    # call string of the function call for printing
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
