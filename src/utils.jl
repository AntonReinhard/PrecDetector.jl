# constant value for _special_eps to return when there are no special values
const _NORM_EPS::Int = 0

# constant value for _special_eps to return when the epsilon is infinite
const _INF_EPS::Int = 1

# constant value for _special_eps to return when the epsilon is zero
const _ZERO_EPS::Int = 2

"""
    epsilons(p::PrecisionCarrier{T})::

Return the number of epsilons of relative difference between `p.big` and `p.x` as an
`EpsT` (`Int64`) value.

!!! note
    Returns `EpsMax` (`typemax(Int64)`) if the difference is infinite, for example when
    the float reports `Inf` and the `BigFloat` has a non-infinite value.
"""
function epsilons(p::P{T})::EpsT where {T <: AbstractFloat}
    special_eps = _special_epsilon(p)
    if special_eps == _ZERO_EPS
        return zero(EpsT)
    elseif special_eps == _INF_EPS
        return EpsMax
    else
        no_eps = abs(p.big / p.x - one(BigFloat)) / big(eps(one(p.x)))
        if (no_eps > EpsMax)
            return EpsMax
        else
            return round(EpsT, no_eps)
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
8.249558483913594
```
"""
function significant_digits(p::P{T}) where {T <: AbstractFloat}
    special_eps = _special_epsilon(p)
    if special_eps == _ZERO_EPS
        # arguable if this is correct, considering subnormal numbers do funky things
        # with the machine epsilon
        return -log10(eps(one(p.x)))
    elseif special_eps == _INF_EPS
        return 0.0
    else
        relative_diff = abs(p.big / p.x - one(BigFloat))
        if iszero(relative_diff)
            # return maximum number of digits carried by the type
            relative_diff = eps(p.x)
        end
        return Float64(-log10(relative_diff))
    end
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
Base.promote_rule(T1::Type{BigFloat}, ::Type{P{T2}}) where {T2 <: AbstractFloat} = P{promote_type(T1, T2)}
Base.promote_rule(T::Type{Rational{T1}}, ::Type{P{T2}}) where {T1 <: Integer, T2 <: AbstractFloat} = P{promote_type(T, T2)}
Base.promote_rule(::Type{Complex{T1}}, ::Type{P{T2}}) where {T1 <: Real, T2 <: AbstractFloat} = Complex{P{promote_type(T1, T2)}}

"""
    _special_epsilon(p::P{T})

Returns:
- `_NORM_EPS` if neither p.x nor p.big need special treatment
- `_INF_EPS` if p.x or p.big have special values and the epsilon should be considered infinite
- `_ZERO_EPS` if p.x or p.big have special values and the epsilon should be considered zero
"""
@inline function _special_epsilon(p::P{T})::Int where {T <: AbstractFloat}
    if iszero(p.x) && !iszero(p.big)
        return _INF_EPS
    elseif iszero(p.x) && iszero(p.big)
        return _ZERO_EPS
        # order matters: isfinite returns false for NaN values, so treat NaNs first
    elseif xor(isnan(p.x), isnan(p.big))
        return _INF_EPS
    elseif isnan(p.x) && isnan(p.big)
        return _ZERO_EPS
    elseif xor(isfinite(p.x), isfinite(p.big))
        return _INF_EPS
    elseif !isfinite(p.x) && !isfinite(p.big) && sign(p.x) != sign(p.big)
        return _INF_EPS
    elseif !isfinite(p.x) && !isfinite(p.big) && sign(p.x) == sign(p.big)
        return _ZERO_EPS
    else
        return _NORM_EPS
    end
end
