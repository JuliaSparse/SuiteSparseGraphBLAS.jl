@testset "GrB_Matrix" begin
    struct MyInt{T}
        x::T
    end
    A = GrB.GrB_Matrix{MyInt{Int64}}(5, 5)
    x = GrB.GrB_Scalar{MyInt{Int64}}()
    y = Ref{MyInt{Int64}}()
    @test GrB.getElement!(y, A, 1, 3) == GrB.LibGraphBLAS.GrB_NO_VALUE
    @test GrB.getElement!(x, A, 1, 3) == GrB.LibGraphBLAS.GrB_SUCCESS
    @test GrB.nvals(x) == 0 == GrB.nvals(A)
    x[] = MyInt(3)
    @test GrB.setElement!(A, x, 1, 3) == x
    @test GrB.nvals(x) == 1 == GrB.nvals(A)
    @test A[1, 3] == MyInt(3)
    B = GrB.dup(A)
    
end
