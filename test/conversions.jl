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
]

@testset "converting $(typeof(v)): $v" for v in SOURCE_VALUES
    @testset "default conversion" begin
        p = convert(PrecCarrier, v)
        t = typeof(p)
        if (v isa PrecCarrier)
            @test t == typeof(v)
        elseif (v isa AbstractFloat)
            @test t == PrecCarrier{typeof(v)}
        else
            @test t == PrecCarrier{Float64}
        end
        @test PrecDetector._no_epsilons(p) == 0
    end

    @testset "default constructor" begin
        p = PrecCarrier(v)
        t = typeof(p)
        if (v isa PrecCarrier)
            @test t == typeof(v)
        elseif (v isa AbstractFloat)
            @test t == PrecCarrier{typeof(v)}
        else
            @test t == PrecCarrier{Float64}
        end
        @test PrecDetector._no_epsilons(p) == 0
    end

    @testset "conversion to PrecCarrier{$F}" for F in FLOAT_TYPES
        p = convert(PrecCarrier{F}, v)
        @test typeof(p) == PrecCarrier{F}
        @test PrecDetector._no_epsilons(p) == 0
    end

    @testset "typed constructor PrecCarrier{$F}" for F in FLOAT_TYPES
        p = PrecCarrier{F}(v)
        @test typeof(p) == PrecCarrier{F}
        @test PrecDetector._no_epsilons(p) == 0
    end

    @testset "invalid conversion to PrecCarrier{$F}" for F in INVALID_FLOAT_TYPES
        @test_throws AssertionError("can not create a PrecCarrier with $F") convert(PrecCarrier{F}, v)
    end

    @testset "invalid typed constructor PrecCarrier{$F}" for F in INVALID_FLOAT_TYPES
        @test_throws AssertionError("can not create a PrecCarrier with $F") PrecCarrier{F}(v)
    end

    @testset "convert from PrecCarrier{$F1} to $F2" for F1 in FLOAT_TYPES, F2 in FLOAT_TYPES
        # conversion is overloaded to remain at stable PrecCarrier types inside calculations
        # but the internal float type is converted
        p = PrecCarrier{F1}(v)
        pc = convert(F2, p)

        @test typeof(pc) == PrecCarrier{F2}
        @test isapprox(pc, v; rtol = max(eps(F1), eps(F2)))
    end
end
