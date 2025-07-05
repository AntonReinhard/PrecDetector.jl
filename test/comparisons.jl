using PrecDetector

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
            @test iszero(v) == iszero(P(v))
            @test isone(v) == isone(P(v))
            @test ispow2(v) == ispow2(P(v))
            @test isfinite(v) == isfinite(P(v))
            @test isnan(v) == isnan(P(v))
            @test isinteger(v) == isinteger(P(v))
            @test iseven(v) == iseven(P(v))
            @test isodd(v) == isodd(P(v))
            @test issubnormal(v) == issubnormal(P(v))
        end
    end

    @testset "binary comparisons" begin
        for v1 in FLOAT_T.(TEST_VALUES), v2 in FLOAT_T.(TEST_VALUES)
            pv1 = P(v1)
            pv2 = P(v2)
            @test (v1 == v2) == (pv1 == pv2)
            @test (v1 != v2) == (pv1 != pv2)
            @test (v1 < v2) == (pv1 < pv2)
            @test (v1 <= v2) == (pv1 <= pv2)
            @test (v1 > v2) == (pv1 > pv2)
            @test (v1 >= v2) == (pv1 >= pv2)
        end
    end
end
