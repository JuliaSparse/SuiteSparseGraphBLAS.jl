@testset "Ops" begin
    @testset "UnaryOps" begin
        @test SuiteSparseGraphBLAS.juliaop(unaryop(sin, Float64, Float64)) === sin
        @test unaryop(sin, Float64, Float64).builtin
        #test the manual construction of TypedUnaryOperators
        X = GBVector(Float64[1,3,5])
        f = (x) -> 1.3 # a random unary function.
        typedop = unaryop(f, Float64, Float64)
        @test !typedop.builtin
        @test !typedop.loaded
        @test unaryop(typedop, Float64, Float64) == typedop

        @test map(typedop, X)[1] == 1.3
        @test typedop.loaded
        
        #test the ephemeral method.
        @test map((x) -> x * 3, X)[1] == 3

    end
    @testset "BinaryOps" begin # kinda vacuous tests here...
        @test xtype(SuiteSparseGraphBLAS.binaryop(+, Float64)) == Float64
        @test ytype(SuiteSparseGraphBLAS.binaryop(+, Float64)) == Float64
        @test ztype(SuiteSparseGraphBLAS.binaryop(+, Float64)) == Float64
    end
    @testset "Monoids" begin
        @test xtype(SuiteSparseGraphBLAS.typedmonoid(+, Float64)) == Float64
        @test ytype(SuiteSparseGraphBLAS.typedmonoid(+, Float64)) == Float64
        @test ztype(SuiteSparseGraphBLAS.typedmonoid(+, Float64)) == Float64
    end
    @testset "Semirings" begin
        @test xtype(semiring((+, *), ComplexF64)) == ComplexF64
        @test ytype(semiring((+, *), ComplexF64)) == ComplexF64
        @test ztype(semiring((+, *), ComplexF64)) == ComplexF64
    end
end
