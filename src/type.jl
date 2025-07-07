"""
    PrecisionCarrier{AbstractFloat}

A carrier type for floating points. Most math functions are overloaded
for this type. Initialize it with some value (or see [`precify`](@ref)
to convert an entire array or tuple type of numbers), do some arithmetic
with your value(s), and finally, print it to check the number of accumulated
epsilons of error.

```jldoctest
julia> using PrecisionCarriers

julia> function unstable(x, N)
           y = abs(x)
           for i in 1:N y = sqrt(y) end
           w = y
           for i in 1:N w = w^2 end
           return w
       end
unstable (generic function with 1 method)

julia> unstable(precify(2), 5)
1.9999999999999964 <ε=8>

julia> unstable(precify(2), 10)
2.0000000000000235 <ε=53>

julia> unstable(precify(2), 20)
2.0000000001573586 <ε=354340>

julia> unstable(precify(2), 128)
1.0 <ε=4503599627370496>

```
"""
mutable struct PrecisionCarrier{T <: AbstractFloat} <: AbstractFloat
    x::T
    big::BigFloat

    """
        PrecisionCarrier{T}(x, b)

    Construct a `PrecisionCarrier` directly from a float and a `BigFloat` value. The two
    values should be the same value, as far as precision allows.

    !!! warn
        This function should never be used by users. Instead, use [`precify`](@ref) or the
        various constructors from single arguments.
    """
    function PrecisionCarrier{T}(x, b) where {T <: AbstractFloat}
        @assert T != BigFloat "can not create a PrecisionCarrier with BigFloat"
        @assert !(T <: PrecisionCarrier) "can not create a PrecisionCarrier with $T"
        return new{T}(x, b)
    end
end

# allow inference of generic T from given value
function PrecisionCarrier(x::T, b::BigFloat) where {T <: AbstractFloat}
    return PrecisionCarrier{T}(x, b)
end

const P = PrecisionCarrier

# convert various <:Real types explicitly
P{T}(x::AbstractFloat) where {T <: AbstractFloat} = P{T}(T(x), big(x))
P{T}(x::Integer) where {T <: AbstractFloat} = P{T}(T(x), BigFloat(x))
P{T}(x::AbstractIrrational) where {T <: AbstractFloat} = P{T}(T(x), BigFloat(x))
P{T}(x::Rational) where {T <: AbstractFloat} = P{T}(T(x), BigFloat(x))

# cast other PrecisionCarrier
P{T}(p::P) where {T <: AbstractFloat} = P{T}(p.x, p.big)
P{T}(p::P{T}) where {T <: AbstractFloat} = P{T}(p.x, p.big)


# dispatch to default type Float64
P(x::T) where {T <: Real} = P{Float64}(x)

# dispatch to x type if its an AbstractFloat
P(x::T) where {T <: AbstractFloat} = P{T}(x)
P(x::P{T}) where {T <: AbstractFloat} = P{T}(x)

# more specific dispatch to default type for rationals to remove ambiguous call
P(x::Rational) = P{Float64}(x)
