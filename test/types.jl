@testset "types.jl" begin
for type ∈ [GBMatrix, GBMatrixC, GBMatrixR]
    # <type>{T, F}(nrows, ncols; fill)
    A = type{Int64, Int64}(3, 3)
    @test getfill(A) === zero(Int64)
    @test nnz(A) == 0
    type === GBMatrixC && (@test storageorder(A) === ColMajor())
    type === GBMatrixR && (@test storageorder(A) === RowMajor())
    A = type{Int64, Int64}(3, 3; fill = 3)
    @test getfill(A) === 3
    type === GBMatrixC && (@test storageorder(A) === ColMajor())
    type === GBMatrixR && (@test storageorder(A) === RowMajor())
    @test_throws MethodError type{Int64, Nothing}(3, 3; fill = 3)

    # <type>{T}(nrows, ncols; fill)
    A = type{Int64}(3, 3)
    @test getfill(A) === zero(Int64)
    @test nnz(A) == 0
    type === GBMatrixC && (@test storageorder(A) === ColMajor())
    type === GBMatrixR && (@test storageorder(A) === RowMajor())
    B = setfill(A, nothing)
    @test getfill(B) === nothing

    # <type>{T, F}()
end
end