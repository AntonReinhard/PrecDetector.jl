PREC_TYPES = [PrecCarrier, PrecCarrier{Float16}, PrecCarrier{Float32}, PrecCarrier{Float64}]

@testset "ones of $P" for P in PREC_TYPES
    @test isone(one(P))
    if (P == PrecCarrier)
        @test typeof(one(P)) == PrecCarrier{Float64}
    else
        @test typeof(one(P)) == P
    end
end

@testset "zeros of $P" for P in PREC_TYPES
    @test iszero(zero(P))
    if (P == PrecCarrier)
        @test typeof(zero(P)) == PrecCarrier{Float64}
    else
        @test typeof(zero(P)) == P
    end
end
