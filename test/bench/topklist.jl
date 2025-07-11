using PrecisionCarriers: EpsT

@testset "top k list" begin
    using PrecisionCarriers: TopKSortedList

    list = TopKSortedList{EpsT, Tuple{Float64, Float32}}(3)

    @test list.max_keys == 3
    @test isempty(list.entries)
    @test typeof(list.entries) == Vector{Tuple{EpsT, Tuple{Float64, Float32}}}

    insert!(list, EpsT(1), (0.5, 0.1f0))

    @test list.max_keys == 3
    @test length(list.entries) == 1
    @test list.entries[1] == (EpsT(1), (0.5, 0.1f0))

    insert!(list, EpsT(5), (0.1, 0.2f0))

    # inserted above
    @test length(list.entries) == 2
    @test list.entries[1] == (EpsT(5), (0.1, 0.2f0))
    @test list.entries[2] == (EpsT(1), (0.5, 0.1f0))

    insert!(list, EpsT(3), (1.0, 0.0f0))
    insert!(list, EpsT(10), (2.0, 0.0f0))

    @test length(list.entries) == 3
    @test list.entries[1] == (EpsT(10), (2.0, 0.0f0))
    @test list.entries[2] == (EpsT(5), (0.1, 0.2f0))
    @test list.entries[3] == (EpsT(3), (1.0, 0.0f0))

    insert!(list, EpsT(2), (3.0, 0.0f0)) # does not get added

    @test length(list.entries) == 3
    @test list.entries[1] == (EpsT(10), (2.0, 0.0f0))
    @test list.entries[2] == (EpsT(5), (0.1, 0.2f0))
    @test list.entries[3] == (EpsT(3), (1.0, 0.0f0))
end
