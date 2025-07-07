using Random

PREC_TYPES = [PrecisionCarrier, PrecisionCarrier{Float16}, PrecisionCarrier{Float32}, PrecisionCarrier{Float64}]

RNG_F = MersenneTwister(1)
RNG_P = MersenneTwister(1)

@testset "random $P" for P in PREC_TYPES
    F = eltype(P)

    random_p = rand(RNG_P, P)
    @test isapprox(random_p, rand(RNG_F, F))
    @test eltype(random_p) == F
end
