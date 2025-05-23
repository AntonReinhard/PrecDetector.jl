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

function _no_epsilons(p::P{T}) where {T <: AbstractFloat}
    return if iszero(p.x)
        iszero(p.big) ? 0 : Inf
    else
        round(Int, abs(p.big / p.x - one(BigFloat)) / big(eps(T)))
    end
end

function _assert_epsilons(p::P{T}) where {T <: AbstractFloat}
    #=if _no_epsilons(p) > 1000
        throw("$p exceeded epsilon limit of 1000")
    end=#
    return nothing
end

include("arithmetic.jl")
include("print.jl")

end # module PrecDetector
