module PrecisionCarriers

using Statistics
using Printf
using DataStructures
using ProgressMeter

export PrecisionCarrier
export precify
export significant_digits
export epsilons
export reset_eps!

export @bench_epsilons

include("type.jl")
include("utils.jl")
include("macros.jl")
include("precify.jl")

include("functionality/arithmetic.jl")
include("functionality/compare.jl")
include("functionality/conversion.jl")
include("functionality/init.jl")
include("functionality/print.jl")

include("bench/utils.jl")
include("bench/result.jl")
include("bench/macros.jl")
include("bench/print.jl")

end # module PrecisionCarriers
