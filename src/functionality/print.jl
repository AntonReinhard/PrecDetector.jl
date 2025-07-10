function _print_colored_epsilon(io::IO, ε::Int64)
    color = if ε < 10
        :green
    elseif ε < 100
        :yellow
    elseif ε < 1000
        :red
    else
        :magenta
    end

    return if (ε == typemax(Int64))
        printstyled(io, "<ε=Inf>"; color = color)
    else
        printstyled(io, "<ε=$ε>"; color = color)
    end

end

function Base.show(io::IO, p::P{T}) where {T <: AbstractFloat}
    print(io, "$(p.x) ")
    _print_colored_epsilon(io, epsilons(p))
    return nothing
end
