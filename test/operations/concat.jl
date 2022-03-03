@testset "concat.jl" begin
    v1 = GBVector([1,2])
    v2 = GBVector([3,4])
    @test vcat(v1, v2) == vcat(Vector(v1), Vector(v2))
    @test vcat(GBMatrix([[1,2] [3,4]]), GBMatrix([[5,6] [7,8]])) == [1 3; 2 4; 5 7; 6 8]
    
    @test hcat(v1, v2) == hcat(Vector(v1), Vector(v2))

    @test cat([[v1, v2] [v1, v2]]) == [[1,2,3,4] [1,2,3,4]]

    # mutating forms:
    C = GBVector{Int64}(4)
    @test SuiteSparseGraphBLAS.vcat!(C, v1, v2) == [1,2,3,4]
    C = GBMatrix{Int64}(2, 2)
    @test SuiteSparseGraphBLAS.hcat!(C, v1, v2) == hcat(v1, v2)
end