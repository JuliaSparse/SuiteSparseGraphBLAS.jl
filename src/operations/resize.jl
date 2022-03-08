function Base.resize!(A::AbstractGBMatrix, nrows::Integer, ncols::Integer)
    @wraperror LibGraphBLAS.GrB_Matrix_resize(gbpointer(A), LibGraphBLAS.GrB_Index(nrows), LibGraphBLAS.GrB_Index(ncols))
    return A
end

function Base.resize!(v::AbstractGBVector, nrows::Integer)
    @wraperror LibGraphBLAS.GrB_Matrix_resize(gbpointer(v), LibGraphBLAS.GrB_Index(nrows), 1)
    return v
end
