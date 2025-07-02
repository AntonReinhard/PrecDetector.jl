function Base.convert(::Type{TF}, p::P) where {TF <: AbstractFloat}
    return P(convert(TF, p.x), p.big)
end

function Base.convert(::Type{P{TF}}, p::P) where {TF <: AbstractFloat}
    return P(convert(TF, p.x), p.big)
end
