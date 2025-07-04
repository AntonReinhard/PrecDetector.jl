function _no_epsilons(p::P{T}) where {T <: AbstractFloat}
    return if iszero(p.x)
        iszero(p.big) ? 0 : Inf
    else
        round(Int, abs(p.big / p.x - one(BigFloat)) / big(eps(T)))
    end
end

"""
    significant_digits(p::PrecCarrier{T})

Return the number of significant decimal digits currently carried by this [`PrecCarrier`](@ref).

```jldoctest
julia> using PrecDetector

julia> function unstable(x, N)
           y = abs(x)
           for i in 1:N y = sqrt(y) end
           w = y
           for i in 1:N w = w^2 end
           return w
       end
unstable (generic function with 1 method)

julia> unstable(precify(0.5), 30)
0.4999999971854335 <ε=25351362>

julia> significant_digits(ans)
8.249558460661778
```
"""
function significant_digits(p::P{T}) where {T <: AbstractFloat}
    sig_digits = -log10(eps(T) * (_no_epsilons(p) + 1))
    return sig_digits
end

function _assert_epsilons(p::P{T}) where {T <: AbstractFloat}
    #=if _no_epsilons(p) > 1000
        throw("$p exceeded epsilon limit of 1000")
    end=#
    return nothing
end

"""
    reset_eps!(p::PrecCarrier{AbstractFloat})

Reset the precision carrier to zero epsilons. Can be called on
containers (`AbstractArray`s or `Tuple`s) to reset all underlying `PrecCarrier`s.

```jldoctest
julia> using PrecDetector

julia> function unstable(x, N)
           y = abs(x)
           for i in 1:N y = sqrt(y) end
           w = y
           for i in 1:N w = w^2 end
           return w
       end
unstable (generic function with 1 method)

julia> p = unstable(precify(1.5), 30)
1.4999996689838975 <ε=993842883>

julia> reset_eps!(p)
1.4999996689838975 <ε=0>
```

Custom types can be overloaded by implementing a function dispatching
the call downwards to all relevant members. Note that this is a muting
operation and therefore requires mutability of the members.

```julia
function reset_eps!(x::Custom)
    reset_eps!(x.v1)
    reset_eps!(x.v2)
    # ...
    return x
end
```
"""
@inline function reset_eps!(p::P{T}) where {T <: AbstractFloat}
    p.big = big(p.x)
    return p
end
@inline function reset_eps!(t::Tuple)
    return reset_eps!.(T, t)
end
@inline function reset_eps!(t::AbstractArray)
    return reset_eps!.(T, t)
end
