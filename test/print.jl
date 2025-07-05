FLOAT_TYPES = [Float16, Float32, Float64]

@testset "print (PrecCarrier{$F})" for F in FLOAT_TYPES
    buf = IOBuffer()

    @testset "NaN" begin
        p = PrecCarrier{F}(NaN)
        print(buf, p)
        @test String(take!(buf)) == "NaN <ε=0>"

        p = PrecCarrier{F}(NaN, 0.0)
        print(buf, p)
        @test String(take!(buf)) == "NaN <ε=Inf>"

        p = PrecCarrier{F}(0.0, NaN)
        print(buf, p)
        @test String(take!(buf)) == "0.0 <ε=Inf>"
    end

    @testset "Inf" begin
        p = PrecCarrier{F}(Inf)
        print(buf, p)
        @test String(take!(buf)) == "Inf <ε=0>"

        p = PrecCarrier{F}(-Inf)
        print(buf, p)
        @test String(take!(buf)) == "-Inf <ε=0>"

        p = PrecCarrier{F}(Inf, 0.0)
        print(buf, p)
        @test String(take!(buf)) == "Inf <ε=Inf>"

        p = PrecCarrier{F}(0.0, Inf)
        print(buf, p)
        @test String(take!(buf)) == "0.0 <ε=Inf>"

        p = PrecCarrier{F}(-Inf, 0.0)
        print(buf, p)
        @test String(take!(buf)) == "-Inf <ε=Inf>"

        p = PrecCarrier{F}(0.0, -Inf)
        print(buf, p)
        @test String(take!(buf)) == "0.0 <ε=Inf>"
    end

    @testset "Zeros" begin
        p = PrecCarrier{F}(0.0, 0.0)
        print(buf, p)
        @test String(take!(buf)) == "0.0 <ε=0>"

        p = PrecCarrier{F}(-0.0, 0.0)
        print(buf, p)
        @test String(take!(buf)) == "-0.0 <ε=0>"

        p = PrecCarrier{F}(0.0, -0.0)
        print(buf, p)
        @test String(take!(buf)) == "0.0 <ε=0>"

        p = PrecCarrier{F}(-0.0, -0.0)
        print(buf, p)
        @test String(take!(buf)) == "-0.0 <ε=0>"

        p = PrecCarrier{F}(0.0, 1.0)
        print(buf, p)
        @test String(take!(buf)) == "0.0 <ε=Inf>"

        p = PrecCarrier{F}(-0.0, 1.0)
        print(buf, p)
        @test String(take!(buf)) == "-0.0 <ε=Inf>"

        p = PrecCarrier{F}(0.0, -1.0)
        print(buf, p)
        @test String(take!(buf)) == "0.0 <ε=Inf>"

        p = PrecCarrier{F}(-0.0, -1.0)
        print(buf, p)
        @test String(take!(buf)) == "-0.0 <ε=Inf>"

        p = PrecCarrier{F}(1.0, 0.0)
        print(buf, p)
        @test String(take!(buf)) == "1.0 <ε=$(round(Int64, 1 / eps(F)))>"

        p = PrecCarrier{F}(1.0, -0.0)
        print(buf, p)
        @test String(take!(buf)) == "1.0 <ε=$(round(Int64, 1 / eps(F)))>"

        p = PrecCarrier{F}(-1.0, 0.0)
        print(buf, p)
        @test String(take!(buf)) == "-1.0 <ε=$(round(Int64, 1 / eps(F)))>"

        p = PrecCarrier{F}(-1.0, -0.0)
        print(buf, p)
        @test String(take!(buf)) == "-1.0 <ε=$(round(Int64, 1 / eps(F)))>"
    end

    @testset "Other" begin
        p = PrecCarrier{F}(1.0, 1.0 + 5 * eps(F))
        print(buf, p)
        @test String(take!(buf)) == "1.0 <ε=5>"

        p = PrecCarrier{F}(1.0, 1.0 + 15 * eps(F))
        print(buf, p)
        @test String(take!(buf)) == "1.0 <ε=15>"

        p = PrecCarrier{F}(1.0, 1.0 + 500 * eps(F))
        print(buf, p)
        @test String(take!(buf)) == "1.0 <ε=500>"

        p = PrecCarrier{F}(1.0, 1.0 + 1500 * eps(F))
        print(buf, p)
        @test String(take!(buf)) == "1.0 <ε=1500>"
    end
end
