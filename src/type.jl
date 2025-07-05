"""
    PrecCarrier{AbstractFloat}

A carrier type for floating points. Most math functions are overloaded
for this type. Initialize it with some value (or see [`precify`](@ref)
to convert an entire array or tuple type of numbers), do some arithemitc
with your value(s), and finally, print it to check the number of accumulated
epsilons of error.

```jldoctest
julia> using PrecDetector

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
mutable struct PrecCarrier{T <: AbstractFloat} <: AbstractFloat
    x::T
    big::BigFloat

    function PrecCarrier{T}(x, b) where {T <: AbstractFloat}
        @assert T != BigFloat "can not create a PrecCarrier with BigFloat"
        @assert !(T <: PrecCarrier) "can not create a PrecCarrier with $T"
        return new{T}(x, b)
    end
end

const P = PrecCarrier

# convert various <:Real types explicitly
P{T}(x::AbstractFloat) where {T <: AbstractFloat} = P{T}(T(x), big(x))
P{T}(x::Integer) where {T <: AbstractFloat} = P{T}(T(x), BigFloat(x))
P{T}(x::AbstractIrrational) where {T <: AbstractFloat} = P{T}(T(x), BigFloat(x))
P{T}(x::Rational) where {T <: AbstractFloat} = P{T}(T(x), BigFloat(x))

# cast other PrecCarrier
P{T}(p::P) where {T <: AbstractFloat} = P{T}(p.x, p.big)
P{T}(p::P{T}) where {T <: AbstractFloat} = P{T}(p.x, p.big)


# dispatch to default type Float64
P(x::T) where {T <: Real} = P{Float64}(x)

# dispatch to x type if its an AbstractFloat
P(x::T) where {T <: AbstractFloat} = P{T}(x)
P(x::P{T}) where {T <: AbstractFloat} = P{T}(x)

# more specific dispatch to default type for rationals to remove ambiguous call
P(x::Rational) = P{Float64}(x)
