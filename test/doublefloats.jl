# load DoubleFloatsExt
using DoubleFloats
using Random

FLOAT_TYPES = [Float16, Float32, Float64]
DFLOAT_TYPES = [Double16, Double32, Double64]

RNG = MersenneTwister(0)

@testset "P{$F}" for F in cat(FLOAT_TYPES, DFLOAT_TYPES; dims = 1)
    @testset "DoubleFloat $DF" for DF in DFLOAT_TYPES
        @testset "convert from PrecisionCarrier{$F} to $DF, for $v" for v in [0.1, 1.0, rand(RNG), rand(RNG)]
            # conversion is overloaded to remain at stable PrecisionCarrier types inside calculations
            # but the internal float type is converted
            p = PrecisionCarrier{F}(v)
            pc = convert(DF, p)

            @test typeof(pc) == PrecisionCarrier{DF}
            @test isapprox(pc, v; rtol = max(eps(F), eps(DF)))

            # "constructor" call
            pc = DF(p)
            @test typeof(pc) == PrecisionCarrier{DF}
            @test isapprox(pc, v; rtol = max(eps(F), eps(DF)))
        end
    end

    @testset "convert from PrecisionCarrier{$F} to DoubleFloat, for $v" for v in [0.1, 1.0, rand(RNG), rand(RNG)]
        p = PrecisionCarrier{F}(v)
        pc = convert(DoubleFloat, p)

        _double(::Type{DoubleFloat{T}}) where {T} = DoubleFloat{T}
        _double(::Type{T}) where {T} = DoubleFloat{T}

        @test typeof(pc) == PrecisionCarrier{_double(F)}
        @test isapprox(pc, v; rtol = eps(F))

        # "constructor" call
        pc = DoubleFloat(p)
        @test typeof(pc) == PrecisionCarrier{_double(F)}
        @test isapprox(pc, v; rtol = eps(F))
    end
end
