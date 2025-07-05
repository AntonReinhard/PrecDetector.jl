function Base.convert(::Type{T}, p::P) where {T <: AbstractFloat}
    return P{T}(convert(T, p.x), p.big)
end
function Base.convert(::Type{P{T}}, p::P) where {T <: AbstractFloat}
    return P{T}(convert(T, p.x), p.big)
end
function Base.convert(::Type{P}, p::P{T}) where {T <: AbstractFloat}
    return P{T}(convert(T, p.x), p.big)
end
