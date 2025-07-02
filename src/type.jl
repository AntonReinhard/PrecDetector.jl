struct PrecCarrier{T <: AbstractFloat} <: AbstractFloat
    x::T
    big::BigFloat
end

PrecCarrier(x::T) where {T <: Real} = PrecCarrier{T}(x, big(x))
PrecCarrier(p::PrecCarrier) = PrecCarrier(p.x, p.big)
PrecCarrier{T}(p::PrecCarrier{T}) where {T <: AbstractFloat} = PrecCarrier(p.x, p.big)
function PrecCarrier{T}(x::T2) where {T <: AbstractFloat, T2 <: Real}
    return PrecCarrier(T(x), big(T(x)))
end

const P = PrecCarrier
