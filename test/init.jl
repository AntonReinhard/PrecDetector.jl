PREC_TYPES = [PrecisionCarrier, PrecisionCarrier{Float16}, PrecisionCarrier{Float32}, PrecisionCarrier{Float64}]

@testset "ones of $P" for P in PREC_TYPES
    @test isone(one(P))
    if (P == PrecisionCarrier)
        @test typeof(one(P)) == PrecisionCarrier{Float64}
    else
        @test typeof(one(P)) == P
    end
end

@testset "zeros of $P" for P in PREC_TYPES
    @test iszero(zero(P))
    if (P == PrecisionCarrier)
        @test typeof(zero(P)) == PrecisionCarrier{Float64}
    else
        @test typeof(zero(P)) == P
    end
end
