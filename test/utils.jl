using PrecDetector: _no_epsilons, _float_type

FLOAT_TYPES = [Float16, Float32, Float64]

@testset "float type $F" for F in FLOAT_TYPES
    @testset "_no_epsilons" begin
        p = one(PrecCarrier{F})

        @test _no_epsilons(p) == 0

        # As a user, do *not* use this constructor!
        p = PrecCarrier(one(F), big(1.0 + 1.0e-5))

        @test _no_epsilons(p) == round(Int, 1.0e-5 / eps(F))

        @test _no_epsilons(precify(F(Inf))) == 0
        @test _no_epsilons(precify(F(-Inf))) == 0
        @test _no_epsilons(precify(F(NaN))) == 0

        # test some edge cases
        @test _no_epsilons(PrecCarrier{F}(0, big(0.0))) == 0
        @test _no_epsilons(PrecCarrier{F}(0, big(1.0))) == -1
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

    @testset "significant_digits" begin
        p = one(PrecCarrier{F})

        total_sig_digits = -log10(eps(F))

        @test isapprox(significant_digits(p), total_sig_digits)

        # As a user, do *not* use this constructor!
        p = PrecCarrier(one(F), big(1.0 + 1.0e-2))

        # need to use a fairly large error here because Float16 only carries ~3
        # significant digits total

        @test isapprox(significant_digits(p), 2)

        # test some edge cases
        @test significant_digits(PrecCarrier{F}(0, big(0.0))) == total_sig_digits
        @test significant_digits(PrecCarrier{F}(0, big(1.0))) == 0.0
        @test significant_digits(PrecCarrier{F}(Inf, big(1.0))) == 0.0
        @test significant_digits(PrecCarrier{F}(-Inf, big(1.0))) == 0.0
        @test significant_digits(PrecCarrier{F}(NaN, big(1.0))) == 0.0
        @test significant_digits(PrecCarrier{F}(Inf, big(-Inf))) == 0.0
        @test significant_digits(PrecCarrier{F}(-Inf, big(Inf))) == 0.0
        @test significant_digits(PrecCarrier{F}(Inf, big(NaN))) == 0.0
        @test significant_digits(PrecCarrier{F}(-Inf, big(NaN))) == 0.0
        @test significant_digits(PrecCarrier{F}(NaN, big(Inf))) == 0.0
        @test significant_digits(PrecCarrier{F}(NaN, big(-Inf))) == 0.0
    end

    @testset "reset_eps" begin
        # As a user, do *not* use this constructor!
        p = PrecCarrier(one(F), big(1.0 + 1.0e-2))

        reset_eps!(p)

        @test _no_epsilons(p) == 0
        @test isapprox(significant_digits(p), -log10(eps(F)))

        @testset "$(N)D array" for N in (1, 2, 3)
            # As a user, do *not* use this constructor!
            p = PrecCarrier(one(F), big(1.0 + 1.0e-2))
            array = fill(p, ntuple(_ -> 3, N))

            reset_eps!(array)

            @test all(_no_epsilons.(array) .== 0)
        end

        @testset "$N element tuple" for N in (1, 2, 3)
            # As a user, do *not* use this constructor!
            p = PrecCarrier(one(F), big(1.0 + 1.0e-2))
            tuple = ntuple(_ -> p, N)

            reset_eps!(tuple)

            @test all(_no_epsilons.(tuple) .== 0)
        end
    end

    @testset "_float_type" begin
        @test _float_type(PrecCarrier{F}) == F
        @test _float_type(precify(F, 1.0)) == F
        @test _float_type(PrecCarrier) == Float64
        @test eltype(precify(F, 1.0)) == F
    end
end
