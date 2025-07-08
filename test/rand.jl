using Random

PREC_TYPES = [PrecisionCarrier, PrecisionCarrier{Float16}, PrecisionCarrier{Float32}, PrecisionCarrier{Float64}]

RNG_F = MersenneTwister(1)
RNG_P = MersenneTwister(1)

@testset "random $P" for P in PREC_TYPES
    F = eltype(P)

    random_p = rand(RNG_P, P)
    random_f = rand(RNG_F, F)

    @test isapprox(random_p, random_f)
    @test eltype(random_p) == F
end

RNG_F = MersenneTwister(1)
RNG_P = MersenneTwister(1)

@testset "random vector $P" for P in PREC_TYPES
    F = eltype(P)

    random_p = rand(RNG_P, P, 10)
    random_f = rand(RNG_F, F, 10)

    @test all(isapprox.(random_p, random_f))
    @test eltype(eltype(random_p)) == F

    random_p = rand(RNG_P, P, (10, 10))
    random_f = rand(RNG_F, F, (10, 10))

    @test all(isapprox.(random_p, random_f))
    @test eltype(eltype(random_p)) == F
end
