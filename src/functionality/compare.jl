# comparisons
@_binary_comparison ==
@_binary_comparison !=
@_binary_comparison <
@_binary_comparison <=
@_binary_comparison >
@_binary_comparison >=
@_unary_comparison iszero
@_unary_comparison isone
@_unary_comparison ispow2
@_unary_comparison isfinite
@_unary_comparison isnan
@_unary_comparison isinteger
@_unary_comparison iseven
@_unary_comparison isodd

# @_unary_comparison issubnormal <- not defined for BigFloat
Base.issubnormal(p::P) = issubnormal(p.x)

function Base.isapprox(p1::P, p2::P; kwargs...)
    truth = isapprox(p1.big, p2.big; kwargs...)
    reality = isapprox(p1.x, p2.x; kwargs...)
    if truth != reality
        @warn "comparison result mismatch"
    end
    return reality
end
function Base.isapprox(p1::Real, p2::P; kwargs...)
    truth = isapprox(p1, p2.big; kwargs...)
    reality = isapprox(p1, p2.x; kwargs...)
    if truth != reality
        @warn "comparison result mismatch"
    end
    return reality
end
function Base.:isapprox(p1::P, p2::Real; kwargs...)
    truth = isapprox(p1.big, p2; kwargs...)
    reality = isapprox(p1.x, p2; kwargs...)
    if truth != reality
        @warn "comparison result mismatch"
    end
    return reality
end
Base.eps(p::P{T}) where {T} = eps(p.x)
Base.eps(p::Type{P{T}}) where {T} = eps(T)
