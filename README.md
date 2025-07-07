# PrecisionCarriers.jl

[![tests](https://github.com/AntonReinhard/PrecisionCarriers.jl/actions/workflows/unit_tests.yml/badge.svg)](https://github.com/AntonReinhard/PrecisionCarriers.jl/actions/workflows/unit_tests.yml)
[![codecov](https://codecov.io/gh/AntonReinhard/PrecisionCarriers.jl/graph/badge.svg?token=HUVC6SZC0R)](https://codecov.io/gh/AntonReinhard/PrecisionCarriers.jl)
[![docs](https://img.shields.io/badge/docs-dev-blue.svg)](https://AntonReinhard.github.io/PrecisionCarriers.jl/dev/)
[![code style: runic](https://img.shields.io/badge/code_style-%E1%9A%B1%E1%9A%A2%E1%9A%BE%E1%9B%81%E1%9A%B2-black)](https://github.com/fredrikekre/Runic.jl)

This is a package to find imprecisions in chains of arithmetic functions.

## How it Works

This package provides a new type, `PrecisionCarrier{T}`, which holds both a standard floating point type, and an arbitrary precision `BigFloat`. Basic arithmetic, trigonometric, and comparison functions are overloaded for this type and always work on both the basic and the arbitrary precision type. When some computations have been done, the values may (or may not) diverge, and the extent of the accumulated precision loss can be evaluated.

This is *not* a package to directly increase the precision of your calculations. It is only intended to find the issues. To improve precision, you can use higher precision types, use arbitrary precision packages, or rearrange terms to be more numerically stable.

## Usage

A floating point number can simply be wrapped in the custom type by calling `precify` on it. This also works for tuples and arrays, and custom types if an implementation is provided for it. The resulting `PrecisionCarrier` object can then be used like any `AbstractFloat` type in most cases. Finally, with `significant_digits`, the number of remaining significant digits in the variable can be queried.

```julia
using PrecisionCarriers

# example function from Prof. Kahan: https://people.eecs.berkeley.edu/~wkahan/WrongR.pdf
function unstable(x, N)
    y = abs(x)
    for i in 1:N y = sqrt(y) end
    w = y
    for i in 1:N w = w^2 end
    return w
end

p = precify(1.5)

significant_digits(p) # -> 15.65...

p = unstable(p, 20)

significant_digits(p) # -> 10.39...

# reset the precision carrier
reset_eps!(p)
```

## Caveats

This method, while helpful in many cases, is not universal and should be used with care:
- Some iterative methods (for a simple example, Newton's method) are not very reliant on high precision in every step, since they converge regardless of the precision of intermediate results. This can lead to something that looks like horrible precision loss, but is not actually relevant.
- The given number of epsilons is *not* the same as an error of measurement. It should not be used for error bars or similar. It's rather a rough indicator of numerical noise, but for example it can statistically happen that imprecisions cancel each other for certain cases, but this does not indicate better stability.
- Even arbitrary precision has its limits. For the `unstable` function given above, at about `N=256`, even the `BigFloat` will become unstable and the program will incorrectly report perfect precision (because both the normal float and the big float are equally wrong). However, this should only happen in extreme cases where you are likely aware of this.
- `BigFloat` is not usable on GPUs.
- The use of arbitrary precision adds considerable performance overhead.
