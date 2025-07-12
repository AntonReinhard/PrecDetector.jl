FLOAT_TYPES = [Float16, Float32, Float64]
INVALID_FLOAT_TYPES = [
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
]

@testset "converting $(typeof(v)): $v" for v in SOURCE_VALUES
    @testset "default conversion" begin
        p = convert(PrecisionCarrier, v)
        t = typeof(p)
        if (v isa PrecisionCarrier)
            @test t == typeof(v)
        elseif (v isa AbstractFloat)
            @test t == PrecisionCarrier{typeof(v)}
        else
            @test t == PrecisionCarrier{Float64}
        end
        @test epsilons(p) == 0
    end

    @testset "default constructor" begin
        p = PrecisionCarrier(v)
        t = typeof(p)
        if (v isa PrecisionCarrier)
            @test t == typeof(v)
        elseif (v isa AbstractFloat)
            @test t == PrecisionCarrier{typeof(v)}
        else
            @test t == PrecisionCarrier{Float64}
        end
        @test epsilons(p) == 0
    end

    @testset "conversion to PrecisionCarrier{$F}" for F in FLOAT_TYPES
        p = convert(PrecisionCarrier{F}, v)
        @test typeof(p) == PrecisionCarrier{F}
        @test epsilons(p) == 0
    end

    @testset "typed constructor PrecisionCarrier{$F}" for F in FLOAT_TYPES
        p = PrecisionCarrier{F}(v)
        @test typeof(p) == PrecisionCarrier{F}
        @test epsilons(p) == 0
    end

    @testset "invalid conversion to PrecisionCarrier{$F}" for F in INVALID_FLOAT_TYPES
        @test_throws AssertionError("can not create a PrecisionCarrier with $F") convert(PrecisionCarrier{F}, v)
    end

    @testset "invalid typed constructor PrecisionCarrier{$F}" for F in INVALID_FLOAT_TYPES
        @test_throws AssertionError("can not create a PrecisionCarrier with $F") PrecisionCarrier{F}(v)
    end

    @testset "convert from PrecisionCarrier{$F1} to $F2" for F1 in FLOAT_TYPES, F2 in FLOAT_TYPES
        # conversion is overloaded to remain at stable PrecisionCarrier types inside calculations
        # but the internal float type is converted
        p = PrecisionCarrier{F1}(v)
        pc = convert(F2, p)

        @test typeof(pc) == PrecisionCarrier{F2}
        @test isapprox(pc, v; rtol = max(eps(F1), eps(F2)))

        # "constructor" call
        pc = F2(p)
        @test typeof(pc) == PrecisionCarrier{F2}
        @test isapprox(pc, v; rtol = max(eps(F1), eps(F2)))
    end
end

@testset "promote BigFloat carrier" begin
    p = precify(big(1.0))
    p = p * 5
    @test typeof(p) == PrecisionCarrier{BigFloat}
end
