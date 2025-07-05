using PrecDetector
using Random

PREC_TYPES = [PrecCarrier, PrecCarrier{Float16}, PrecCarrier{Float32}, PrecCarrier{Float64}]

RNG_F = MersenneTwister(1)
RNG_P = MersenneTwister(1)

@testset "random $P" for P in PREC_TYPES
    F = PrecDetector._float_type(P)

    random_p = rand(RNG_P, P)
    @test isapprox(random_p, rand(RNG_F, F))
    @test eltype(random_p) == F
end
