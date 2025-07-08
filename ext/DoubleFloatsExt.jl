module DoubleFloatsExt

using PrecisionCarriers
using DoubleFloats

const P = PrecisionCarrier

# conversion to doublefloats:
function Base.convert(::Type{DoubleFloat{T}}, p::P) where {T <: Base.IEEEFloat}
    return P{DoubleFloat{T}}(convert(DoubleFloat{T}, p.x), p.big)
end

# constructors for doublefloats
function DoubleFloats.Double16(p::P{T}) where {T <: AbstractFloat}
    return convert(Double16, p)
end
function DoubleFloats.Double32(p::P{T}) where {T <: AbstractFloat}
    return convert(Double32, p)
end
function DoubleFloats.Double64(p::P{T}) where {T <: AbstractFloat}
    return convert(Double64, p)
end
function DoubleFloats.DoubleFloat(p::P{T}) where {T <: AbstractFloat}
    return convert(DoubleFloat{T}, p)
end

end
