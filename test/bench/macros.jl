foo(x) = sqrt(tan(atan(x)))

@testset "negative tests" begin
    @test_throws ErrorException("got unknown keyword invalid_kwarg") @macroexpand @bench_epsilons f(x) ranges = begin
        x = (0.0, 5.0)
    end invalid_kwarg = 5

    @test_throws ErrorException("@bench_epsilons must be used with a function call as the first argument") @macroexpand @bench_epsilons 5.0

    @test_throws ErrorException("@bench_epsilons requires a `ranges = begin ... end` block") @macroexpand @bench_epsilons f(x)

    @test_throws ErrorException("ranges= must be assigned a begin...end block") @macroexpand @bench_epsilons f(x) ranges = 5.0

    @test_throws ErrorException("each line in the ranges block must be an assignment like `x = (a, b)`, got x = 5.0") @macroexpand @bench_epsilons f(x) ranges = begin
        x = 5.0
    end
end
