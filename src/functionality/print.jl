function Base.show(io::IO, p::P{T}) where {T <: AbstractFloat}
    no_ε = _no_epsilons(p)

    color = if 0 <= no_ε < 10
        :green
    elseif no_ε < 100
        :yellow
    elseif no_ε < 1000
        :red
    else # includes no_ε == -1
        :magenta
    end

    print(io, "$(p.x) ")

    if (no_ε < 0)
        return printstyled(io, "<ε=Inf>"; color = color)
    else
        return printstyled(io, "<ε=$no_ε>"; color = color)
    end

    return nothing
end
