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
end