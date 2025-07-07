"""
    _no_epsilons(p::PrecisionCarrier{T})

Return the number of epsilons of relative difference between `p.big` and `p.x`.
Returns -1 if the difference is infinite.
"""
function _no_epsilons(p::P{T}) where {T <: AbstractFloat}
    return if iszero(p.x) # if only p.big is zero, epsilon is still well-defined
        iszero(p.big) ? 0 : -1
    elseif isnan(p.x) || isnan(p.big)
        isnan(p.x) && isnan(p.big) ? 0 : -1
    elseif !isfinite(p.x) || !isfinite(p.big)
        if !isfinite(p.x) && !isfinite(p.big)
            sign(p.x) == sign(p.big) ? 0 : -1
        else
            -1
        end
    else
        no_eps = abs(p.big / p.x - one(BigFloat)) / big(eps(T))
        if (no_eps > typemax(Int64))
            return -1
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
    epsilons = _no_epsilons(p)
    if (epsilons < 0)
        return 0.0
    end
    sig_digits = -log10(eps(T) * (epsilons + 1))
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
    _float_type(::P{T})
    _float_type(::Type{P{T}})

Return the underlying float type of the [`PrecisionCarrier`](@ref).
"""
_float_type(::P{T}) where {T} = T
_float_type(::Type{P{T}}) where {T} = T
_float_type(::Type{P}) = Float64

"""
    Base.eltype(::PrecisionCarrier)

Return the internally carried floating point type.
"""
Base.eltype(p::P) = _float_type(p)
Base.eltype(T::Type{<:P}) = _float_type(T)

function Base.promote_rule(::Type{P{T1}}, ::Type{P{T2}}) where {T1 <: AbstractFloat, T2 <: AbstractFloat}
    return P{promote_type(T1, T2)}
end
function Base.promote_rule(::Type{T1}, ::Type{P{T2}}) where {T1 <: Real, T2 <: AbstractFloat}
    return P{promote_type(T1, T2)}
end
function Base.promote_rule(::Type{T1}, ::Type{P{T2}}) where {TF, T1 <: Complex{TF}, T2 <: AbstractFloat}
    return Complex{P{promote_type(TF, T2)}}
end
