module PrecisionCarriers

using Statistics
using Printf
using ProgressMeter

export PrecisionCarrier
export precify
export significant_digits
export epsilons
export reset_eps!

export @bench_epsilons

"""
    EpsT

The integer type of epsilons, for example the return type of the 
[`epsilons`](@ref) function. `Int64` by default.
"""
const EpsT = Int64

"""
    EpsMax

The maximum representable number of epsilons. `typemax(EpsT)` by
default. If an epsilon would be larger than this value, it is shown
as "infinite" epsilons.
"""
const EpsMax = typemax(EpsT)

"""
    BigT

The backend high precision float type used by [`PrecisionCarrier`](@ref)s.
"""
const BigT = BigFloat

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
