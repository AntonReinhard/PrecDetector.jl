const mean_color = :magenta
const median_color = :blue
const min_color = :green
const max_color = :red

"""
    make_bins(
        vec::Vector{EpsT},
        min_val::EpsT,
        max_val::EpsT,
        mean_val::AbstractFloat,
        median_val::AbstractFloat,
        histogram_width::Int
    )

Helper function for printing [`EpsilonBenchmarkResult`](@ref). Returns a tuple
`(hist, mean_bin, median_bin)`, where `hist` is a vector of length `histogram_width`.
The elements represent the number of results (from the given `vec`) in the bin.
`mean_bin` and `median_bin` contain the bins that the given `mean_val` and `median_val`
fall in. `min_val` and `max_val` are used to scale the histogram appropriately.
The histogram bins are sized logarithmically, which also means that 0 values are ignored.
This function errors when the difference between `min_val` and `max_val` is 1 or less, or
when `min_val` is 0 or less.
"""
function make_bins(
        vec::Vector{EpsT},
        min_val::EpsT,
        max_val::EpsT,
        mean_val::AbstractFloat,
        median_val::AbstractFloat,
        histogram_width::Int
    )
    hist = fill(0, histogram_width)

    log_minval = log(min_val)
    log_maxval = log(max_val)

    _getbin(val) = round(Int, ((log(val) - log_minval) / log_maxval) * (histogram_width - 1)) + 1

    for val in vec
        if val == 0
            continue
        end
        hist_index = _getbin(val)
        hist[hist_index] += 1
    end

    mean_bin = iszero(mean_val) ? -1 : _getbin(mean_val)
    median_bin = iszero(median_val) ? -1 : _getbin(median_val)

    return hist, mean_bin, median_bin
end

"""
    ascii_hist(io::IO, bins::Vector{Int}, mean_bin::Int, median_bin::Int)

Prints the given histogram (`bins`) to the given `io`. The mean and median bins
are colored in their respective colors.

!!! note
    The implementation is copied and slightly adapted from BenchmarkTools.jl.
"""
function ascii_hist(io::IO, bins::Vector{Int}, mean_bin::Int, median_bin::Int)
    height = 2
    hist_bars = ['▁', '▂', '▃', '▄', '▅', '▆', '▇', '█']
    if minimum(bins) == 0
        bar_heights =
            2 .+ round.(Int, (height * length(hist_bars) - 2) * bins ./ maximum(bins))
        bar_heights[bins .== 0] .= 1
    else
        bar_heights =
            1 .+ round.(Int, (height * length(hist_bars) - 1) * bins ./ maximum(bins))
    end
    height_matrix = [
        min(length(hist_bars), bar_heights[b] - (h - 1) * length(hist_bars)) for
            h in height:-1:1, b in 1:length(bins)
    ]
    hist = map(
        height -> height < 1 ? ' ' : hist_bars[height],
        height_matrix
    )

    println(io)
    for row in eachrow(hist)
        for c in eachindex(row)
            if (c == mean_bin)
                printstyled(io, row[c]; color = mean_color)
            elseif (c == median_bin)
                printstyled(io, row[c]; color = median_color)
            else
                print(io, row[c])
            end
        end
        print(io, '\n')
    end
    return nothing
end

"""
    print_hist_info(io::IO, histogram_width::Int, minval::EpsT, maxval::EpsT)

To be called after [`ascii_hist`](@ref). Prints a line below the histogram marking the
minimum and maximum value.
"""
function print_hist_info(io::IO, histogram_width::Int, minval::EpsT, maxval::EpsT)
    # print left-most value
    minval_string = string("^ $minval ε")
    maxval_string = string("$maxval ε ^")
    info_string = "log scale"
    no_spaces = max(0, (histogram_width - length(minval_string) - length(maxval_string) - length(info_string)))

    printstyled(io, "$minval_string"; color = min_color)
    print(io, " "^(no_spaces ÷ 2))
    printstyled(io, info_string; bold = true, underline = true)
    print(io, " "^(no_spaces - no_spaces ÷ 2))

    return printstyled(io, "$maxval_string\n"; color = max_color)
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
    @printf(io, "  %-9s %s ε\n", cstr("minimum: ", min_color), cstr(string(minval), :bold))
    @printf(io, "  %-9s %s ε\n", cstr("median:  ", median_color), cstr(string(med), :bold))
    @printf(io, "  %-9s %s ε\n", cstr("mean:    ", mean_color), cstr(string(meanval), :bold))
    @printf(io, "  %-9s %s ε\n", cstr("maximum: ", max_color), cstr(string(maxval), :bold))
    if bench_result.no_inf_epsilons != 0
        @printf(io, "  %-9s %s\n", cstr("samples with infinite ε:", :bold), string(bench_result.no_inf_epsilons))
    end

    if ((maxval - minval) >= 2)
        histogram_width = 60
        clamped_minval = max(1, minval)
        # print histogram only when there are any imprecisions
        bins, mean_bin, median_bin = make_bins(v, clamped_minval, maxval, meanval, med, histogram_width)
        ascii_hist(io, bins, mean_bin, median_bin)
        print_hist_info(io, histogram_width, clamped_minval, maxval)
    end

    if (isempty(bench_result.worst_arguments.entries))
        @printf(io, "\n  %s\n", cstr(string("no imprecisions > $(bench_result.epsilon_limit)ε found"), :bold))
        return nothing
    end

    @printf(io, "\n  %s:\n", cstr(string("largest imprecisions"), :bold))

    for (key, value) in bench_result.worst_arguments.entries
        Printf.format(io, Printf.Format(bench_result.call_string), value...)
        print(io, " -> ")
        _print_colored_epsilon(io, key)
        println(io, "")
    end

    return nothing
end
