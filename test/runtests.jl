using TestItemRunner
using TestItems

@run_package_tests

@testitem "PrecisionCarrier conversions" begin
    include("conversions.jl")
end

@testitem "precify" begin
    include("precify.jl")
end

@testitem "inits" begin
    include("init.jl")
end

@testitem "comparisons" begin
    include("comparisons.jl")
end

@testitem "arithmetic" begin
    include("arithmetic.jl")
end

@testitem "utils" begin
    include("utils.jl")
end

@testitem "printing" begin
    include("print.jl")
end

@testitem "random" begin
    include("rand.jl")
end

@testitem "doublefloats" begin
    include("doublefloats.jl")
end

@testitem "bench/utils" begin
    include("bench/utils.jl")
end

@testitem "bench/print" begin
    include("bench/print.jl")
end

@testitem "bench/topklist" begin
    include("bench/topklist.jl")
end

@testitem "bench/macros.jl" begin
    include("bench/macros.jl")
end
