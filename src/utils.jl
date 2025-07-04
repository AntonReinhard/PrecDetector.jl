function _no_epsilons(p::P{T}) where {T <: AbstractFloat}
    return if iszero(p.x)
        iszero(p.big) ? 0 : Inf
    else
        round(Int, abs(p.big / p.x - one(BigFloat)) / big(eps(T)))
    end
end

"""
    significant_digits(p::PrecCarrier{T})

Return the number of significant decimal digits currently carried by this PrecCarrier.

```jldoctest
julia> using PrecDetector

julia> function unstable(x, N)
           y = abs(x)
           for i in 1:N y = sqrt(y) end
           w = y
           for i in 1:N w = w^2 end
           return w
       end

julia> unstable(precify(0.5), 30)
0.4999999971854335 <ε=25351362>

julia> significant_digits(ans)
8.249558460661778
```
"""
function significant_digits(p::P{T}) where {T <: AbstractFloat}
    sig_digits = -log10(eps() * (_no_epsilons(p) + 1))
    return sig_digits
end

function _assert_epsilons(p::P{T}) where {T <: AbstractFloat}
    #=if _no_epsilons(p) > 1000
        throw("$p exceeded epsilon limit of 1000")
    end=#
    return nothing
end
