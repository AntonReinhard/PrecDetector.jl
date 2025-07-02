using Random

# rand functions
function Base.rand(rng::Random.AbstractRNG, type::Type{P{T}}) where {T <: AbstractFloat}
    return P(rand(rng, T))
end
Base.rand(rng::Random.AbstractRNG, type::Type{P}) = rand(rng, P{Float64})
