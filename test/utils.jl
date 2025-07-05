using PrecDetector

using PrecDetector: _no_epsilons

FLOAT_TYPES = [Float16, Float32, Float64]

@testset "_no_epsilons of PrecCarrier{$F}" for F in FLOAT_TYPES
    p = one(PrecCarrier{F})

    @test _no_epsilons(p) == 0

    # As a user, do *not* use this constructor!
    p = PrecCarrier(one(F), big(1.0 + 1.0e-5))

    @test _no_epsilons(p) == round(Int, 1.0e-5 / eps(F))

    @test _no_epsilons(precify(F(Inf))) == 0
    @test _no_epsilons(precify(F(-Inf))) == 0
    @test _no_epsilons(precify(F(NaN))) == 0

    # test some edge cases
    @test _no_epsilons(PrecCarrier{F}(Inf, big(1.0))) == -1
    @test _no_epsilons(PrecCarrier{F}(-Inf, big(1.0))) == -1
    @test _no_epsilons(PrecCarrier{F}(NaN, big(1.0))) == -1
    @test _no_epsilons(PrecCarrier{F}(Inf, big(-Inf))) == -1
    @test _no_epsilons(PrecCarrier{F}(-Inf, big(Inf))) == -1
    @test _no_epsilons(PrecCarrier{F}(Inf, big(NaN))) == -1
    @test _no_epsilons(PrecCarrier{F}(-Inf, big(NaN))) == -1
    @test _no_epsilons(PrecCarrier{F}(NaN, big(Inf))) == -1
    @test _no_epsilons(PrecCarrier{F}(NaN, big(-Inf))) == -1
end

@testset "significant_digits of PrecCarrier{$F}" for F in FLOAT_TYPES
    p = one(PrecCarrier{F})

    @test isapprox(significant_digits(p), -log10(eps(F)))

    # As a user, do *not* use this constructor!
    p = PrecCarrier(one(F), big(1.0 + 1.0e-2))

    # need to use a fairly large error here because Float16 only carries ~3
    # significant digits total

    @test isapprox(significant_digits(p), 2)
end

@testset "reset_eps of PrecCarrier{$F}" for F in FLOAT_TYPES
    # As a user, do *not* use this constructor!
    p = PrecCarrier(one(F), big(1.0 + 1.0e-2))

    reset_eps!(p)

    @test _no_epsilons(p) == 0
    @test isapprox(significant_digits(p), -log10(eps(F)))
end
