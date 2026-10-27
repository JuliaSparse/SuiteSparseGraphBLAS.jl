@testset "mul" begin
    m = rand(10, 10)
    n = rand(10, 100)
    @test isapprox(Matrix(*(GBMatrix(m), GBMatrix(n))), m * n, atol=8e-15)
    m = GBMatrix([1,3,5,7], [7,5,3,1], [1,2,3,4])
    n = GBMatrix{Int8}(7, 1)
    n[1:2:7, 1] = [1, 10, 20, 30]
    o = *(m, n)
    @test size(o, 1) == 7
    @test eltype(o) == Int64
    @test o[7, 1] == 4 && o[5, 1] == 30
    o = GBMatrix(ones(Int64, 7, 1))
    mask = GBMatrix(ones(Bool, 7, 1))
    mask[3,1] = false
    @test mul!(o, m, n; mask, accum=+) ==
        GBMatrix([31,1,1,1,31,1,5])

    m = GBMatrix([[1,2,3] [4,5,6]])
    n = GBVector([10,20,30])
    @test_throws DimensionMismatch m * n
    @test m' * n == Matrix(m)' * Vector(n)
    @test n' * m == Vector(n)' * Matrix(m)
    @test n' * n == GBVector([Vector(n)' * Vector(n)])

    # mul! into dense outputs runs in GraphBLAS (#125)
    S = sprand(ComplexF64, 20, 15, 0.3)
    A = GBMatrix(S)
    x, X, y, Y = rand(ComplexF64, 15), rand(ComplexF64, 15, 3), rand(ComplexF64, 20), rand(ComplexF64, 20, 3)
    @test mul!(copy(y), A, x) ≈ S * x
    @test mul!(copy(y), A, x, 2, 3) ≈ 2 * S * x + 3 * y
    @test mul!(copy(Y), A, X) ≈ S * X
    @test mul!(copy(Y), A, X, 2, 3) ≈ 2 * S * X + 3 * Y
    @test mul!(zeros(ComplexF64, 15), A', y) ≈ S' * y
    @test mul!(view(zeros(ComplexF64, 25), 3:22), A, view([x; x], 16:30)) ≈ S * x

    # previously ambiguous products
    R = GBMatrix([1.0 2; 3 4]); r = [3.0, 4.0]
    @test (GBVector([1.0, 2.0])' * r)[1, 1] == 11.0
    @test R * sparse(r) ≈ [11.0, 25.0]
    @test R * view([0.0, 3, 4], 2:3) ≈ [11.0, 25.0]
    M = [1.0 2; 3 4]; g = GBVector([1.0, 1.0])
    @test Vector(M * g) == M * [1.0, 1.0]
    @test Vector(transpose(M) * g) == transpose(M) * [1.0, 1.0]
    @test Vector(transpose(ComplexF64.(M)) * GBVector(ComplexF64[1, 1])) == transpose(M) * [1.0, 1.0]
end
