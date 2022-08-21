@testset "reduce" begin
    @testset "Reduction of Vec -> Scalar" begin
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
end
