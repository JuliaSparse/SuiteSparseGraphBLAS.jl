function _unpackdensematrix!(
    A::AbstractGBVector{T}; 
    desc = nothing, attachfinalizer = true
) where {T}
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
    v = try
        if values[] ∈ keys(KEEPALIVE)
            return pop!(KEEPALIVE, values[])
        else
            v = unsafe_wrap(Array, Ptr{T}(values[]), szA...)
            if attachfinalizer
                return finalizer(v) do x
                    _jlfree(x)
                end
            else
                return v
            end
        end
    finally
        unlock(memlock)
    end
end

function _unpackdensematrix!(
    A::AbstractGBMatrix{T}; 
    desc = nothing, attachfinalizer = true
) where {T}
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
        if values[] ∈ keys(KEEPALIVE)
            v = pop!(KEEPALIVE, values[])
        else
            v = unsafe_wrap(Array, Ptr{T}(values[]), szA)
            if attachfinalizer
                v = finalizer(v) do x
                    _jlfree(x)
                end
            end
        end
        v
    finally
        unlock(memlock)
    end
    # eltype(M) == T || (M = copy(reinterpret(T, M)))
    if length(M) != length(A)
        resize!(M, length(A))
    end
    return reshape(M, szA[1], szA[2])::Matrix{T} # reshape may not be necessary.
end

function _unpackdensematrixR!(
    A::AbstractGBArray{T}; 
    desc = nothing, attachfinalizer = true
) where {T}
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
        if values[] ∈ keys(KEEPALIVE)
            return pop!(KEEPALIVE, values[])
        else
            v = unsafe_wrap(Array, Ptr{T}(values[]), szA)
            if attachfinalizer
                return finalizer(v) do x
                    _jlfree(x)
                end
            end
        end
    finally
        unlock(memlock)
    end
end

function _unpackcscmatrix!(
    A::AbstractGBArray{T}; 
    desc = nothing, incrementindices = true, attachfinalizer = true
) where {T}
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
    colptr, rowidx, vals = try
        if values[] ∈ keys(KEEPALIVE) && colptr[] ∈ keys(KEEPALIVE) && rowidx[] ∈ keys(KEEPALIVE)
            x = (pop!(KEEPALIVE, colptr[]), pop!(KEEPALIVE, rowidx[]), pop!(KEEPALIVE, values[]))
        else
            colvector = unsafe_wrap(Array, Ptr{Int64}(colptr[]), size(A, 2) + 1)
            rowvector = unsafe_wrap(Array, Ptr{Int64}(rowidx[]), nnonzeros)
            v = unsafe_wrap(Array, Ptr{T}(values[]), nnonzeros)
            if attachfinalizer
                colvector = finalizer(colvector) do x
                    _jlfree(x)
                end
                rowvector = finalizer(rowvector) do x
                    _jlfree(x)
                end
                v = finalizer(v) do x
                    _jlfree(x)
                end
            end
            x = (colvector, rowvector, v)
        end
        x
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
    return colptr, rowidx, vals
end

function _unpackcsrmatrix!(
    A::AbstractGBArray{T}; 
    desc = nothing, incrementindices = true, attachfinalizer = true
) where {T}
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
    rowptr, colidx, vals = try
        if values[] ∈ keys(KEEPALIVE) && rowptr[] ∈ keys(KEEPALIVE) && colidx[] ∈ keys(KEEPALIVE)
            x = (pop!(KEEPALIVE, colptr[]), pop!(KEEPALIVE, rowidx[]), pop!(KEEPALIVE, values[]))
        else
            rowvector = unsafe_wrap(Array, Ptr{Int64}(rowptr[]), size(A, 1) + 1)
            colvector = unsafe_wrap(Array, Ptr{Int64}(rowidx[]), colidxsize[])
            v = unsafe_wrap(Array, Ptr{T}(values[]), nnz)
            if attachfinalizer
                rowvector = finalizer(rowvector) do x
                    _jlfree(x)
                end
                colvector = finalizer(colvector) do x
                    _jlfree(x)
                end
                v = finalizer(v) do x
                    _jlfree(x)
                end
            end
            x = (rowvector, colvector, v)
        end
        x
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

function unpack!(
    A::AbstractGBVector{T}, ::Dense; 
    order = ColMajor(), attachfinalizer = true
) where {T}
    wait(A)
    sparsity = sparsitystatus(A)
    sparsity === Dense() || (A .+= (similar(A) .= zero(T)))
    if order === ColMajor()
        return _unpackdensematrix!(A; attachfinalizer)::Vector{T}
    else
        return _unpackdensematrixR!(A; attachfinalizer)::Vector{T}
    end
end

function unpack!(
    A::AbstractGBMatrix{T}, ::Dense; 
    order = ColMajor(), attachfinalizer = true) where {T}
    wait(A)
    sparsity = sparsitystatus(A)
    sparsity === Dense() || (A .+= (similar(A) .= zero(T)))
    if order === ColMajor()
        return _unpackdensematrix!(A; attachfinalizer)::Matrix{T}
    else
        return _unpackdensematrixR!(A; attachfinalizer)::Matrix{T}
    end
end

function unpack!(A::AbstractGBArray, ::Type{Vector}; attachfinalizer = true)
    reshape(unpack!(A, Dense(); attachfinalizer), :)::Vector{T}
end
unpack!(A::AbstractGBArray, ::Type{Matrix}; attachfinalizer = true) = unpack!(A, Dense(); attachfinalizer)

function unpack!(
    A::AbstractGBArray{T}, ::Sparse; 
    order = ColMajor(), incrementindices = true, attachfinalizer = true
) where {T}
    wait(A)
    if order === ColMajor()
        return _unpackcscmatrix!(A; incrementindices, attachfinalizer)::Tuple{Vector{Int64}, Vector{Int64}, Vector{T}}
    else
        return _unpackcsrmatrix!(A; incrementindices, attachfinalizer)::Tuple{Vector{Int64}, Vector{Int64}, Vector{T}}
    end
end
unpack!(A::AbstractGBArray, ::Type{SparseMatrixCSC}; attachfinalizer = true) = 
    SparseMatrixCSC(size(A)..., unpack!(A, Sparse(); attachfinalizer)...)

# remove colptr for this, colptr doesn't really exist anyway, it should just be [0] (or [1] in 1-based).
unpack!(A::AbstractGBVector, ::Type{SparseVector}; attachfinalizer = true) = 
    SparseVector(size(A)..., unpack!(A, Sparse(); attachfinalizer)[2:end]...)

function unpack!(A::AbstractGBArray; attachfinalizer = true)
    sparsity, order = format(A)
    return unpack!(A, sparsity; order, attachfinalizer)
end

# TODO: BITMAP && HYPER
# TODO: A repack! api?