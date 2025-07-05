PREC_TYPES = [PrecCarrier{Float16}, PrecCarrier{Float32}, PrecCarrier{Float64}]
TEST_VALUES = [
    0.0,
    1.0,
    Inf,
    -Inf,
    -0.0,
    NaN,
    1.0e4,
    1.0e-6,   # subnormal in fp16
]

@testset "$P" for P in PREC_TYPES
    FLOAT_T = PrecDetector._float_type(P)

    @testset "unary comparisons" begin
        for v in FLOAT_T.(TEST_VALUES)
            p = P(v)

            @test iszero(v) == iszero(p)
            @test isone(v) == isone(p)
            @test ispow2(v) == ispow2(p)
            @test isfinite(v) == isfinite(p)
            @test isnan(v) == isnan(p)
            @test isinteger(v) == isinteger(p)
            @test iseven(v) == iseven(p)
            @test isodd(v) == isodd(p)
            @test issubnormal(v) == issubnormal(p)

            @test eps(FLOAT_T) == eps(P)

            if (isnan(eps(v)))   # if eps(v) is NaN, eps(p) is NaN, and NaN != NaN
                @test isnan(eps(p))
                @test typeof(eps(p)) == FLOAT_T
            else
                @test eps(v) == eps(p)
            end
        end
    end

    @testset "binary comparisons" begin
        # ignore the fp16 subnormal number here, it leads to inequalities
        for x1 in TEST_VALUES[1:(end - 1)], x2 in TEST_VALUES[1:(end - 1)]
            for (v1, v2) in [ # test interoperability with non PrecCarrier values
                    (FLOAT_T(x1), FLOAT_T(x2)),
                    (FLOAT_T(x1), x2),
                    (x1, FLOAT_T(x2)),
                ]
                for (pv1, pv2) in [
                        (P(v1), P(v2)),
                        (P(v1), v2),
                        (v1, P(v2)),
                    ]
                    @test (v1 == v2) == (pv1 == pv2)
                    @test (v1 != v2) == (pv1 != pv2)
                    @test (v1 < v2) == (pv1 < pv2)
                    @test (v1 <= v2) == (pv1 <= pv2)
                    @test (v1 > v2) == (pv1 > pv2)
                    @test (v1 >= v2) == (pv1 >= pv2)

                    @test isapprox(v1, v2) == isapprox(pv1, pv2)
                end
            end
        end
    end
end
