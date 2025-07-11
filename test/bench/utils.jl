using Random
FLOAT_TYPES = [Float16, Float32, Float64]

RNG = MersenneTwister()

@testset "samplers for $N points" for N in [10, 100, 1000]
    @testset "$M ranges"  for M in [1, 2, 3]
        ranges = ntuple(_ -> (rand(RNG), rand(RNG) + 1), M)
        @testset "random search" begin
            iter = PrecisionCarriers._random_samples(ranges, N)

            @test length(iter) == N
            v = collect(iter)
            @test length(v) == N
            for i in 1:M
                @test all(Ref(ranges[i][1]) .<= getindex.(v, Ref(i)) .<= Ref(ranges[i][2]))
            end
        end

        @testset "evenly spaced" begin
            iter = PrecisionCarriers._grid_samples(ranges, N)

            @test length(iter) <= N
            v = collect(iter)
            @test length(v) == length(iter)
            for i in 1:M
                @test all(Ref(ranges[i][1]) .<= getindex.(v, Ref(i)) .<= Ref(ranges[i][2]))
            end
            # the first value should be all the lower bounds
            @test v[1] == ntuple(i -> ranges[i][1], M)
            # and the last value all upper bounds
            @test v[end] == ntuple(i -> ranges[i][2], M)
        end
    end
end

test_exprs = [
    (
        Expr(:call, :f, 5.0, :x),
        "f(Float64(5.0), precify(%s))",
        Any[5.0, :($precify(x))],
        [:x],
    ),
    (
        Expr(:call, :f, 5.0f0, Expr(:call, :bar, :y)),
        "f(Float32(5.0), bar(precify(%s)))",
        Any[5.0f0, :(($(Expr(:escape, :bar)))(($precify)(y)))],
        [:y],
    ),
    (
        Expr(:call, :f, Expr(:tuple, Float64(5.0), Expr(:call, :bar, :y))),
        "f((Float64(5.0), bar(precify(%s))))",
        Any[:((5.0, ($(Expr(:escape, :bar)))(($precify)(y))))],
        [:y],
    ),
    (
        Expr(:call, :f, Expr(:tuple, 5.0), Expr(:call, :bar, :y)),
        "f((Float64(5.0), ), bar(precify(%s)))",
        Any[:((5.0,)), :(($(Expr(:escape, :bar)))(($precify)(y)))],
        [:y],
    ),
    (
        Expr(:call, :foo, Expr(:$, :outside), :x, :y),
        "foo(outside, precify(%s), precify(%s))",
        Any[:($(Expr(:escape, :outside))), :(($precify)(x)), :(($precify)(y))],
        [:x, :y],
    ),
    (
        Expr(:call, :bar, "string", :var),
        "bar(\"string\", precify(%s))",
        Any["string", :(($precify)(var))],
        [:var],
    ),
    (
        Expr(:call, :bar, 1, :var),
        "bar(1, precify(%s))",
        Any[1, :(($precify)(var))],
        [:var],
    ),
]

@testset "build function call string" begin
    using PrecisionCarriers: _build_function_call_string
    for (expr, str, _, __) in test_exprs
        @test _build_function_call_string(expr) == str
    end
end

@testset "argument precifying" begin
    using PrecisionCarriers: _precify_args!
    for (expr, _, precified, vars) in test_exprs
        args = expr.args[2:end]
        vars = []
        _precify_args!(args, vars)
        @test args == precified
        @test vars == vars
    end
end
