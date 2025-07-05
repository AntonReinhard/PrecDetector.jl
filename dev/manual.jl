# # Manual

using PrecDetector

# ## Precify

# Create a [`PrecCarrier`](@ref) object from any floating point by using [`precify`](@ref):

p = precify(1.0)

# By default, precify uses the type of the given floating point:

typeof(precify(1.0f0))

#

typeof(precify(Float16(1.0)))

# One can also specify the type:

typeof(precify(Float32, 1.0))

# All of these versions also work on array and tuple types:

precify((1.0, Float32(2.0), Float16(3.0)))

# The interface can also easily be extended for custom types by dispatching
# to all relevant members:

struct A
    x::AbstractFloat
end

PrecDetector.precify(T::Type{<:PrecCarrier}, a::A) = A(precify(a.x))

precify(A(1.0))

# ## Arithmetic and Precision Estimation

# The resulting precified object can be used like a normal floating point number:

p = atan((p + 10) ^ 2 * pi)

# When displaying the result, the number of epsilons (ε) is calculated.
# It represents the number of machine precision of the underlying floating 
# point type, that it differs relative to the arbitrary precision calculation.

p = tan(p)

# The result is also color graded to draw attention to values that have precision problems.

# The number of significant digits remaining in the type can be calculated
# by using [`significant_digits`](@ref):

significant_digits(p)

# Finally, the precision carried can be reset using [`reset_eps!`](@ref):

reset_eps!(p)

#
