@testset "types.jl" begin
for type ∈ [GBMatrix, GBMatrixC, GBMatrixR]
    # <type>{T, F}(nrows, ncols; fill)
    @test type{Int64}(3, 3) isa type
    A = type{Int64}(3, 3)
    @test nnz(A) == 0
    type === GBMatrixC && (@test storageorder(A) === ColMajor())
    type === GBMatrixR && (@test storageorder(A) === RowMajor())

    @test type{Int64}(3, 3,) isa type
    A = type{Int64}(3, 3)
    type === GBMatrixC && (@test storageorder(A) === ColMajor())
    type === GBMatrixR && (@test storageorder(A) === RowMajor())
    
    # <type>{T}(nrows, ncols; fill)
    A = type{Int64}(3, 3)
    @test getfill(A) === novalue
    @test nnz(A) == 0
    type === GBMatrixC && (@test storageorder(A) === ColMajor())
    type === GBMatrixR && (@test storageorder(A) === RowMajor())

    # <type>{T, F}()
end
end
