types = [Bool, Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64, Float32, Float64]

@testset "Matrix methods" begin
    I = J = ZeroBasedIndex[0, 1, 2, 3, 4]
    for t in types
        X = rand(t, 5)
        A = GrB_Matrix(I, J, X)
        @test size(A) == (5, 5)
        @test size(A, 1) == 5
        P, Q, R = findnz(A)
        @test P == I
        @test Q == J
        @test R == X
        @test nnz(A) == 5
        B = copy(A)
        @test A == B
        @test size(B) == (5, 5)
        P, Q, R = findnz(B)
        @test P == I
        @test Q == J
        @test R == X
        @test nnz(B) == 5
        i = rand(1:5)
        @test A[I[i], J[i]] == X[i]
        k = rand(t)
        A[I[i], J[i]] = k
        @test A[I[i], J[i]] == k
        empty!(A)
        @test nnz(A) == 0
        GrB_free(A)
        GrB_free(B)
    end
end

@testset "Vector Methods" begin
    I = ZeroBasedIndex[0, 3, 4]
    for t in types
        X = rand(t, 3)
        V = GrB_Vector(I, X)
        @test size(V) == (5, )
        @test size(V, 1) == 5
        P, Q = findnz(V)
        @test P == I
        @test Q == X
        @test nnz(V) == 3
        W = copy(V)
        @test V == W
        @test size(W) == (5, )
        P, Q = findnz(W)
        @test P == I
        @test Q == X
        @test nnz(W) == 3
        i = rand(1:3)
        @test V[I[i]] == X[i]
        k = rand(t)
        V[I[i]] = k
        @test V[I[i]] == k
        empty!(V)
        @test nnz(V) == 0
        GrB_free(W)
        GrB_free(V)
    end
end
