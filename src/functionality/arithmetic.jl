# basic functions
@_unary_function +
@_unary_function -
@_binary_function +
@_binary_function -
@_binary_function *
@_binary_function /
@_binary_function \
@_binary_function ^
@_unary_function abs

# min/max
@_binary_function min
@_binary_function max

# rounding (for floating point targets, do the rounding, but keep x and big separate and return a PrecCarrier again)
@_unary_function round
Base.round(T::Type, p::P) = round(T, p.x)
Base.round(::Type{T}, p::P) where {T <: AbstractFloat} = P{T}(round(T, p.x), big(round(T, p.big)))
@_unary_function floor
Base.floor(T::Type, p::P) = floor(T, p.x)
Base.floor(::Type{T}, p::P) where {T <: AbstractFloat} = P{T}(floor(T, p.x), big(floor(T, p.big)))
@_unary_function ceil
Base.ceil(T::Type, p::P) = ceil(T, p.x)
Base.ceil(::Type{T}, p::P) where {T <: AbstractFloat} = P{T}(ceil(T, p.x), big(ceil(T, p.big)))
@_unary_function trunc
Base.trunc(T::Type, p::P) = trunc(T, p.x)
Base.trunc(::Type{T}, p::P) where {T <: AbstractFloat} = P{T}(trunc(T, p.x), big(trunc(T, p.big)))

Base.round(p::P, mode::RoundingMode) = round(p.x, mode)

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
Base.sincos(p::P) = (sin(p), cos(p))
