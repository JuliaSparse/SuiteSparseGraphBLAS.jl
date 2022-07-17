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
    x = m' * n
    y = Matrix(m)'; show(y)
    z = Vector(n); show(z)
    @test m' * n == Matrix(m)' * Vector(n)
    @test n' * m == Vector(n)' * Matrix(m)
    @test n' * n == GBVector([Vector(n)' * Vector(n)])
end
