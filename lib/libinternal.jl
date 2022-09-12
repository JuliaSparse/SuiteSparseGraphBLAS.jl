function GB_is_shallow(A)
    ccall((:GB_is_shallow, libgraphblas), Bool, (GrB_Matrix,), A)
end