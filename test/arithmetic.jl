PREC_TYPES = [PrecisionCarrier{Float16}, PrecisionCarrier{Float32}, PrecisionCarrier{Float64}]
TEST_VALUES = [
    0.0,
    1.0,
    Inf,
    -Inf,
    -0.0,
    NaN,
]

UNARY_OPS = [
    +, -, abs, sqrt, cbrt, exp, expm1, log,
    log2, log10, log1p, exponent, significand,
    sign, eps,
    sin, cos, tan, cot, sec, csc,               # "normal"
    sinh, cosh, tanh, coth, sech, csch,         # hyperbolic
    asin, acos, atan, acot, asec, acsc,         # arc
    asinh, acosh, atanh, acoth, asech, acsch,   # arc hyperbolic
    sinc, cosc,                                 # normalized
    sind, cosd, tand, cotd, secd, cscd,         # radians versions
    asind, acosd, atand, acotd, asecd, acscd,   # radians arc versions
    cis, sinpi, cospi,                          # other
]

BINARY_OPS = [
    +, -, *, /, \, ^, min, max,
    hypot, log, ldexp, sincos,
    flipsign, copysign,
]

TYPE_OPS = [
    maxintfloat, typemin, typemax, floatmin,
    floatmax, eps, precision,
]

@testset "$P" for P in PREC_TYPES
    FLOAT_T = eltype(P)

    @testset "$op" for op in UNARY_OPS
        for v in FLOAT_T.(TEST_VALUES)
            p = P(v)

            try
                op(v)
                @test isapprox(op(v), op(p)) || (isnan(op(v)) && isnan(op(p)))
            catch e
                @test_throws e op(p)
            end
        end
    end

    @testset "$op" for op in TYPE_OPS
        # can use proper == here instead of isapprox
        @test op(P) == op(eltype(P))
        @test epsilons(op(P)) == 0
    end

    @testset "sincos" begin
        for v in FLOAT_T.(TEST_VALUES)
            p = P(v)

            try
                sincos(v)
                @test isapprox(sincos(v)[1], sincos(p)[1]) || (isnan(sincos(v)[1]) && isnan(sincos(p)[1]))
                @test isapprox(sincos(v)[2], sincos(p)[2]) || (isnan(sincos(v)[2]) && isnan(sincos(p)[2]))
            catch e
                @test_throws e sincos(p)
            end
        end

        @test_throws DomainError(Inf, "sincos(x) is only defined for finite x.") sincos(PrecisionCarrier{FLOAT_T}(1.0, big(Inf)))
    end

    @testset "rounding functions" begin
        for v in FLOAT_T.(TEST_VALUES)
            p = P(v)

            if isfinite(v) && !isnan(v)
                @testset "round to $INT_T" for INT_T in [Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64]
                    @test round(INT_T, v) == round(INT_T, p)
                    @test floor(INT_T, v) == floor(INT_T, p)
                    @test ceil(INT_T, v) == ceil(INT_T, p)
                    @test trunc(INT_T, v) == trunc(INT_T, p)
                end
            end


            if (VERSION >= v"1.11")
                @testset "round to $FLOAT_T" for FLOAT_T in [Float16, Float32, Float64]
                    @test isapprox(round(FLOAT_T, v), round(FLOAT_T, p)) || isnan(round(FLOAT_T, v)) && isnan(round(FLOAT_T, p))
                    @test typeof(round(FLOAT_T, p)) == PrecisionCarrier{FLOAT_T}

                    @test isapprox(floor(FLOAT_T, v), floor(FLOAT_T, p)) || isnan(floor(FLOAT_T, v)) && isnan(floor(FLOAT_T, p))
                    @test typeof(floor(FLOAT_T, p)) == PrecisionCarrier{FLOAT_T}

                    @test isapprox(ceil(FLOAT_T, v), ceil(FLOAT_T, p)) || isnan(ceil(FLOAT_T, v)) && isnan(ceil(FLOAT_T, p))
                    @test typeof(ceil(FLOAT_T, p)) == PrecisionCarrier{FLOAT_T}

                    @test isapprox(trunc(FLOAT_T, v), trunc(FLOAT_T, p)) || isnan(trunc(FLOAT_T, v)) && isnan(trunc(FLOAT_T, p))
                    @test typeof(trunc(FLOAT_T, p)) == PrecisionCarrier{FLOAT_T}
                end
            end
        end
    end


end
