function _packdensematrix!(A::AbstractGBArray{T}, M::VecOrMat{T}; desc = nothing) where {T}
    desc = _handledescriptor(desc)
    Csize = length(A) * sizeof(T)
    ptr = pointer(M)
    # lock(memlock)
    # try
    #     PTRTOJL[Ptr{Cvoid}(ptr)] = M
    # finally
    #     unlock(memlock)
    # end
    @wraperror LibGraphBLAS.GxB_Matrix_pack_FullC(
        gbpointer(A),
        Ref{Ptr{Cvoid}}(ptr),
        Csize,
        false, #isuniform
        desc
    )
    return A
end

function _packdensematrixR!(A::AbstractGBArray{T}, M::VecOrMat{T}; desc = nothing) where {T}
    desc = _handledescriptor(desc)
    Csize = length(A) * sizeof(T)
    ptr = pointer(M)
    # lock(memlock)
    # try
    #     PTRTOJL[Ptr{Cvoid}(ptr)] = M
    # finally
    #     unlock(memlock)
    # end
    @wraperror LibGraphBLAS.GxB_Matrix_pack_FullR(
        gbpointer(A),
        Ref{Ptr{Cvoid}}(ptr),
        Csize,
        false, #isuniform
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
    decrementindices = true
    ) where {T, Ti}
    decrementindices && decrement!(colptr)
    decrementindices && decrement!(rowidx)

    # colpointer = pointer(colptr)
    # rowpointer = pointer(rowidx)
    # valpointer = pointer(values)
    # lock(memlock)
    # try
    #     PTRTOJL[Ptr{Cvoid}(colpointer)] = colptr
    #     PTRTOJL[Ptr{Cvoid}(rowpointer)] = rowidx
    #     PTRTOJL[Ptr{Cvoid}(valpointer)] = values
    # finally
    #     unlock(memlock)
    # end

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
    decrementindices = true
    ) where {T, Ti}

    decrementindices && decrement!(rowptr)
    decrementindices && decrement!(colidx)

    # rowpointer = pointer(rowptr)
    # colpointer = pointer(colidx)
    # valpointer = pointer(values)
    # lock(memlock)
    # try
    #     PTRTOJL[Ptr{Cvoid}(rowpointer)] = rowptr
    #     PTRTOJL[Ptr{Cvoid}(colpointer)] = colidx
    #     PTRTOJL[Ptr{Cvoid}(valpointer)] = values
    # finally
    #     unlock(memlock)
    # end

    rowptr = Ref{Ptr{LibGraphBLAS.GrB_Index}}(pointer(rowptr))
    colidx = Ref{Ptr{LibGraphBLAS.GrB_Index}}(pointer(colidx))
    values = Ref{Ptr{Cvoid}}(pointer(values))
    desc = _handledescriptor(desc)

    @wraperror LibGraphBLAS.GxB_Matrix_pack_CSR(
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

function pack!(A::AbstractGBArray, M::VecOrMat; order = ColMajor(), copytoraw = true)
    M = copytoraw ? _copytoraw(M) : M
    if order === ColMajor()
        _packdensematrix!(A, M)
    else
        _packdensematrixR!(A, M)
    end
    return A
end

function pack!(
    A::AbstractGBArray, ptr, idx, values; 
    order = ColMajor(), decrementindices = true, copytoraw = true
)
    ptr2 = copytoraw ? _copytoraw(ptr) : ptr
    idx2 = copytoraw ? _copytoraw(idx) : idx
    values2 = copytoraw ? _copytoraw(values) : values
    if order === ColMajor()
        _packcscmatrix!(A, ptr2, idx2, values2; decrementindices)
    else
        _packcsrmatrix!(A, ptr2, idx2, values2; decrementindices)
    end
    return A
end

function pack!(A::AbstractGBMatrix, S::SparseMatrixCSC; copytoraw = true)
    pack!(A, getcolptr(S), rowvals(S), nonzeros(S); copytoraw)
end

function pack!(A::AbstractGBArray, s::SparseVector; copytoraw = true)
    pack!(A, [1, length(s.nzind) + 1], rowvals(s), nonzeros(s); copytoraw)
end

function pack!(
    ::Type{GT}, A::AbstractArray{T}; 
    fill = nothing, order = ColMajor(), copytoraw = true
) where {GT<:AbstractGBArray, T}
    if GT <: AbstractGBVector
        G = GT{T}(size(A, 1); fill)
    else
        G = GT{T}(size(A, 1), size(A, 2); fill)
    end
    return pack!(G, A; order, copytoraw)
end
