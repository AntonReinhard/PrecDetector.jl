module PrecDetector

export P

struct P{T <: AbstractFloat} <: AbstractFloat
    x::T
    big::BigFloat
end

P(x::T) where {T <: Real} = P{T}(x, big(x))
P(p::P) = P(p.x, p.big)
P{T}(p::P{T}) where {T <: AbstractFloat} = P(p.x, p.big)
function P{T}(x::T2) where {T <: AbstractFloat, T2 <: Real}
    return P(T(x), big(T(x)))
end

include("arithmetic.jl")
include("print.jl")

end # module PrecDetector
