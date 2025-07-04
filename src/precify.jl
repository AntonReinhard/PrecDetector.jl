"""
    precify([::Type{PrecCarrier{T}}], t::Any) where {T<:AbstractFloat}
    precify([::Type{T}], t::Any) where {T<:AbstractFloat}

Convert a number or container to a container of [`PrecCarrier`](@ref)s. If no specific float type for the `PrecCarrier` is specified, the type of `t`s floats will be used.

```jldoctest
julia> using PrecDetector

julia> precify((0, 1.0, 2.0f0))
(0.0 <ε=0>, 1.0 <ε=0>, 2.0 <ε=0>)

julia> typeof(ans)
Tuple{PrecCarrier{Float64}, PrecCarrier{Float64}, PrecCarrier{Float32}}

julia> precify(PrecCarrier{Float32}, [0, 1.0, 2.0f0])
3-element Vector{PrecCarrier{Float32}}:
 0.0 <ε=0>
 1.0 <ε=0>
 2.0 <ε=0>

```
"""
@inline precify(t::Any) = precify(P, t)
@inline precify(T::Type{<:AbstractFloat}, t::Any) = precify(P{T}, t)
@inline function precify(T::Type{<:P}, t::Tuple)
    return precify.(T, t)
end
@inline function precify(T::Type{<:P}, t::AbstractArray)
    return precify.(T, t)
end
@inline function precify(::Type{P{T}}, t::T2) where {T <: AbstractFloat, T2 <: AbstractFloat}
    return convert(P{T}, t)
end
@inline function precify(::Type{P}, t::T) where {T <: AbstractFloat}
    return convert(P{T}, t)
end
@inline function precify(T::Type{<:P}, t::Integer)
    return convert(T, t)
end
