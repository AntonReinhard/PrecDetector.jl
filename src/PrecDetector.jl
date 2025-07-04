module PrecDetector

export PrecCarrier
export precify
export significant_digits
export reset_eps!

include("type.jl")
include("utils.jl")
include("macros.jl")
include("precify.jl")

include("functionality/arithmetic.jl")
include("functionality/compare.jl")
include("functionality/conversion.jl")
include("functionality/init.jl")
include("functionality/print.jl")
include("functionality/random.jl")

end # module PrecDetector
