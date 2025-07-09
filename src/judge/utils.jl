"""
    grid_samples(ranges::Tuple{Vararg{Tuple{<:Real, <:Real}}}, n::Integer)

Generate approximately `n` evenly spaced samples over the Cartesian grid defined by `ranges`.
Each element of `ranges` is a (lo, hi) tuple. Returns an iterator over tuples of sampled points.
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
