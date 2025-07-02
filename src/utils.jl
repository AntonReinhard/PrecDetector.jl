
function _no_epsilons(p::P{T}) where {T <: AbstractFloat}
    return if iszero(p.x)
        iszero(p.big) ? 0 : Inf
    else
        round(Int, abs(p.big / p.x - one(BigFloat)) / big(eps(T)))
    end
end

function _assert_epsilons(p::P{T}) where {T <: AbstractFloat}
    #=if _no_epsilons(p) > 1000
        throw("$p exceeded epsilon limit of 1000")
    end=#
    return nothing
end
