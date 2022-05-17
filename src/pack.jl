function _packdensematrix!(A::AbstractGBArray{T}, M::DenseVecOrMat; desc = nothing) where {T}
    desc = _handledescriptor(desc)
    Csize = length(A) * sizeof(T)
    values = Ref{Ptr{Cvoid}}(pointer(M))
    isuniform = false
    @wraperror LibGraphBLAS.GxB_Matrix_pack_FullC(
        gbpointer(A),
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
    valsize = length(values) * sizeof(T),
    rebaseindices = true
    ) where {T, Ti}
    if rebaseindices
        decrement!(colptr)
        decrement!(rowidx)
    end
    colptr = Ref{Ptr{LibGraphBLAS.GrB_Index}}(pointer(colptr))
    rowidx = Ref{Ptr{LibGraphBLAS.GrB_Index}}(pointer(rowidx))
    values = Ref{Ptr{Cvoid}}(pointer(values))
    desc = _handledescriptor(desc)

    @wraperror LibGraphBLAS.GxB_Matrix_pack_CSC(
        gbpointer(A),
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
    valsize = length(values) * sizeof(T),
    rebaseindices = true
    ) where {T, Ti}
    if rebaseindices
        decrement!(rowptr)
        decrement!(colidx)
    end
    rowptr = Ref{Ptr{LibGraphBLAS.GrB_Index}}(pointer(rowptr))
    colidx = Ref{Ptr{LibGraphBLAS.GrB_Index}}(pointer(colidx))
    values = Ref{Ptr{Cvoid}}(pointer(values))
    desc = _handledescriptor(desc)

    @wraperror LibGraphBLAS.GxB_Matrix_pack_CSC(
        gbpointer(A),
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

function _makeshallow!(A::AbstractGBArray)
    ccall((:GB_make_shallow, libgraphblas), Cvoid, (LibGraphBLAS.GrB_Matrix,), gbpointer(A))
end