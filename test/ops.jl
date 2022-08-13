@testset "Ops" begin
    @testset "UnaryOps" begin
        @test SuiteSparseGraphBLAS.SuiteSparseGraphBLAS.juliaop(unaryop(sin, Float64)) === sin
        @test unaryop(sin, Float64).builtin
        #test the manual construction of TypedUnaryOperators
        X = GBVector(Float64[1,3,5])
        f = (x) -> 1.3 # a random unary function.
        typedop = unaryop(f, Float64)
        @test !typedop.builtin
        @test !typedop.loaded
        @test unaryop(typedop, Float64) == typedop

        @test map(typedop, X)[1] == 1.3
        @test typedop.loaded

        #test the macro method. Macro is used in runtests.jl
        @test !FOO_FP64.loaded
        @test map(foo, X)[1] == 4.5
        @test FOO_FP64.loaded
        #test the ephemeral method.
        @test map((x) -> x * 3, X)[1] == 3

    end
    @testset "BinaryOps" begin # kinda vacuous tests here...
        @test xtype(BinaryOp(+)(Float64)) == Float64
        @test ytype(BinaryOp(+)(Float64)) == Float64
        @test ztype(BinaryOp(+)(Float64)) == Float64
    end
    @testset "Monoids" begin
        @test xtype(Monoid(+)(Float64)) == Float64
        @test ytype(Monoid(+)(Float64)) == Float64
        @test ztype(Monoid(+)(Float64)) == Float64

        op = Monoid(+)
        @test SuiteSparseGraphBLAS.juliaop(op) === +
        @test Monoid(op(ComplexF64)) == op(ComplexF64)
    end
    @testset "Semirings" begin
        @test xtype(Semiring(+, *)(ComplexF64)) == ComplexF64
        @test ytype(Semiring(+, *)(ComplexF64)) == ComplexF64
        @test ztype(Semiring(+, *)(ComplexF64)) == ComplexF64
    end
end