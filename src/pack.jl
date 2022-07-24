function _packdensematrix!(
    A::AbstractGBArray{T}, M::VecOrMat{T};
    desc = nothing, shallow = true
) where {T}
    desc = _handledescriptor(desc)
    Csize = length(A) * sizeof(T)
    ptr = pointer(M)
    if shallow 
        lock(memlock)
        try
            KEEPALIVE[Ptr{Cvoid}(ptr)] = M
        finally
            unlock(memlock)
        end
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

function _packdensematrixR!(
    A::AbstractGBArray{T}, M::VecOrMat{T};
    desc = nothing, shallow = true
) where {T}
    desc = _handledescriptor(desc)
    Csize = length(A) * sizeof(T)
    ptr = pointer(M)
    if shallow 
        lock(memlock)
        try
            KEEPALIVE[Ptr{Cvoid}(ptr)] = M
        finally
            unlock(memlock)
        end
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
    decrementindices = true,
    shallow = true
    ) where {T, Ti}
    decrementindices && decrement!(colptr)
    decrementindices && decrement!(rowidx)

    colpointer = pointer(colptr)
    rowpointer = pointer(rowidx)
    valpointer = pointer(values)
    if shallow
        lock(memlock)
        try
            KEEPALIVE[Ptr{LibGraphBLAS.GrB_Index}(colpointer)] = colptr
            KEEPALIVE[Ptr{LibGraphBLAS.GrB_Index}(rowpointer)] = rowidx
            KEEPALIVE[Ptr{Cvoid}(valpointer)] = values
        finally
            unlock(memlock)
        end
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
    decrementindices = true,
    shallow = true
    ) where {T, Ti}
    decrementindices && decrement!(rowptr)
    decrementindices && decrement!(colidx)

    rowpointer = pointer(rowptr)
    colpointer = pointer(colidx)
    valpointer = pointer(values)
    if shallow
        lock(memlock)
        try
            KEEPALIVE[Ptr{LibGraphBLAS.GrB_Index}(rowpointer)] = rowptr
            KEEPALIVE[Ptr{LibGraphBLAS.GrB_Index}(colpointer)] = colidx
            KEEPALIVE[Ptr{Cvoid}(valpointer)] = values
        finally
            unlock(memlock)
        end
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

function makeshallow!(A)
    ccall((:GB_make_shallow, libgraphblas), Cvoid, (LibGraphBLAS.GrB_Matrix,), gbpointer(parent(A)))
end

function pack!(A::AbstractGBArray, M::VecOrMat; order = ColMajor(), shallow = true)
    if order === ColMajor()
        _packdensematrix!(A, M; shallow)
    else
        _packdensematrixR!(A, M; shallow)
    end
    shallow && makeshallow!(A)
    return A
end

function pack!(
    A::AbstractGBArray, ptr, idx, values; 
    order = ColMajor(), decrementindices = true, shallow = true
)
    
    if order === ColMajor()
        _packcscmatrix!(A, ptr, idx, values; decrementindices, shallow)
    else
        _packcsrmatrix!(A, ptr, idx, values; decrementindices, shallow)
    end
    shallow && makeshallow!(A)
    return A
end

function pack!(A::AbstractGBArray, S::SparseMatrixCSC, shallow = true)
    pack!(A, getcolptr(S), getrowval(S), getnzval(S); shallow)
end

function pack!(A::AbstractGBArray, s::SparseVector, shallow = true)
    ptrvec = [1, length(s.nzind) + 1]
    ptrvec = shallow ? ptrvec : _copytoraw(ptrvec)
    pack!(A, ptrvec, s.nzind, s.nzval; shallow)
end

function pack!(::Type{GT}, A::AbstractArray{T}; fill = nothing, shallow = true) where {GT<:AbstractGBArray, T}
    if GT <: AbstractGBVector
        G = GT{T}(size(A, 1); fill)
    else
        G = GT{T}(size(A, 1), size(A, 2); fill)
    end
    return pack!(G, A; shallow)
end
