using SafeTestsets

@safetestset "PrecCarrier conversions" begin
    include("conversions.jl")
end

@safetestset "precify" begin
    include("precify.jl")
end

@safetestset "inits" begin
    include("init.jl")
end

@safetestset "comparisons" begin
    include("comparisons.jl")
end

@safetestset "arithmetic" begin
    include("arithmetic.jl")
end

@safetestset "utils" begin
    include("utils.jl")
end

@safetestset "random" begin
    include("rand.jl")
end
