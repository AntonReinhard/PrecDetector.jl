using SafeTestsets

@safetestset "PrecCarrier conversions" begin
    include("conversions.jl")
end

@safetestset "precify" begin
    include("precify.jl")
end

@safetestset "comparisons" begin
    include("comparisons.jl")
end

@safetestset "inits" begin
    include("init.jl")
end
