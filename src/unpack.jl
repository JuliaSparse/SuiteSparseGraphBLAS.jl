function _unpackdensematrix!(A::AbstractGBVector{T}; desc = nothing) where {T}
    szA = size(A)
    desc = _handledescriptor(desc)
    Csize = Ref{LibGraphBLAS.GrB_Index}(length(A) * sizeof(T))
    values = Ref{Ptr{Cvoid}}(Ptr{T}())
    isiso = Ref{Bool}(false)
    @wraperror LibGraphBLAS.GxB_Matrix_unpack_FullC(
        gbpointer(A),
        values,
        Csize,
        isiso,
        desc
    )
    lock(memlock)
    M = try
        pop!(PTRTOJL, values[])
    finally
        unlock(memlock)
    end
    # eltype(M) == T || (M = copy(reinterpret(T, M)))
    if length(M) != length(A)
        resize!(M, length(A))
    end
    return M::Vector{T}
end

function _unpackdensematrix!(A::AbstractGBMatrix{T}; desc = nothing) where {T}
    szA = size(A)
    desc = _handledescriptor(desc)
    Csize = Ref{LibGraphBLAS.GrB_Index}(length(A) * sizeof(T))
    values = Ref{Ptr{Cvoid}}(Ptr{T}())
    isiso = Ref{Bool}(false)
    @wraperror LibGraphBLAS.GxB_Matrix_unpack_FullC(
        gbpointer(A),
        values,
        Csize,
        isiso,
        desc
    )
    lock(memlock)
    M = try
        pop!(PTRTOJL, values[])
    finally
        unlock(memlock)
    end
    # eltype(M) == T || (M = copy(reinterpret(T, M)))
    if length(M) != length(A)
        resize!(M, length(A))
    end
    return reshape(M, szA[1], szA[2])::Matrix{T}
end

function _unpackdensematrixR!(A::AbstractGBArray{T}; desc = nothing) where {T}
    szA = size(A)
    desc = _handledescriptor(desc)
    Csize = Ref{LibGraphBLAS.GrB_Index}(length(A) * sizeof(T))
    values = Ref{Ptr{Cvoid}}(Ptr{T}())
    isiso = Ref{Bool}(false)
    @wraperror LibGraphBLAS.GxB_Matrix_unpack_FullR(
        gbpointer(A),
        values,
        Csize,
        isiso,
        desc
    )
    lock(memlock)
    M = try
        pop!(PTRTOJL, values[])
    finally
        unlock(memlock)
    end
    return reshape(M, szA...)
end

function _unpackcscmatrix!(A::AbstractGBArray{T}; desc = nothing, incrementindices = true) where {T}
    desc = _handledescriptor(desc)
    colptr = Ref{Ptr{LibGraphBLAS.GrB_Index}}()
    rowidx = Ref{Ptr{LibGraphBLAS.GrB_Index}}()
    values = Ref{Ptr{Cvoid}}(Ptr{T}())
    colptrsize = Ref{LibGraphBLAS.GrB_Index}()
    rowidxsize = Ref{LibGraphBLAS.GrB_Index}()
    valsize = Ref{LibGraphBLAS.GrB_Index}()
    isiso = Ref{Bool}(false)
    isjumbled = C_NULL
    nnonzeros = nnz(A)
    @wraperror LibGraphBLAS.GxB_Matrix_unpack_CSC(
        gbpointer(A),
        colptr,
        rowidx,
        values,
        colptrsize,
        rowidxsize,
        valsize,
        isiso,
        isjumbled,
        desc
    )
    lock(memlock)
    colptr, rowidx = try
        (pop!(PTRTOJL, colptr[]), pop!(PTRTOJL, rowidx[]))
    finally
        unlock(memlock)
    end
    lock(memlock)
    vals = try
        pop!(PTROJL, values[])
    finally
        unlock(memlock)
    end
    if isiso[]
        vals = fill(vals[1], nnonzeros)
    end
    if incrementindices
        increment!(colptr)
        increment!(rowidx)
    end
    return resize!(colptr, size(A, 2) + 1),
    rowidx,
    vals
end

function _unpackcsrmatrix!(A::AbstractGBArray{T}; desc = nothing, incrementindices = true) where {T}
    desc = _handledescriptor(desc)
    rowptr = Ref{Ptr{LibGraphBLAS.GrB_Index}}()
    colidx = Ref{Ptr{LibGraphBLAS.GrB_Index}}()
    values = Ref{Ptr{Cvoid}}(Ptr{T}())
    rowptrsize = Ref{LibGraphBLAS.GrB_Index}()
    colidxsize = Ref{LibGraphBLAS.GrB_Index}()
    valsize = Ref{LibGraphBLAS.GrB_Index}()
    isiso = Ref{Bool}(false)
    isjumbled = C_NULL
    nnonzeros = nnz(A)
    @wraperror LibGraphBLAS.GxB_Matrix_unpack_CSC(
        gbpointer(A),
        rowptr,
        colidx,
        values,
        rowptrsize,
        colidxsize,
        valsize,
        isiso,
        isjumbled,
        desc
    )
    lock(memlock)
    rowptr, colidx = try
        (pop!(PTRTOJL, rowptr[]), pop!(PTRTOJL, colidx[]))
    finally
        unlock(memlock)
    end
    lock(memlock)
    vals = try
        pop!(PTROJL, values[])
    finally
        unlock(memlock)
    end
    if isiso[]
        vals = fill(vals[1], nnonzeros)
    end
    if incrementindices
        increment!(rowptr)
        increment!(colidx)
    end
    return resize!(rowptr, size(A, 1) + 1),
    colidx,
    vals
end

function unpack!(A::AbstractGBArray{T}, ::Dense; order = ColMajor()) where {T}
    wait(A)
    sparsity = sparsitystatus(A)
    sparsity === Dense() || (A .+= (similar(A) .= zero(T)))
    if order === ColMajor()
        return _unpackdensematrix!(A)
    else
        return _unpackdensematrixR!(A)
    end
end

function unpack!(A::AbstractGBArray, ::Type{Vector})
    reshape(unpack!(A, Dense()), :)
end
unpack!(A::AbstractGBArray, ::Type{Matrix}) = unpack!(A, Dense())

function unpack!(A::AbstractGBArray, ::Sparse; order = ColMajor(), incrementindices = true)
    wait(A)
    if order === ColMajor()
        return _unpackcscmatrix!(A; incrementindices)
    else
        return _unpackcsrmatrix!(A; incrementindices)
    end
end
unpack!(A::AbstractGBArray, ::Type{SparseMatrixCSC}) = SparseMatrixCSC(size(A)..., unpack!(A, Sparse())...)

# remove colptr for this, colptr doesn't really exist anyway, it should just be [0] (or [1] in 1-based).
unpack!(A::AbstractGBVector, ::Type{SparseVector}) = SparseVector(size(A)..., unpack!(A, Sparse())[2:end]...)

function unpack!(A::AbstractGBArray)
    sparsity, order = format(A)
    return unpack!(A, sparsity; order)
end


# TODO: BITMAP && HYPER
# TODO: A repack! api?