function _packdensematrix!(A::AbstractGBArray{T}, M::VecOrMat{T}; desc = nothing) where {T}
    desc = _handledescriptor(desc)
    Csize = length(A) * sizeof(T)
    ptr = pointer(M)
    lock(memlock)
    try
        PTRTOJL[Ptr{Cvoid}(ptr)] = M
    finally
        unlock(memlock)
    end
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
    lock(memlock)
    try
        PTRTOJL[Ptr{Cvoid}(ptr)] = M
    finally
        unlock(memlock)
    end
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
    A::AbstractGBArray{T},
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

    colpointer = pointer(colptr)
    rowpointer = pointer(rowidx)
    valpointer = pointer(values)
    lock(memlock)
    try
        PTRTOJL[Ptr{Cvoid}(colpointer)] = colptr
        PTRTOJL[Ptr{Cvoid}(rowpointer)] = rowidx
        PTRTOJL[Ptr{Cvoid}(valpointer)] = values
    finally
        unlock(memlock)
    end

    colptr = Ref{Ptr{LibGraphBLAS.GrB_Index}}(colpointer)
    rowidx = Ref{Ptr{LibGraphBLAS.GrB_Index}}(rowpointer)
    values = Ref{Ptr{Cvoid}}(valpointer)
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
    A::AbstractGBArray{T},
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

    rowpointer = pointer(rowptr)
    colpointer = pointer(colidx)
    valpointer = pointer(values)
    lock(memlock)
    try
        PTRTOJL[Ptr{Cvoid}(rowpointer)] = rowptr
        PTRTOJL[Ptr{Cvoid}(colpointer)] = colidx
        PTRTOJL[Ptr{Cvoid}(valpointer)] = values
    finally
        unlock(memlock)
    end

    rowptr = Ref{Ptr{LibGraphBLAS.GrB_Index}}(rowpointer)
    colidx = Ref{Ptr{LibGraphBLAS.GrB_Index}}(colpointer)
    values = Ref{Ptr{Cvoid}}(valpointer)

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

function pack!(A::AbstractGBArray, M::VecOrMat; order = ColMajor())
    if order === ColMajor()
        _packdensematrix!(A, M)
    else
        _packdensematrixR!(A, M)
    end
    return A
end

function pack!(
    A::AbstractGBArray, ptr, idx, values; 
    order = ColMajor(), decrementindices = true
)
    if order === ColMajor()
        _packcscmatrix!(A, ptr, idx, values; decrementindices)
    else
        _packcsrmatrix!(A, ptr, idx, values; decrementindices)
    end
    return A
end

function pack!(A::AbstractGBArray, S::SparseMatrixCSC)
    _packcscmatrix!(A, getcolptr(S), getrowval(S), getnzval(S))
end

function pack!(A::AbstractGBArray, s::SparseVector)
    _packcscmatrix!(A, [1, length(s.nzind) + 1], s.nzind, s.nzval)
end

function pack!(::Type{GT}, A::AbstractArray{T}; fill = nothing) where {GT<:AbstractGBArray, T}
    if GT <: AbstractGBVector
        G = GT{T}(size(A, 1); fill)
    else
        G = GT{T}(size(A, 1), size(A, 2); fill)
    end
    return pack!(G, A)
end

# TODO: BITMAP && HYPER