function Base.resize!(A::GBMatrix, nrows::Integer, ncols::Integer)
    @wraperror LibGraphBLAS.GrB_Matrix_resize(A, LibGraphBLAS.GrB_Index(nrows), LibGraphBLAS.GrB_Index(ncols))
    return A
end

function Base.resize!(v::GBVector, nrows::Integer)
    @wraperror LibGraphBLAS.GrB_Matrix_resize(v, LibGraphBLAS.GrB_Index(nrows), 1)
    return v
end
