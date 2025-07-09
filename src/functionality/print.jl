function Base.show(io::IO, p::P{T}) where {T <: AbstractFloat}
    no_ε = epsilons(p)

    color = if no_ε < 10
        :green
    elseif no_ε < 100
        :yellow
    elseif no_ε < 1000
        :red
    else
        :magenta
    end

    print(io, "$(p.x) ")

    if (no_ε == typemax(Int64))
        printstyled(io, "<ε=Inf>"; color = color)
    else
        printstyled(io, "<ε=$no_ε>"; color = color)
    end

    return nothing
end
