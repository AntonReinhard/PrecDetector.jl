# Package Extensions

Some extensions for interoperability with other packages are provided.

## Random

An extension for the `Base.Random` package is provided, overloading rand functions. When Random is loaded, one can therefore generate random numbers just like for `Floats`:

```@example random
using PrecisionCarriers
using Random

rand(PrecisionCarrier{Float16})
```
```@example random
rand(PrecisionCarrier{Float32})
```
```@example random
rand(PrecisionCarrier)
```

Furthermore, when using a specific (seeded) generator, the produced values are reproducible with the non-wrapped Float generator:

```@example random
@assert rand(MersenneTwister(0)) == rand(MersenneTwister(0), PrecisionCarrier)
```

The same is true for arrays of random numbers:

```@example random
@assert rand(MersenneTwister(0), Float32, (5, 5)) == rand(MersenneTwister(0), PrecisionCarrier{Float32}, (5, 5))
```

## [DoubleFloats.jl](https://github.com/JuliaMath/DoubleFloats.jl/)

This is an extension for a package providing `DoubleFloat` types, which internally store two floats, a `hi` and a `lo` one. These can be used for better precision without resorting to larger types (which may not be supported on GPUs, for example). When this package is loaded, they can be `precify`'d and used just like basic `Float` types.

```@example doublefloats
using PrecisionCarriers
using DoubleFloats

precify(df64"0.1")
```
```@example doublefloats
d = DoubleFloat(precify(1.0e3))
```
```@example doublefloats
tan(atan(d))
```
