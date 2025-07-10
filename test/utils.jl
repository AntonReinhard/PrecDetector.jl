FLOAT_TYPES = [Float16, Float32, Float64]

@testset "float type $F" for F in FLOAT_TYPES
    @testset "epsilons" begin
        p = one(PrecisionCarrier{F})

        @test epsilons(p) == 0

        # As a user, do *not* use this constructor!
        p = PrecisionCarrier(one(F), big(1.0 + 1.0e-5))

        @test epsilons(p) == round(Int, 1.0e-5 / eps(F))

        @test epsilons(precify(F(Inf))) == 0
        @test epsilons(precify(F(-Inf))) == 0
        @test epsilons(precify(F(NaN))) == 0

        # test some edge cases
        @test epsilons(PrecisionCarrier{F}(0, big(0.0))) == 0
        @test epsilons(PrecisionCarrier{F}(0, big(1.0))) == typemax(Int)
        @test epsilons(PrecisionCarrier{F}(Inf, big(1.0))) == typemax(Int)
        @test epsilons(PrecisionCarrier{F}(-Inf, big(1.0))) == typemax(Int)
        @test epsilons(PrecisionCarrier{F}(NaN, big(1.0))) == typemax(Int)
        @test epsilons(PrecisionCarrier{F}(Inf, big(-Inf))) == typemax(Int)
        @test epsilons(PrecisionCarrier{F}(-Inf, big(Inf))) == typemax(Int)
        @test epsilons(PrecisionCarrier{F}(Inf, big(NaN))) == typemax(Int)
        @test epsilons(PrecisionCarrier{F}(-Inf, big(NaN))) == typemax(Int)
        @test epsilons(PrecisionCarrier{F}(NaN, big(Inf))) == typemax(Int)
        @test epsilons(PrecisionCarrier{F}(NaN, big(-Inf))) == typemax(Int)
    end

    @testset "significant_digits" begin
        p = one(PrecisionCarrier{F})

        total_sig_digits = -log10(eps(F))

        @test isapprox(significant_digits(p), total_sig_digits)

        # As a user, do *not* use this constructor!
        p = PrecisionCarrier(one(F), big(1.0 + 1.0e-2))

        # need to use a fairly large error here because Float16 only carries ~3
        # significant digits total

        @test isapprox(significant_digits(p), 2)

        # test some edge cases
        @test significant_digits(PrecisionCarrier{F}(0, big(0.0))) == total_sig_digits
        @test significant_digits(PrecisionCarrier{F}(0, big(1.0))) == 0.0
        @test significant_digits(PrecisionCarrier{F}(Inf, big(1.0))) == 0.0
        @test significant_digits(PrecisionCarrier{F}(-Inf, big(1.0))) == 0.0
        @test significant_digits(PrecisionCarrier{F}(NaN, big(1.0))) == 0.0
        @test significant_digits(PrecisionCarrier{F}(Inf, big(-Inf))) == 0.0
        @test significant_digits(PrecisionCarrier{F}(-Inf, big(Inf))) == 0.0
        @test significant_digits(PrecisionCarrier{F}(Inf, big(NaN))) == 0.0
        @test significant_digits(PrecisionCarrier{F}(-Inf, big(NaN))) == 0.0
        @test significant_digits(PrecisionCarrier{F}(NaN, big(Inf))) == 0.0
        @test significant_digits(PrecisionCarrier{F}(NaN, big(-Inf))) == 0.0
    end

    @testset "reset_eps" begin
        # As a user, do *not* use this constructor!
        p = PrecisionCarrier(one(F), big(1.0 + 1.0e-2))

        reset_eps!(p)

        @test epsilons(p) == 0
        @test isapprox(significant_digits(p), -log10(eps(F)))

        @testset "$(N)D array" for N in (1, 2, 3)
            # As a user, do *not* use this constructor!
            p = PrecisionCarrier(one(F), big(1.0 + 1.0e-2))
            array = fill(p, ntuple(_ -> 3, N))

            reset_eps!(array)

            @test all(epsilons.(array) .== 0)
        end

        @testset "$N element tuple" for N in (1, 2, 3)
            # As a user, do *not* use this constructor!
            p = PrecisionCarrier(one(F), big(1.0 + 1.0e-2))
            tuple = ntuple(_ -> p, N)

            reset_eps!(tuple)

            @test all(epsilons.(tuple) .== 0)
        end
    end

    @testset "eltype" begin
        @test eltype(PrecisionCarrier{F}) == F
        @test eltype(precify(F, 1.0)) == F
        @test eltype(PrecisionCarrier) == Float64
    end
end

@testset "type promotions" begin
    @testset "promotion with $T1 and $T2" for T1 in FLOAT_TYPES, T2 in FLOAT_TYPES
        @test promote_type(PrecisionCarrier{T1}, PrecisionCarrier{T2}) == PrecisionCarrier{promote_type(T1, T2)}
        @test promote_type(PrecisionCarrier{T1}, T2) == PrecisionCarrier{promote_type(T1, T2)}
        @test promote_type(T1, PrecisionCarrier{T2}) == PrecisionCarrier{promote_type(T1, T2)}
    end
    @testset "promotion with $T1 and $T2" for T1 in FLOAT_TYPES, T2 in [Int8, Int16, Int32, Int, UInt8, UInt16, UInt32, UInt]
        @test promote_type(T1, T2) <: AbstractFloat
        @test promote_type(PrecisionCarrier{T1}, T2) == PrecisionCarrier{promote_type(T1, T2)}
        @test promote_type(T2, PrecisionCarrier{T1}) == PrecisionCarrier{promote_type(T1, T2)}
    end
    @testset "promotion with $T1 and $T2" for T1 in FLOAT_TYPES, T2 in [Rational{Int8}, Rational{Int16}, Rational{Int32}, Rational{Int}, Rational{UInt8}, Rational{UInt16}, Rational{UInt32}, Rational{UInt}]
        @test promote_type(T1, T2) <: AbstractFloat
        @test promote_type(PrecisionCarrier{T1}, T2) == PrecisionCarrier{promote_type(T1, T2)}
        @test promote_type(T2, PrecisionCarrier{T1}) == PrecisionCarrier{promote_type(T1, T2)}
    end
    @testset "promotion with $T1 and $T2" for T1 in FLOAT_TYPES, T2 in [ComplexF16, ComplexF32, ComplexF64, Complex{Int}, Complex{Int8}, Complex{Int16}, Complex{Int32}, Complex{Int}, Complex{UInt8}, Complex{UInt16}, Complex{UInt32}, Complex{UInt}]
        @test promote_type(PrecisionCarrier{T1}, T2) == Complex{PrecisionCarrier{promote_type(T1, real(T2))}}
        @test promote_type(T2, PrecisionCarrier{T1}) == Complex{PrecisionCarrier{promote_type(T1, real(T2))}}
    end
end
