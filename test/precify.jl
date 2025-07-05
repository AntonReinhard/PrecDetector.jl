struct PrecifyUnimplemented end

struct CustomStruct{T1, T2, T3, T4}
    a::T1
    b::T2
    c::Vector{T3}
    d::Tuple{T4, T4}
end

function PrecDetector.precify(T::Type{<:PrecCarrier}, x::CustomStruct)
    return CustomStruct(precify(T, x.a), precify(T, x.b), precify(T, x.c), precify(T, x.d))
end

DIMENSIONS = (1, 2, 3)
FLOAT_TYPES = [Float16, Float32, Float64]
INVALID_FLOAT_TYPES = [
    BigFloat,               # cannot construct with bigfloat, wouldn't make sense
    PrecCarrier{Float16},   # cannot construct PrecCarrier{PrecCarrier}
    PrecCarrier{Float32},
    PrecCarrier{Float64},
]
SOURCE_VALUES = [
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
    PrecCarrier{Float16}(1.0),
    PrecCarrier{Float32}(1.0),
    PrecCarrier{Float64}(1.0),
    CustomStruct(Float64(1.0), Float32(2.0), [Float16(3.0), Float16(4.0)], (5.0, 6.0)),
]

@testset "precify to $FLOAT_T" for FLOAT_T in FLOAT_TYPES
    for v in SOURCE_VALUES[1:(end - 1)]
        p = precify(PrecCarrier{FLOAT_T}, v)
        @test typeof(p) == PrecCarrier{FLOAT_T}

        p = precify(FLOAT_T, v)
        @test typeof(p) == PrecCarrier{FLOAT_T}
    end
end

@testset "precify $(N)D" for N in DIMENSIONS
    @testset "arrays of $(typeof(v))" for v in SOURCE_VALUES
        array = fill(v, ntuple(_ -> 4, N))
        @testset "default precify" begin
            precified = precify(array)

            t = eltype(precified)
            if (v isa PrecCarrier)
                @test t == typeof(v)
            elseif (v isa AbstractFloat)
                @test t == PrecCarrier{typeof(v)}
            elseif (v isa CustomStruct)
                el = precified[begin]

                @test typeof(el.a) == PrecCarrier{typeof(v.a)}
                @test typeof(el.b) == PrecCarrier{typeof(v.b)}
                @test eltype(el.c) == PrecCarrier{eltype(v.c)}
                @test eltype(el.d) == PrecCarrier{eltype(v.d)}
            else
                @test t == PrecCarrier{Float64}
            end
            if !(v isa CustomStruct)
                @test all(PrecDetector._no_epsilons.(precified) .== 0)
            end
        end
    end

    @testset "tuples of $(typeof(v))" for v in SOURCE_VALUES
        tuple = ntuple(_ -> v, N)
        @testset "default precify" begin
            precified = precify(tuple)

            t = eltype(precified)
            if (v isa PrecCarrier)
                @test t == typeof(v)
            elseif (v isa AbstractFloat)
                @test t == PrecCarrier{typeof(v)}
            elseif (v isa CustomStruct)
                el = precified[begin]

                @test typeof(el.a) == PrecCarrier{typeof(v.a)}
                @test typeof(el.b) == PrecCarrier{typeof(v.b)}
                @test eltype(el.c) == PrecCarrier{eltype(v.c)}
                @test eltype(el.d) == PrecCarrier{eltype(v.d)}
            else
                @test t == PrecCarrier{Float64}
            end
            if !(v isa CustomStruct)
                @test all(PrecDetector._no_epsilons.(precified) .== 0)
            end
        end
    end
end

@testset "unimplemented precify" begin
    @test_throws "no precify is implemented for type PrecifyUnimplemented" precify(PrecifyUnimplemented())
end
