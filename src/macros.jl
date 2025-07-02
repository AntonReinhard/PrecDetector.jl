macro _unary_function(operator)
    return Meta.parse("
    begin
        function Base.:$(operator)(p::P{T}) where {T<:AbstractFloat}
            res = P($(operator)(p.x), $(operator)(p.big))
            _assert_epsilons(res)
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
            _assert_epsilons(res)
            return res
        end
        function Base.:$(operator)(p1::Real, p2::P)
            res = P($(operator)(p1, p2.x), $(operator)(p1, p2.big))
            _assert_epsilons(res)
            return res
        end
        function Base.:$(operator)(p1::P, p2::Real)
            res =  P($(operator)(p1.x, p2), $(operator)(p1.big, p2))
            _assert_epsilons(res)
            return res
        end
        function Base.:$(operator)(p1::Integer, p2::P)
            res =  P($(operator)(p1, p2.x), $(operator)(p1, p2.big))
            _assert_epsilons(res)
            return res
        end
        function Base.:$(operator)(p1::P, p2::Integer)
            res = P($(operator)(p1.x, p2), $(operator)(p1.big, p2))
            _assert_epsilons(res)
            return res
        end
    end
    ")
end

macro _unary_comparison(operator)
    return Meta.parse("
    begin
        function Base.:($(operator))(p1::P)
            truth = $(operator)(p1.big)
            reality = $(operator)(p1.x)
            if truth != reality 
                @warn \"comparison result mismatch\"
            end
            return reality
        end
    end
    ")
end

macro _binary_comparison(operator)
    return Meta.parse("
    begin
        function Base.:($(operator))(p1::P, p2::P)
            truth = $(operator)(p1.big, p2.big)
            reality = $(operator)(p1.x, p2.x)
            if truth != reality 
                @warn \"comparison result mismatch\"
            end
            return reality
        end
        function Base.:($(operator))(p1::Real, p2::P)
            truth = $(operator)(p1, p2.big)
            reality = $(operator)(p1, p2.x)
            if truth != reality 
                @warn \"comparison result mismatch\"
            end
            return reality
        end
        function Base.:($(operator))(p1::P, p2::Real)
            truth = $(operator)(p1.big, p2)
            reality = $(operator)(p1.x, p2)
            if truth != reality 
                @warn \"comparison result mismatch\"
            end
            return reality
        end
    end
    ")
end
