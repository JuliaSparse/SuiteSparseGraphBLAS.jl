@testset "libutils" begin
    @test SuiteSparseGraphBLAS.decrement!(3) == 2
    v = [1,2,3]
    SuiteSparseGraphBLAS.decrement!(v)
    @test v == [0, 1, 2]

    @test SuiteSparseGraphBLAS.increment!(2) == 3
    SuiteSparseGraphBLAS.increment!(v)
    @test v == [1, 2, 3]

    @test SuiteSparseGraphBLAS.suffix("ComplexF64") == "FC64"

    @test SuiteSparseGraphBLAS.load_global("gobbledygook") == Ptr{Nothing}()

    @test SuiteSparseGraphBLAS.isGxB("GxB_Matrix_import_CSC")
    @test !SuiteSparseGraphBLAS.isGxB("GrB_Desc_Field")
    @test SuiteSparseGraphBLAS.isGrB("GrB_Desc_Field")

    if Sys.islinux() && Sys.which("cc") !== nothing # default JIT flags assume gcc
        cache = mktempdir()
        @test SuiteSparseGraphBLAS.jit!(; cache)
        x = sprand(Int64, 50, 50, 0.1)
        @test GBMatrix(x)[:, 3] == GBVector(x[:, 3]) # needs a JIT kernel
        @test any(endswith(".so"), (f for (_, _, fs) in walkdir(cache) for f in fs))
        @test !SuiteSparseGraphBLAS.jit!(false)
    end
end