using Random

macro _unary_function(operator)
    return Meta.parse("
    begin
        function Base.:$(operator)(p::P{T}) where {T<:AbstractFloat}
            res = P($(operator)(p.x), $(operator)(p.big))
            _assert_epsilons(res)
            return res
        end
    end
    ")
end

macro _binary_function(operator)
    return Meta.parse("
    begin
        function Base.:$(operator)(p1::P, p2::P)
            res = P($(operator)(p1.x, p2.x), $(operator)(p1.big, p2.big))
            _assert_epsilons(res)
            return res
        end
        function Base.:$(operator)(p1::Real, p2::P)
            res = P($(operator)(p1, p2.x), $(operator)(p1, p2.big))
            _assert_epsilons(res)
            return res
        end
        function Base.:$(operator)(p1::P, p2::Real)
            res =  P($(operator)(p1.x, p2), $(operator)(p1.big, p2))
            _assert_epsilons(res)
            return res
        end
        function Base.:$(operator)(p1::Integer, p2::P)
            res =  P($(operator)(p1, p2.x), $(operator)(p1, p2.big))
            _assert_epsilons(res)
            return res
        end
        function Base.:$(operator)(p1::P, p2::Integer)
            res = P($(operator)(p1.x, p2), $(operator)(p1.big, p2))
            _assert_epsilons(res)
            return res
        end
    end
    ")
end


macro _unary_comparison(operator)
    return Meta.parse("
    begin
        function Base.:($(operator))(p1::P)
            truth = $(operator)(p1.big)
            reality = $(operator)(p1.x)
            if truth != reality 
                @warn \"comparison result mismatch\"
            end
            return reality
        end
    end
    ")
end

macro _binary_comparison(operator)
    return Meta.parse("
    begin
        function Base.:($(operator))(p1::P, p2::P)
            truth = $(operator)(p1.big, p2.big)
            reality = $(operator)(p1.x, p2.x)
            if truth != reality 
                @warn \"comparison result mismatch\"
            end
            return reality
        end
        function Base.:($(operator))(p1::Real, p2::P)
            truth = $(operator)(p1, p2.big)
            reality = $(operator)(p1, p2.x)
            if truth != reality 
                @warn \"comparison result mismatch\"
            end
            return reality
        end
        function Base.:($(operator))(p1::P, p2::Real)
            truth = $(operator)(p1.big, p2)
            reality = $(operator)(p1.x, p2)
            if truth != reality 
                @warn \"comparison result mismatch\"
            end
            return reality
        end
    end
    ")
end

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

# comparisons
@_binary_comparison ==
@_binary_comparison !=
@_binary_comparison <
@_binary_comparison <=
@_binary_comparison >
@_binary_comparison >=
@_unary_comparison iszero
@_unary_comparison isone
@_unary_comparison ispow2
@_unary_comparison isfinite
@_unary_comparison isnan
#@_unary_comparison issubnormal <- not defined for BigFloat
@_unary_comparison isinteger
@_unary_comparison iseven
@_unary_comparison isodd


function Base.isapprox(p1::P, p2::P; kwargs...)
    truth = isapprox(p1.big, p2.big; kwargs...)
    reality = isapprox(p1.x, p2.x; kwargs...)
    if truth != reality
        @warn "comparison result mismatch"
    end
    return reality
end
function Base.isapprox(p1::Real, p2::P; kwargs...)
    truth = isapprox(p1, p2.big; kwargs...)
    reality = isapprox(p1, p2.x; kwargs...)
    if truth != reality
        @warn "comparison result mismatch"
    end
    return reality
end
function Base.:isapprox(p1::P, p2::Real; kwargs...)
    truth = isapprox(p1.big, p2; kwargs...)
    reality = isapprox(p1.x, p2; kwargs...)
    if truth != reality
        @warn "comparison result mismatch"
    end
    return reality
end
Base.eps(p::Type{P{T}}) where {T} = eps(T)

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

# rand functions
function Base.rand(rng::Random.AbstractRNG, type::Type{P{T}}) where {T <: AbstractFloat}
    return P(rand(rng, T))
end
Base.rand(rng::Random.AbstractRNG, type::Type{P}) = rand(rng, P{Float64})

# init functions
Base.one(::Type{P{T}}) where {T} = P(one(T))
Base.one(::Type{P}) = P(one(Float64))
Base.zero(::Type{P{T}}) where {T} = P(zero(T))
Base.zero(::Type{}) = P(zero(Float64))
