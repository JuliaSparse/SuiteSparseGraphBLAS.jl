function Base.resize!(A::AbstractGBMatrix, nrows::Integer, ncols::Integer)
    _canbeoutput(A) || throw(ShallowException())
    @wraperror LibGraphBLAS.GrB_Matrix_resize(A, LibGraphBLAS.GrB_Index(nrows), LibGraphBLAS.GrB_Index(ncols))
    return A
end

function Base.resize!(v::AbstractGBVector, nrows::Integer)
    _canbeoutput(v) || throw(ShallowException())
    @wraperror LibGraphBLAS.GrB_Matrix_resize(v, LibGraphBLAS.GrB_Index(nrows), 1)
    return v
end
