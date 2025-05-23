function Base.show(io::IO, p::P{T}) where {T <: AbstractFloat}
    no_ε = if iszero(p.x)
        iszero(p.big) ? 0 : Inf
    else
        round(Int, abs(p.big / p.x - one(BigFloat)) / big(eps(T)))
    end
    return print(io, "$(T(p.big)), ε=$no_ε")
end
