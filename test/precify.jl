struct PrecifyUnimplemented end

struct CustomStruct{T1, T2, T3, T4}
    a::T1
    b::T2
    c::Vector{T3}
    d::Tuple{T4, T4}
end

function PrecisionCarriers.precify(T::Type{<:PrecisionCarrier}, x::CustomStruct)
    return CustomStruct(precify(T, x.a), precify(T, x.b), precify(T, x.c), precify(T, x.d))
end

DIMENSIONS = (1, 2, 3)
FLOAT_TYPES = [Float16, Float32, Float64]
INVALID_FLOAT_TYPES = [
    BigFloat,               # cannot construct with bigfloat, wouldn't make sense
    PrecisionCarrier{Float16},   # cannot construct PrecisionCarrier{PrecisionCarrier}
    PrecisionCarrier{Float32},
    PrecisionCarrier{Float64},
]
SOURCE_VALUES = Any[
    Float16(1.0),
    Float32(1.0),
    Float64(1.0),
    π,
    1 // 3,
    Int8(1),
    Int16(1),
    Int32(1),
    Int64(1),
    UInt8(1),
    UInt16(1),
    UInt32(1),
    UInt64(1),
    PrecisionCarrier{Float16}(1.0),
    PrecisionCarrier{Float32}(1.0),
    PrecisionCarrier{Float64}(1.0),
    big(1.0),
    CustomStruct(Float64(1.0), Float32(2.0), [Float16(3.0), Float16(4.0)], (5.0, 6.0)),
]

@testset "precify to $FLOAT_T" for FLOAT_T in FLOAT_TYPES
    for v in SOURCE_VALUES[1:(end - 1)]
        p = precify(PrecisionCarrier{FLOAT_T}, v)
        @test typeof(p) == PrecisionCarrier{FLOAT_T}

        p = precify(FLOAT_T, v)
        @test typeof(p) == PrecisionCarrier{FLOAT_T}
    end
end

@testset "precify $(N)D" for N in DIMENSIONS
    @testset "arrays of $(typeof(v))" for v in SOURCE_VALUES
        array = fill(v, ntuple(_ -> 4, N))
        @testset "default precify" begin
            precified = precify(array)

            t = eltype(precified)
            if (v isa PrecisionCarrier)
                @test t == typeof(v)
            elseif (v isa AbstractFloat)
                @test t == PrecisionCarrier{typeof(v)}
            elseif (v isa CustomStruct)
                el = precified[begin]

                @test typeof(el.a) == PrecisionCarrier{typeof(v.a)}
                @test typeof(el.b) == PrecisionCarrier{typeof(v.b)}
                @test eltype(el.c) == PrecisionCarrier{eltype(v.c)}
                @test eltype(el.d) == PrecisionCarrier{eltype(v.d)}
            else
                @test t == PrecisionCarrier{Float64}
            end
            if !(v isa CustomStruct)
                @test all(PrecisionCarriers.epsilons.(precified) .== 0)
            end
        end
    end

    @testset "tuples of $(typeof(v))" for v in SOURCE_VALUES
        tuple = ntuple(_ -> v, N)
        @testset "default precify" begin
            precified = precify(tuple)

            t = eltype(precified)
            if (v isa PrecisionCarrier)
                @test t == typeof(v)
            elseif (v isa AbstractFloat)
                @test t == PrecisionCarrier{typeof(v)}
            elseif (v isa CustomStruct)
                el = precified[begin]

                @test typeof(el.a) == PrecisionCarrier{typeof(v.a)}
                @test typeof(el.b) == PrecisionCarrier{typeof(v.b)}
                @test eltype(el.c) == PrecisionCarrier{eltype(v.c)}
                @test eltype(el.d) == PrecisionCarrier{eltype(v.d)}
            else
                @test t == PrecisionCarrier{Float64}
            end
            if !(v isa CustomStruct)
                @test all(PrecisionCarriers.epsilons.(precified) .== 0)
            end
        end
    end
end

@testset "precify type $FLOAT_T" for FLOAT_T in FLOAT_TYPES
    @test precify(FLOAT_T) == PrecisionCarrier{FLOAT_T}
    @test precify(Tuple{FLOAT_T, Float64}) == Tuple{PrecisionCarrier{FLOAT_T}, PrecisionCarrier{Float64}}
    @test precify(Vector{FLOAT_T}) == Vector{PrecisionCarrier{FLOAT_T}}
    @test precify(Array{FLOAT_T, 2}) == Array{PrecisionCarrier{FLOAT_T}, 2}
    @test precify(Vector{Tuple{FLOAT_T, FLOAT_T}}) == Vector{Tuple{PrecisionCarrier{FLOAT_T}, PrecisionCarrier{FLOAT_T}}}
    @test precify(PrecisionCarrier{FLOAT_T}) == PrecisionCarrier{FLOAT_T}
end

@testset "unimplemented precify" begin
    @test_throws "no precify is implemented for type PrecifyUnimplemented" precify(PrecifyUnimplemented())
end
