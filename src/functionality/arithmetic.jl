# basic functions
@_unary_function +
@_unary_function -
@_binary_function +
@_binary_function -
@_binary_function *
@_binary_function /
@_binary_function \
@_binary_function ^
@_binary_function mod
@_binary_function rem
@_unary_function abs

# min/max
@_binary_function min
@_binary_function max

# rounding (for floating point targets, do the rounding, but keep x and big separate and return a PrecisionCarrier again)
@_unary_function round
Base.round(::Type{T}, p::P) where {T <: Integer} = round(T, p.x) # necessary in 1.10
@_unary_function floor
Base.floor(::Type{T}, p::P) where {T <: Integer} = floor(T, p.x)
@_unary_function ceil
Base.ceil(::Type{T}, p::P) where {T <: Integer} = ceil(T, p.x)
@_unary_function trunc
Base.trunc(::Type{T}, p::P) where {T <: Integer} = trunc(T, p.x)

if (VERSION >= v"1.11")
    # julia 1.10 does not overload these rounding functions for float targets
    Base.round(::Type{T}, p::P) where {T <: AbstractFloat} = P{T}(round(T, p.x), big(round(T, p.big)))
    Base.floor(::Type{T}, p::P) where {T <: AbstractFloat} = P{T}(floor(T, p.x), big(floor(T, p.big)))
    Base.ceil(::Type{T}, p::P) where {T <: AbstractFloat} = P{T}(ceil(T, p.x), big(ceil(T, p.big)))
    Base.trunc(::Type{T}, p::P) where {T <: AbstractFloat} = P{T}(trunc(T, p.x), big(trunc(T, p.big)))
end

# powers, logs, roots
@_unary_function sqrt
@_unary_function cbrt
@_binary_function hypot
@_unary_function exp
@_unary_function expm1
@_unary_function log
@_binary_function log
@_unary_function log2
@_unary_function log10
@_unary_function log1p
@_binary_function ldexp # should technically only overload (x::P, n::Int)

Base.significand(p::P) = significand(p.x)
Base.exponent(p::P) = exponent(p.x)

# trig functions
for op in [
        sin, cos, tan, cot, sec, csc,               # "normal"
        sinh, cosh, tanh, coth, sech, csch,         # hyperbolic
        asin, acos, atan, acot, asec, acsc,         # arc
        asinh, acosh, atanh, acoth, asech, acsch,   # arc hyperbolic
        sinc, cosc,                                 # normalized
        sind, cosd, tand, cotd, secd, cscd,         # radians versions
        asind, acosd, atand, acotd, asecd, acscd,   # radians arc versions
        sinpi, cospi,                               # other
    ]
    eval(Meta.parse("@_unary_function $op"))
end

function Base.cis(p::T) where {T <: P}
    c = cis(p.x)
    c_big = cis(p.big)
    return Complex{T}(T(real(c), real(c_big)), T(imag(c), imag(c_big)))
end
function Base.sincos(p::P)
    if isinf(p.x)
        throw(DomainError(p.x, "sincos(x) is only defined for finite x."))
    elseif isinf(p.big)
        throw(DomainError(p.big, "sincos(x) is only defined for finite x."))
    end
    return (sin(p), cos(p))
end

# floating point functions
@_unary_function sign
@_binary_function flipsign
@_binary_function copysign
@_unary_type_function maxintfloat
@_unary_type_function typemin
@_unary_type_function typemax
@_unary_type_function floatmin
@_unary_type_function floatmax
@_unary_type_function eps
@_unary_type_function precision

# for these functions, convert the big part to T, then apply the operator,
# then convert back, to treat the big number *as if* it was a T
function Base.eps(p::P{T}) where {T}
    return P{T}(eps(p.x), big(eps(T(p.big))))
end
function Base.prevfloat(p::P{T}) where {T}
    return P{T}(prevfloat(p.x), big(prevfloat(T(p.big))))
end
function Base.prevfloat(p::P{T}, n::Integer) where {T}
    return P{T}(prevfloat(p.x, n), big(prevfloat(T(p.big), n)))
end
function Base.nextfloat(p::P{T}) where {T}
    return P{T}(nextfloat(p.x), big(nextfloat(T(p.big))))
end
function Base.nextfloat(p::P{T}, n::Integer) where {T}
    return P{T}(nextfloat(p.x, n), big(nextfloat(T(p.big), n)))
end

# ternary function
@_ternary_function fma
@_ternary_function muladd
