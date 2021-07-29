@testset "operations.jl" begin
    @testset "ewise" begin
        m = GBMatrix([[1,2,3] [4,5,6]])
        n = GBMatrix([1,2,3,2], [1,2,2,1], [1,2,3,4])
        #eadd correctness
        @test eadd(m, n) == GBMatrix([1,1,2,2,3,3], [1,2,1,2,1,2], [2,4,6,7,3,9])
        @test eadd(m, n, BinaryOps.GT)[1, 1] == 0
        #check that the (+) op is being picked up from the semiring.
        @test eadd(m, n, Semirings.PLUS_MAX) == eadd(m, n, BinaryOps.PLUS)
        #emul correctness
        @test emul(m, n, BinaryOps.POW)[3, 2] == m[3,2] ^ n[3,2]
        #check that the (*) op is being picked up from the semiring
        @test emul(m, n, Semirings.MAX_PLUS) == emul(m, n, BinaryOps.PLUS)
        @test eltype(m .== n) == Bool
    end
    @testset "kron" begin
        m1 = GBMatrix(UInt64[1, 2, 3, 5], UInt64[1, 3, 1, 2], Int8[1, 2, 3, 5])
        n1 = GBMatrix(ones(UInt32, 4, 4))
        m2 = sparse([1, 2, 3, 5], [1, 3, 1, 2], Int8[1, 2, 3, 5])
        n2 = ones(Int32, 4, 4)
        o1 = kron(m1, n1)
        @test o1 == GBMatrix(kron(m2, n2)) #basic kron is equivalent
        mask = GBMatrix{Bool}(20, 12)
        mask[17:20, 5:8] = false #don't care value, using structural
        #mask out bottom chunk using structural complement
        o2 = kron(m1, n1; mask, desc=SC)
        @test o2[20, 5] === nothing #We don't want values in masked out area
        @test o2[1:2:15, :] == o1[1:2:15, :] #The rest should match, test indexing too.
    end
    @testset "map" begin
        m = sprand(5, 5, 0.25)
        n = GBMatrix(m)
        @test map(UnaryOps.LOG, n)[1,1] == map(log, m)[1,1]
        o = map!(BinaryOps.GT, GBMatrix{Bool}(5, 5),  0.1, n)
        @test o[1,1] == false && o[1,4] == true
        @test map(BinaryOps.SECOND, n, 1.5)[1,1] == 1.5
        @test (n .* 10)[1,1] == n[1,1] * 10
    end
    @testset "mul" begin
        m = rand(10, 10)
        n = rand(10, 100)
        #NOTE: Can someone check this, not sure if that's fine, or egregious.
        @test isapprox(Matrix(mul(GBMatrix(m), GBMatrix(n))), m * n, atol=8e-15)
        m = GBMatrix([1,3,5,7], [7,5,3,1], [1,2,3,4])
        n = GBMatrix{Int8}(7, 1)
        n[1:2:7, 1] = [1, 10, 20, 30]
        o = mul(m, n)
        @test size(o) == (7,1)
        @test eltype(o) == Int64
        @test o[7, 1] == 4 && o[5, 1] == 30
        o = GBMatrix(ones(Int64, 7, 1))
        mask = GBMatrix(ones(Bool, 7, 1))
        mask[3,1] = false
        @test mul!(o, m, n; mask, accum=BinaryOps.PLUS) ==
            GBMatrix([31,1,1,1,31,1,5])

        m = GBMatrix([[1,2,3] [4,5,6]])
        n = GBVector([10,20,30])
        @test_throws DimensionMismatch m * n
        @test m' * n == GBVector([140, 320]) == n * m
    end
    @testset "reduce" begin
        m = GBMatrix([[1,2,3] [4,5,6] [7,8,9]])
        reduce(max, m, dims=2) == reduce(Monoids.MAX_MONOID, m) #this only works for dense
        reduce(Monoids.MAX_MONOID, m, dims=(1,2)) == 9
        @test_throws ArgumentError reduce(BinaryOps.TIMES, m)
    end
    @testset "select" begin
        m = GBMatrix([[1,2,3] [4,5,6] [7,8,9]])
        s = select(TRIL, m)
        @test s[1,2] === nothing && s[3,1] == 3
        s = select(LT, m, 6)
        @test s[2,2] == 5 && s[3,3] === nothing
    end
    @testset "transpose" begin
        m = GBMatrix(sprand(3, 3, 0.5))
        @test gbtranspose(m') == m
        @test m[1,2] == m'[2,1]
        @test m[1,2] == gbtranspose(m)[2,1]
    end
end
