"""
    PrecCarrier{AbstractFloat}

A carrier type for floating points. Most math functions are overloaded
for this type. Initialize it with some value (or see [`precify`](@ref)
to convert an entire array or tuple type of numbers), do some arithemitc
with your value(s), and finally, print it to check the number of accumulated
epsilons of error.

```jldoctest
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
struct PrecCarrier{T <: AbstractFloat} <: AbstractFloat
    x::T
    big::BigFloat
end

PrecCarrier(x::T) where {T <: AbstractFloat} = PrecCarrier{T}(x, big(x))
PrecCarrier(x::Integer) = PrecCarrier{Float64}(x, BigFloat(x))
PrecCarrier(p::PrecCarrier) = PrecCarrier(p.x, p.big)
PrecCarrier{T}(p::PrecCarrier{T}) where {T <: AbstractFloat} = PrecCarrier(p.x, p.big)
function PrecCarrier{T}(x::T2) where {T <: AbstractFloat, T2 <: Real}
    return PrecCarrier(T(x), big(T(x)))
end

const P = PrecCarrier
