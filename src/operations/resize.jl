function Base.resize!(A::GBMatrix, nrows::Integer, ncols::Integer)
    libgb.GrB_Matrix_resize(A, libgb.GrB_Index(nrows), libgb.GrB_Index(ncols))
    return A
end

function Base.resize!(v::GBVector, nrows::Integer)
    libgb.GrB_Vector_resize(v, libgb.GrB_Index(nrows))
    return v
end
