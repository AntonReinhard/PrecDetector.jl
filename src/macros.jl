macro _unary_function(operator)
    return Meta.parse("
    begin
        function Base.:$(operator)(p::P{T}; kw...) where {T<:AbstractFloat}
            res = P(($(operator))(p.x; kw...), ($(operator))(p.big; kw...))
            return res
        end
    end
    ")
end

macro _binary_function(operator)
    return Meta.parse("
    begin
        function Base.:$(operator)(p1::P, p2::P; kw...)
            res = P($(operator)(p1.x, p2.x; kw...), $(operator)(p1.big, p2.big; kw...))
            return res
        end
        function Base.:$(operator)(p1::Real, p2::P; kw...)
            res = P($(operator)(p1, p2.x; kw...), $(operator)(p1, p2.big; kw...))
            return res
        end
        function Base.:$(operator)(p1::P, p2::Real; kw...)
            res =  P($(operator)(p1.x, p2; kw...), $(operator)(p1.big, p2; kw...))
            return res
        end
        function Base.:$(operator)(p1::Integer, p2::P; kw...)
            res =  P($(operator)(p1, p2.x; kw...), $(operator)(p1, p2.big; kw...))
            return res
        end
        function Base.:$(operator)(p1::P, p2::Integer; kw...)
            res = P($(operator)(p1.x, p2; kw...), $(operator)(p1.big, p2; kw...))
            return res
        end
    end
    ")
end

macro _ternary_function(operator)
    # other cases should be caught by generic Base julia type promotion overloads
    return Meta.parse("
    begin
        function Base.$(operator)(p1::P{T}, p2::P{T}, p3::P{T}; kw...) where {T<:AbstractFloat}
            return P(
                $(operator)(p1.x, p2.x, p3.x; kw...),
                $(operator)(p1.big, p2.big, p3.big; kw...)
            )
        end
    end
    ")
end

macro _unary_comparison(operator)
    return Meta.parse("
        Base.:($(operator))(p1::P; kw...) = $(operator)(p1.x; kw...)
    ")
end

macro _binary_comparison(operator)
    return Meta.parse("
    begin
        Base.:($(operator))(p1::P, p2::P; kw...)= $(operator)(p1.x, p2.x; kw...)
        # compare with reals
        Base.:($(operator))(p1::Real, p2::P; kw...) = $(operator)(p1, p2.x; kw...)
        Base.:($(operator))(p1::P, p2::Real; kw...) = $(operator)(p1.x, p2; kw...)
        # compare with rationals (needed for disambiguation)
        Base.:($(operator))(p1::Rational, p2::P; kw...) = $(operator)(p1, p2.x; kw...)
        Base.:($(operator))(p1::P, p2::Rational; kw...) = $(operator)(p1.x, p2; kw...)
    end
    ")
end

macro _unary_type_function(operator)
    return Meta.parse("
        function Base.:($(operator))(::Type{P{T}}; kw...) where {T}
            m = $(operator)(T; kw...)
            return P{T}(m, big(m))
        end
    ")
end
