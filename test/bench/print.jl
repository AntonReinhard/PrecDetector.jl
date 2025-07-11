using Statistics

using PrecisionCarriers: EpsT, EpsMax

@testset "make bins" begin
    using PrecisionCarriers: make_bins

    hist, mean_bin, median_bin = make_bins(EpsT[1, 2], EpsT(1), EpsT(2), 1.5, 1.5, 10)
    @test hist == [1, 0, 0, 0, 0, 0, 0, 0, 0, 1]
    @test mean_bin == 6
    @test median_bin == 6

    v = EpsT[0, 0, 0, 0, 1, 1, 2, 3, 4, 7, 15, 0, 0, 1, 0, 5, 3, 4, 5, 9, 20, 5, 2, 2, 2]
    hist, mean_bin, median_bin = make_bins(v, EpsT(1), maximum(v), mean(v), median(v), 5)
    @test hist == [3, 6, 5, 2, 2]
    @test mean_bin == 3
    @test median_bin == 2

    @test_throws InexactError make_bins(v, EpsT(0), maximum(v), mean(v), median(v), 5)
    @test_throws InexactError make_bins(v, EpsT(1), EpsT(1), mean(v), median(v), 5)
end

@testset "ascii_hist" begin
    using PrecisionCarriers: ascii_hist
    buf = IOBuffer()

    ascii_hist(buf, [1, 0, 0, 0, 0, 0, 0, 0, 0, 1], 6, 6)
    @test String(take!(buf)) == "\n█        █\n█▁▁▁▁▁▁▁▁█\n"

    ascii_hist(buf, [3, 6, 5, 2, 2], 3, 2)
    @test String(take!(buf)) == "\n▁█▅  \n███▆▆\n"
end

@testset "print hist info" begin
    using PrecisionCarriers: print_hist_info
    buf = IOBuffer()

    print_hist_info(buf, 25, EpsT(1), EpsT(20))
    @test String(take!(buf)) == "^ 1 ε  log scale   20 ε ^\n"

    print_hist_info(buf, 50, EpsT(5), EpsT(9841))
    @test String(take!(buf)) == "^ 5 ε              log scale              9841 ε ^\n"
end

@testset "print bench result" begin
    using PrecisionCarriers: EpsilonBenchmarkResult

    res = EpsilonBenchmarkResult("f(precify(%s))", EpsT(10), 3)

    buf = IOBuffer()
    show(buf, MIME"text/plain"(), res)
    @test String(take!(buf)) == "No samples were collected."

    @test res.total_samples == 0
    @test res.no_inf_epsilons == 0

    insert!(res, EpsT(0), (0.0f0,))

    @test res.total_samples == 1
    @test res.no_inf_epsilons == 0
    @test length(res.epsilons) == 1

    insert!(res, EpsT(500), (1.0f0,))

    @test res.total_samples == 2
    @test res.no_inf_epsilons == 0
    @test length(res.epsilons) == 2

    insert!(res, EpsMax, (2.0f0,))

    @test res.total_samples == 3
    @test res.no_inf_epsilons == 1
    @test length(res.epsilons) == 2  # infinite epsilons are not inserted

    show(buf, MIME"text/plain"(), res)
    @test String(take!(buf)) == "  \e[36msamples: \e[0m \e[1m3\e[0m\n  \e[32mminimum: \e[0m \e[1m0\e[0m ε\n  \e[34mmedian:  \e[0m \e[1m250.0\e[0m ε\n  \e[35mmean:    \e[0m \e[1m250.0\e[0m ε\n  \e[31mmaximum: \e[0m \e[1m500\e[0m ε\n  \e[1msamples with infinite ε:\e[0m 1\n\n                                                           █\n▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁█\n^ 1 ε                   log scale                    500 ε ^\n\n  \e[1mlargest imprecisions\e[0m:\nf(precify(2.0)) -> <ε=Inf>\nf(precify(1.0)) -> <ε=500>\n"
end
