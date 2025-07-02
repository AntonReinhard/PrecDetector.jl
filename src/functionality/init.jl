# init functions
Base.one(::Type{P{T}}) where {T} = P(one(T))
Base.one(::Type{P}) = P(one(Float64))
Base.zero(::Type{P{T}}) where {T} = P(zero(T))
Base.zero(::Type{}) = P(zero(Float64))
