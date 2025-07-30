# # Benchmarking Imprecisions of a Function

# For functions or expressions taking in some amount of floating point numbers and
# returning a single floating point number, `PrecisionCarriers.jl` provides a simple
# macro to quickly check for precision problems:

using PrecisionCarriers

foo(x, y) = sqrt(abs(x^2 - y^2))

@bench_epsilons foo(1.0, y) ranges = begin
    y = (0.5, 1.0)
end search_method = :evenly_spaced

# Function calls can be nested inside the expression as well, or multiple variables
# sampled simultaneously:

@bench_epsilons foo(exp2(x), y) ranges = begin
    x = (0.5, 2.0)
    y = (0.0, 2.0)
end

# To interpolate values from your local scope, use the `$` syntax:

z = 5.0

@bench_epsilons foo(exp2(x), y * $z) ranges = begin
    x = (1.0, 2.0)
    y = (0.0, 0.3)
end search_method = :random

# For information on the supported keyword arguments, see also [`@bench_epsilons`](@ref).
