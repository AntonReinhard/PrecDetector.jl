macro _unary_function(operator)
    return Meta.parse("
    begin
        function Base.:$(operator)(p::P{T}) where {T<:AbstractFloat}
            res = P($(operator)(p.x), $(operator)(p.big))
            return res
        end
    end
    ")
end

macro _binary_function(operator)
    return Meta.parse("
    begin
        function Base.:$(operator)(p1::P, p2::P)
            res = P($(operator)(p1.x, p2.x), $(operator)(p1.big, p2.big))
            return res
        end
        function Base.:$(operator)(p1::Real, p2::P)
            res = P($(operator)(p1, p2.x), $(operator)(p1, p2.big))
            return res
        end
        function Base.:$(operator)(p1::P, p2::Real)
            res =  P($(operator)(p1.x, p2), $(operator)(p1.big, p2))
            return res
        end
        function Base.:$(operator)(p1::Integer, p2::P)
            res =  P($(operator)(p1, p2.x), $(operator)(p1, p2.big))
            return res
        end
        function Base.:$(operator)(p1::P, p2::Integer)
            res = P($(operator)(p1.x, p2), $(operator)(p1.big, p2))
            return res
        end
    end
    ")
end

macro _unary_comparison(operator)
    return Meta.parse("
        Base.:($(operator))(p1::P) = $(operator)(p1.x)
    ")
end

macro _binary_comparison(operator)
    return Meta.parse("
    begin
        Base.:($(operator))(p1::P, p2::P)= $(operator)(p1.x, p2.x)
        Base.:($(operator))(p1::Real, p2::P) = $(operator)(p1, p2.x)
        Base.:($(operator))(p1::P, p2::Real) = $(operator)(p1.x, p2)
    end
    ")
end
