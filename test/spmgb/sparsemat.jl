using SuiteSparseGraphBLAS.SparseArrayCompat
@testset "Matching SparseMatrixCSC" begin
    A = sprand(5, 5, 0.35)
    B = SparseMatrixGB(A)
    C = sprand(5, 5, 0.35)
    D = SparseMatrixGB(C)
    for i ∈ eachindex(A)
        @test A[i] == B[i]
    end
    # broadcasting tests
    @test A .+ C ≈ B .+ D
    @test A .- C ≈ B .- D
    @test A .* C ≈ B .* D
    @test min.(A, C) ≈ min.(B, D)
    @test max.(A, C) ≈ max.(B, D)

    # map tests
    @test map(one, A) == map(one, B)
    @test map(sin, A) ≈ map(sin, B)
    @test map(identity, A) == map(identity, B)
    @test map(cos, A) ≈ map(cos, B)
    @test map((x)-> 1.5*x^2 + 3.0, A) ≈ map((x)-> 1.5*x^2 + 3.0, B)
end
