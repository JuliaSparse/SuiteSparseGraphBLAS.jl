using SuiteSparseGraphBLAS.SparseArrayCompat
# Modified SparseMatrixCSC test file
@testset "map[!] implementation specialized for a single (input) sparse vector/matrix" begin
    N, M = 10, 12
    for shapeA in (#=(N,),=# (N, M),)
        A = SparseMatrixGB(sprand(shapeA..., 0.4)); fA = Array(A)
        # --> test map entry point
        @test map(sin, A) ≈ SparseMatrixGB((map(sin, fA)); dropzeros=true)
        @test map(cos, A) ≈ SparseMatrixGB((map(cos, fA)); dropzeros=true)
        # --> test map! entry point
        # fX = copy(fA); X = sparse(fX)
        # map!(sin, X, A); X = sparse(fX) # warmup for @allocated
        # @test (@allocated map!(sin, X, A)) == 0
        # @test map!(sin, X, A) == sparse(map!(sin, fX, fA))
        # @test map!(cos, X, A) == sparse(map!(cos, fX, fA))
        # @test_throws DimensionMismatch map!(sin, X, spzeros((shapeA .- 1)...))
    end
    # https://github.com/JuliaLang/julia/issues/37819
    # Z = spzeros(Float64, Int32, 50000, 50000)
    # @test isa(-Z, SparseMatrixCSC{Float64, Int32})
end