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

# rounding
@_unary_function round
Base.round(T, p::P) = round(T, p.x)
@_unary_function floor
floor(T, p::P) = floor(T, p.x)
@_unary_function ceil
ceil(T, p::P) = ceil(T, p.x)
@_unary_function trunc
trunc(T, p::P) = trunc(T, p.x)

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
@_unary_function exponent
@_binary_function ldexp # should technically only overload (x::P, n::Int)

Base.significand(p::P) = significand(p.x)

# trig functions
for op in [
        sin, cos, tan, cot, sec, csc,               # "normal"
        sinh, cosh, tanh, coth, sech, csch,         # hyperbolic
        asin, acos, atan, acot, asec, acsc,         # arc
        asinh, acosh, atanh, acoth, asech, acsch,   # arc hyperbolic
        sinc, cosc,                                 # normalized
        sind, cosd, tand, cotd, secd, cscd,         # radians versions
        asind, acosd, atand, acotd, asecd, acscd,   # radians arc versions
        cis, sinpi, cospi,                          # other
    ]
    eval(Meta.parse("@_unary_function $op"))
end

Base.sincos(p::P) = (sin(p), cos(p))
