@testset "asjulia" begin
    A = [[1,2] [3,4]]
    B = GBMatrix(A)
    @test (A .== A) == SuiteSparseGraphBLAS.as((x) -> x .== A, Matrix, B)
    SuiteSparseGraphBLAS.as(Matrix, B; dropzeros=true) do mat
        mat[2, 2] = zero(eltype(mat))
        return nothing
    end

    u = [1,3,5,7,9]
    v = GBVector(u)
    @test 25 == SuiteSparseGraphBLAS.as(Vector, v) do vec
        sum(vec)
    end

    A = spdiagm([1,3,5,7,9])
    B = GBMatrix(A)
    @test SparseMatrixCSC(B) == A
    @test 25 == SuiteSparseGraphBLAS.as(SparseMatrixCSC, B, freeunpacked=true) do mat
        x = 0
        for i ∈ 1:5
            x += mat[i, i]
        end
        return x
    end

    u = sparsevec([1,3,5,7,9], [1,2,3,4,5])
    v = GBVector(u)
    @test SparseVector(v) == u
    SuiteSparseGraphBLAS.as(SparseVector, v) do vec
        for i ∈ 1:2:9
            vec[i] = vec[i] * 10
        end
        return nothing
    end
    @test sum(v) == 150
    @test u .* 10 == SuiteSparseGraphBLAS.as(SparseVector, v; freeunpacked=true) do vec
        copy(vec)
    end
end