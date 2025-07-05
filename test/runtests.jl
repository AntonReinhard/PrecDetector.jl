using SafeTestsets

@safetestset "PrecCarrier conversions" begin
    include("conversions.jl")
end

@safetestset "precify" begin
    include("precify.jl")
end
