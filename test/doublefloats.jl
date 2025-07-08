# load DoubleFloatsExt
using DoubleFloats

FLOAT_TYPES = [Float16, Float32, Float64]
DFLOAT_TYPES = [Double16, Double32, Double64]

@testset "P{$F}" for F in cat(FLOAT_TYPES, DFLOAT_TYPES; dims = 1)
    @testset "DoubleFloat $DF" for DF in DFLOAT_TYPES
        @testset "convert from PrecisionCarrier{$F} to $DF, for $v" for v in [0.1, 1.0, rand(), rand()]
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
end
