module RandomExt

using PrecisionCarriers
using Random

const P = PrecisionCarrier

# need to overload the sampler function too, because
# otherwise the `AbstractFloat` one from Random itself catches it
function Random.Sampler(::Type{<:AbstractRNG}, p::Type{P{T}}, n::Random.Repetition) where {T <: AbstractFloat}
    return Random.SamplerType{p}()
end
function Random.Sampler(::Type{<:AbstractRNG}, p::Type{P}, n::Random.Repetition)
    return Random.SamplerType{P{Float64}}()
end

# rand functions
function Random.rand(rng::AbstractRNG, ::Random.SamplerType{P{T}}) where {T <: AbstractFloat}
    return P(rand(rng, T))
end
Random.rand(rng::AbstractRNG, ::Random.SamplerType{P}) = P(rand(rng, Float64))

# rand functions for arrays
function Random.rand!(rng::AbstractRNG, dst::Array{P{T}}, ::Random.SamplerType{P{T}}) where {T <: AbstractFloat}
    return dst = precify(rand(rng, T, size(dst)))
end

end
