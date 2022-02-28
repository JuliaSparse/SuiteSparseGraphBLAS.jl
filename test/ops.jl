@testset "Ops" begin
    @testset "UnaryOps" begin
        @test SuiteSparseGraphBLAS.juliaop(UnaryOp(sin)) === sin
        @test UnaryOp(sin)(Float64).builtin
        @test_throws ArgumentError UnaryOp(frexp)(Float64)

        #test the manual construction of TypedUnaryOperators
        X = GBVector(Float64[1,3,5])
        f = (x) -> 1.3 # a random unary function.
        op = UnaryOp(f)
        @test SuiteSparseGraphBLAS.juliaop(op) == f
        typedop = op(Float64)
        @test !typedop.builtin
        @test !typedop.loaded

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
    end
end