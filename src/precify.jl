"""
    precify([::Type{PrecisionCarrier{T}}], t::Any) where {T<:AbstractFloat}
    precify([::Type{T}], t::Any) where {T<:AbstractFloat}

Convert a number or container to a container of [`PrecisionCarrier`](@ref)s. If no specific float type for the `PrecisionCarrier` is specified, the type of `t`s floats will be used.

```jldoctest
julia> using PrecisionCarriers

julia> precify((0, 1.0, 2.0f0))
(0.0 <ε=0>, 1.0 <ε=0>, 2.0 <ε=0>)

julia> typeof(ans)
Tuple{PrecisionCarrier{Float64}, PrecisionCarrier{Float64}, PrecisionCarrier{Float32}}

julia> precify(PrecisionCarrier{Float32}, [0, 1.0, 2.0f0])
3-element Vector{PrecisionCarrier{Float32}}:
 0.0 <ε=0>
 1.0 <ε=0>
 2.0 <ε=0>

```
"""
@inline precify(t::Any) = precify(P, t)
@inline precify(T::Type{<:AbstractFloat}, t::Any) = precify(P{T}, t)

# unimplemented throw to prevent infinite recursion (since P is also an AbstractFloat)
@inline precify(T::Type{<:P}, t::Any) = throw("no precify is implemented for type $(typeof(t))")

# convert PrecisionCarrier to PrecisionCarrier calls
@inline precify(T::Type{<:P}, p::P) = T(p)

# convert basic number types
@inline precify(T::Type{<:P}, x::AbstractFloat) = convert(T, x)
@inline precify(T::Type{<:P}, x::Integer) = convert(T, x)
@inline precify(T::Type{<:P}, x::AbstractIrrational) = convert(T, x)
@inline precify(T::Type{<:P}, x::Rational) = convert(T, x)

# container broadcasts
@inline precify(T::Type{<:P}, t::Tuple) = precify.(T, t)
@inline precify(T::Type{<:P}, t::AbstractArray) = precify.(T, t)
