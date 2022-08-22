using SuiteSparseGraphBLAS: Structural
@testset "reduce" begin
    @testset "Reduction of Vec" begin
        v = GBVector(Int128.(1:10)) # test UDTs here.
        @test reduce(+, v) == 55
        @test reduce(*, v) == 3628800
        @test reduce(+, v, dims=1) == GBVector([1], Int128[55])
        @test reduce(+, v, dims=2) == v
        @test reduce(Monoid((x, y) -> x + y, zero), v) == 55
        f = (x, y) -> x * y
        SuiteSparseGraphBLAS.defaultmonoid(::typeof(f), ::Type{T}) where {T<:Any} = Monoid(f, one, zero)
        @test reduce(f, v) == 3628800
    end
    @testset "Reduction of Matrices" begin
        M = GBMatrix([[1,2] [3,4]]) # UDTs are pretty well tested above.
        @test reduce(+, M) == 10
        @test reduce(+, M, dims=1) == GBVector([3,7])
        @test reduce(+, M, dims=2) == GBVector([4, 6])
        @test reduce(+, M, dims=1; mask = GBVector([1], [true], nrows = 2)) == 
            GBVector([1], [3], nrows = 2)
        @test reduce(+, M, dims=2; mask = ~GBVector([1], [true], nrows = 2)) == 
            GBVector([2], [6], nrows = 2)
        
        @test reduce(+, M, dims=2; mask=Structural(GBVector([1], [false], nrows = 2))) ==
            GBVector([1], [4], nrows = 2)
        @test reduce(+, M, dims=2; mask=GBVector([1], [false], nrows = 2)) ==
            GBVector{Int64}(2)
    end
end
