function _packdensematrix!(A::GBVecOrMat{T}, M::DenseVecOrMat; desc = nothing) where {T}
    desc = _handledescriptor(desc)
    Csize = length(A) * sizeof(T)
    values = Ref{Ptr{Cvoid}}(pointer(M))
    isuniform = false
    @wraperror LibGraphBLAS.GxB_Matrix_pack_FullC(
        A.p,
        values,
        Csize,
        isuniform,
        desc
    )
    return A
end

function _packcscmatrix!(
    A::GBVecOrMat{T},
    colptr::Vector{Ti},
    rowidx::Vector{Ti},
    values::Vector{T};
    desc = nothing,
    colptrsize = length(colptr) * sizeof(LibGraphBLAS.GrB_Index),
    rowidxsize = length(rowidx) * sizeof(LibGraphBLAS.GrB_Index),
    valsize = length(values) * sizeof(T)
    ) where {T, Ti}
    colptr .-= 1
    rowidx .-= 1
    colptr = Ref{Ptr{LibGraphBLAS.GrB_Index}}(pointer(colptr))
    rowidx = Ref{Ptr{LibGraphBLAS.GrB_Index}}(pointer(rowidx))
    values = Ref{Ptr{Cvoid}}(pointer(values))
    desc = _handledescriptor(desc)

    @wraperror LibGraphBLAS.GxB_Matrix_pack_CSC(
        A,
        colptr,
        rowidx,
        values,
        colptrsize,
        rowidxsize,
        valsize,
        false,
        false,
        desc
    )
    return A
end

function _packcsrmatrix!(
    A::GBVecOrMat{T},
    rowptr::Vector{Ti},
    colidx::Vector{Ti},
    values::Vector{T};
    desc = nothing,
    rowptrsize = length(rowptr) * sizeof(LibGraphBLAS.GrB_Index),
    colidxsize = length(colidx) * sizeof(LibGraphBLAS.GrB_Index),
    valsize = length(values) * sizeof(T)
    ) where {T, Ti}
    rowptr .-= 1
    colidx .-= 1
    rowptr = Ref{Ptr{LibGraphBLAS.GrB_Index}}(pointer(rowptr))
    colidx = Ref{Ptr{LibGraphBLAS.GrB_Index}}(pointer(colidx))
    values = Ref{Ptr{Cvoid}}(pointer(values))
    desc = _handledescriptor(desc)

    @wraperror LibGraphBLAS.GxB_Matrix_pack_CSC(
        A,
        rowptr,
        colidx,
        values,
        rowptrsize,
        colidxsize,
        valsize,
        false,
        false,
        desc
    )
    return A
end

function _makeshallow!(A::GBVecOrMat)
    ccall((:GB_make_shallow, libgraphblas), Cvoid, (LibGraphBLAS.GrB_Matrix,), A)
end