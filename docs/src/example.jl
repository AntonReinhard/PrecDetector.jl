# # Usage Example

# Suppose we have the problem of computing the square root of the positive difference of two squares,
# x and y. The formula is simple: $$\sqrt{\left|x^2 - y^2\right|}$$. Let's write it in julia:

f(x, y) = sqrt(abs(x^2 - y^2))

f(5, 4)

# So far so good. Now what happens when $$x$$ and $$y$$ have almost equal values?

f(3.0 + 1.0e-7, 3.0)

# Compare that with a result in arbitrary precision:

f(big(3.0 + 1.0e-7), big(3.0))

# Clearly, not all of the supposed ca. 15 digits that the `Float64` result carries are correct.
# Let's see what `PrecDetector` says:

using PrecDetector
p = f(precify(3.0 + 1.0e-7), precify(3.0))
#
significant_digits(p)

# It looks like we lost about 5 significant digits! This happens because of the intermediate
# results of $$x^2$$ and $$y^2$$ do not carry enough precision to accurately calculate their
# difference. This is often called "catastrophic cancellation", because the two values are
# almost equal, so many of the most-significant bits are "cancelled".

# In this instance, we can resolve the problem for most cases by replacing $$x^2 - y^2$$
# with its binomial representation $$(x + y) * (x - y)$$. This reduces the instability
# of the intermediate values:

f_improved(x, y) = sqrt(abs((x + y) * (x - y)))
p = f_improved(precify(3.0 + 1.0e-7), precify(3.0))
#
significant_digits(p)

# We can now also easily visualize the precision loss of either version by plotting the
# significant digits on an x-y-plane:

using CairoMakie

x = 1.0:1.0e-6:(1.0 + 1.0e-4)
y = 1.0:1.0e-6:(1.0 + 1.0e-4)

contourf(x, y, (x, y) -> significant_digits(f(precify(x), precify(y))))

# With a little more effort we can compare the two versions on some values:

fig = Figure()

z1 = [significant_digits(f(precify(xi), precify(yi))) for yi in y, xi in x]
z2 = [significant_digits(f_improved(precify(xi), precify(yi))) for yi in y, xi in x]

zmin = floor(Int64, min(minimum(z1), minimum(z2)))
zmax = ceil(Int64, max(maximum(z1), maximum(z2)))

ax1 = Axis(fig[1, 1]; aspect = AxisAspect(1), title = "Original f", xticksvisible = false, yticksvisible = false, xticklabelsvisible = false, yticklabelsvisible = false)
ax2 = Axis(fig[1, 2]; aspect = AxisAspect(1), title = "Improved f", xticksvisible = false, yticksvisible = false, xticklabelsvisible = false, yticklabelsvisible = false)

contour1 = contourf!(ax1, x, y, z1; levels = range(zmin, zmax))
contour2 = contourf!(ax2, x, y, z2; levels = range(zmin, zmax))

Colorbar(fig[1, 3], contour1; label = "Significant Digits")

fig
