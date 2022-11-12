@testset "abstractgbarray.jl" begin
    A = GBMatrix([[1,2] [3,4]])
    @testset "_canbeoutput" begin
        B = SuiteSparseGraphBLAS.pack([[1,2] [3,4]])
        @test SuiteSparseGraphBLAS._canbeoutput(A)
        @test !SuiteSparseGraphBLAS._canbeoutput(B)
    end

    @testset "_hasconstantorder" begin
        @test !SuiteSparseGraphBLAS._hasconstantorder(A)
        @test SuiteSparseGraphBLAS._hasconstantorder(GBMatrixC(A))
    end
    @testset "Base Functions" begin
        @test Base.IndexStyle(A) === IndexCartesian()

        @testset "similar of Transpose" begin
            @test similar(A, Float64, 5) isa GBVector{Float64}
            @test similar(A, 5) isa GBVector{eltype(A)}
        end

        C = GBMatrix{Int64}(2, 2)
        @test copyto!(C, A) == A
        @test C !== A

        @testset "reshape and resize!" begin
            @test size(reshape(A, 1, 4)) == (1, 4)
            @test size(reshape(A, 1, :)) == (1, 4)
            @test size(reshape(A, :, 1)) == (4, 1)
            @test size(reshape(A, :, 2)) == (2, 2)
            @test size(reshape(A, 2, :)) == (2, 2)
            @test size(reshape(A, (:, 2))) == (2, 2)
            @test size(reshape(A, (2, 2))) == (2, 2)
            @test size(reshape(A, :)) == (4,)
            B = copy(A)
            @test resize!(B, 1, 4) == GBMatrix([1, 1], [1, 2], [1, 3], 1, 4)
            @test resize!(B, 1, 1) === B
        end
        @testset "isstored" begin
            @test deleteat!(A, 1, 1) isa SuiteSparseGraphBLAS.AbstractGBArray
            @test !Base.isstored(A, 1, 1)
            @test Base.isstored(A, 2, 2)
            A[1, 1] = 1
        end
    end

    @testset "SparseArrays.jl Functions" begin
        @test SparseMatrixCSC(A) == A
    end

    @testset "build!" begin
        # UDTs
        X = GBMatrix{Int128}(2, 2)
        @test SuiteSparseGraphBLAS.build!(X, [1,1,2,2], [1,2,1,2], Int128[1,2,3,4]) == 
        Int128[[1,3] [2,4]]
        X = GBMatrix{Int128}(2, 2)
        @test SuiteSparseGraphBLAS.build!(X, [1,1,2,2], [1,2,1,2], Int128(5)) ==
        Int128[[5,5] [5,5]]

        # Built-in
        X = GBMatrix{Float64}(2, 2)
        @test SuiteSparseGraphBLAS.build!(X, [1,1,2,2], [1,2,1,2], Float64[1,2,3,4]) == 
        Float64[[1,3] [2,4]]
        X = GBMatrix{Float64}(2, 2)
        @test SuiteSparseGraphBLAS.build!(X, [1,1,2,2], [1,2,1,2], Float64(5)) ==
        Float64[[5,5] [5,5]]
    end

    @testset "findnz" begin
        # UDTs
        X = GBMatrix{Int128}([[1,2] [3,4]])
        @test eltype(X) === Int128
        @test findnz(X) == ([1,2,1,2], [1,1,2,2], [1,2,3,4])
        @test nonzeros(X) == [1,2,3,4]
        @test nonzeroinds(X) == ([1,2,1,2], [1,1,2,2])

        X = GBMatrix{Float64, Nothing}([[1,2] [3,4]])
        @test eltype(X) == Union{Float64, Nothing}
        @test findnz(X) == ([1,2,1,2], [1,1,2,2], [1,2,3,4])
        @test nonzeros(X) == [1,2,3,4]
        @test nonzeroinds(X) == ([1,2,1,2], [1,1,2,2])
    end
end