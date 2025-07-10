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

function make_bins(vec::Vector{Int64}, minval::Int64, maxval::Int64, histogram_width::Int64)
    hist = fill(0, histogram_width)

    log_minval = log(minval)
    log_maxval = log(maxval)

    for val in vec
        if val == 0
            continue
        end
        unrounded = ((log(val) - log_minval) / log_maxval) * (histogram_width - 1)
        hist_index = round(Int, unrounded) + 1
        hist[hist_index] += 1
    end
    return hist
end

# slightly adapted from BenchmarkTools.jl
function ascii_hist(io::IO, bins::Vector{Int64})
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
        for c in row
            print(io, c)
        end
        print(io, '\n')
    end
    return nothing
end

function print_hist_info(io::IO, histogram_width::Int64, minval::Int64, maxval::Int64)
    # print left-most value
    minval_string = string("^ $minval ε")
    maxval_string = string("$maxval ε ^")
    spaces = max(0, (histogram_width - length(minval_string) - length(maxval_string)))

    print(io, "$minval_string")
    print(io, " "^spaces)
    return println(io, "$maxval_string")
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

    if (maxval != 0)
        histogram_width = 60
        clamped_minval = max(1, minval)
        # print histogram only when there are any imprecisions
        bins = make_bins(v, clamped_minval, maxval, histogram_width)
        ascii_hist(io, bins)
        print_hist_info(io, histogram_width, clamped_minval, maxval)
    end

    @printf(io, "\n  %s:\n", cstr(string("largest imprecisions"), :bold))

    for (key, value) in bench_result.worst_arguments.entries
        print(io, "    $(bench_result.function_name)(")
        _print_helper(io, value)
        print(io, ") -> ")
        _print_colored_epsilon(io, key)
        println("")
    end

    return nothing
end
