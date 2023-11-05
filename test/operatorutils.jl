@testset "Operator Utilities" begin
    @test SuiteSparseGraphBLAS.optype(Float64, Float32) == Float64
    @test SuiteSparseGraphBLAS.optype(UInt32, UInt64) == UInt64
    A = GBMatrix{Float64}(3, 3)
    B = GBMatrix{Int32}(3, 3)
    @test SuiteSparseGraphBLAS.optype(A, B) == Float64

    @test SuiteSparseGraphBLAS.symtotype(:nB) == SuiteSparseGraphBLAS.nBsyms
    @test SuiteSparseGraphBLAS.symtotype(:BigFloat) == :BigFloat
end
