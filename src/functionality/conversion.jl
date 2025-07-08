# these conversions are slightly evil, but necessary
# so unaware code does not accidentally cast away
# the PrecisionCarriers

function Base.convert(::Type{T}, p::P) where {T <: AbstractFloat}
    return P{T}(convert(T, p.x), p.big)
end
function Base.convert(::Type{P{T}}, p::P) where {T <: AbstractFloat}
    return P{T}(convert(T, p.x), p.big)
end
function Base.convert(::Type{P}, p::P{T}) where {T <: AbstractFloat}
    return P{T}(convert(T, p.x), p.big)
end

function Base.Float16(p::P{T}) where {T <: AbstractFloat}
    return convert(Float16, p)
end
function Base.Float32(p::P{T}) where {T <: AbstractFloat}
    return convert(Float32, p)
end
function Base.Float64(p::P{T}) where {T <: AbstractFloat}
    return convert(Float64, p)
end
