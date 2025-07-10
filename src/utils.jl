"""
    epsilons(p::PrecisionCarrier{T})::

Return the number of epsilons of relative difference between `p.big` and `p.x` as an
`Int64` value.

!!! note
    Returns `typemax(Int64)` if the difference is infinite, for example when the float
    reports `Inf` and the `BigFloat` has a non-infinite value.
"""
function epsilons(p::P{T})::Int64 where {T <: AbstractFloat}
    return if iszero(p.x) # if only p.big is zero, epsilon is still well-defined
        iszero(p.big) ? 0 : typemax(Int64)
    elseif isnan(p.x) || isnan(p.big)
        isnan(p.x) && isnan(p.big) ? 0 : typemax(Int64)
    elseif !isfinite(p.x) || !isfinite(p.big)
        if !isfinite(p.x) && !isfinite(p.big)
            sign(p.x) == sign(p.big) ? 0 : typemax(Int64)
        else
            typemax(Int64)
        end
    else
        no_eps = abs(p.big / p.x - one(BigFloat)) / big(eps(T))
        if (no_eps > typemax(Int64))
            return typemax(Int64)
        else
            return round(Int64, no_eps)
        end
    end
end

"""
    significant_digits(p::PrecisionCarrier{T})

Return the number of significant decimal digits currently carried by this [`PrecisionCarrier`](@ref).

```jldoctest
julia> using PrecisionCarriers

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
    ε = epsilons(p)
    if (ε == typemax(Int64))
        return 0.0
    end
    sig_digits = -log10(eps(T) * (ε + 1))
    return sig_digits
end

"""
    reset_eps!(p::PrecisionCarrier{AbstractFloat})

Reset the precision carrier to zero epsilons. Can be called on
containers (`AbstractArray`s or `Tuple`s) to reset all underlying `PrecisionCarrier`s.

```jldoctest
julia> using PrecisionCarriers

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
    return reset_eps!.(t)
end
@inline function reset_eps!(t::AbstractArray)
    return reset_eps!.(t)
end

"""
    Base.eltype(::PrecisionCarrier)

Return the internally carried floating point type.
"""
Base.eltype(p::P{T}) where {T} = T
Base.eltype(::Type{P{T}}) where {T} = T
Base.eltype(::Type{P}) = Float64

Base.promote_rule(::Type{P{T1}}, ::Type{P{T2}}) where {T1 <: AbstractFloat, T2 <: AbstractFloat} = P{promote_type(T1, T2)}
Base.promote_rule(::Type{T1}, ::Type{P{T2}}) where {T1 <: AbstractFloat, T2 <: AbstractFloat} = P{promote_type(T1, T2)}
Base.promote_rule(::Type{T1}, ::Type{P{T2}}) where {T1 <: Integer, T2 <: AbstractFloat} = P{promote_type(T1, T2)}
Base.promote_rule(T::Type{Rational{T1}}, ::Type{P{T2}}) where {T1 <: Integer, T2 <: AbstractFloat} = P{promote_type(T, T2)}
Base.promote_rule(::Type{Complex{T1}}, ::Type{P{T2}}) where {T1 <: Real, T2 <: AbstractFloat} = Complex{P{promote_type(T1, T2)}}
