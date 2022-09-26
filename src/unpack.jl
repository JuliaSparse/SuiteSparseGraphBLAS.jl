function _unpackdensematrix!(
    A::AbstractGBVector{T}; 
    desc = nothing, attachfinalizer = false, allowiso = false
) where {T}
    szA = size(A)
    desc = _handledescriptor(desc)
    Csize = Ref{LibGraphBLAS.GrB_Index}(length(A) * sizeof(T))
    values = Ref{Ptr{Cvoid}}(C_NULL)
    isiso = Ref{Bool}(allowiso ? true : C_NULL)
    @wraperror LibGraphBLAS.GxB_Matrix_unpack_FullC(
        A,
        values,
        Csize,
        isiso,
        desc
    )
    v = unsafe_wrap(Array, Ptr{T}(values[]), szA)
    if attachfinalizer
        return finalizer(v) do x
            _jlfree(x)
        end
    else
        return v
    end
end

function _unpackdensematrix!(
    A::AbstractGBMatrix{T}; 
    desc = nothing, attachfinalizer = false, allowiso = false
) where {T}
    szA = size(A)
    desc = _handledescriptor(desc)
    Csize = Ref{LibGraphBLAS.GrB_Index}(length(A) * sizeof(T))
    values = Ref{Ptr{Cvoid}}(C_NULL)
    isiso = Ref{Bool}(allowiso ? true : C_NULL)
    @wraperror LibGraphBLAS.GxB_Matrix_unpack_FullC(
        A,
        values,
        Csize,
        isiso,
        desc
    )
    v = unsafe_wrap(Array, Ptr{T}(values[]), szA)
    if attachfinalizer
        v = finalizer(v) do x
            _jlfree(x)
        end
    end
    # eltype(M) == T || (M = copy(reinterpret(T, M)))
    if length(v) != length(A)
        resize!(v, length(A))
    end
    return reshape(v, szA[1], szA[2])::Matrix{T} # reshape may not be necessary.
end

function _unpackdensematrixR!(
    A::AbstractGBArray{T}; 
    desc = nothing, attachfinalizer = false, allowiso = false
) where {T}
    szA = size(A)
    desc = _handledescriptor(desc)
    Csize = Ref{LibGraphBLAS.GrB_Index}(length(A) * sizeof(T))
    values = Ref{Ptr{Cvoid}}(C_NULL)
    isiso = Ref{Bool}(allowiso ? true : C_NULL)
    @wraperror LibGraphBLAS.GxB_Matrix_unpack_FullR(
        A,
        values,
        Csize,
        isiso,
        desc
    )
    v = unsafe_wrap(Array, Ptr{T}(values[]), szA)
    if attachfinalizer
        return finalizer(v) do x
            _jlfree(x)
        end
    end
end

function _unpackcscmatrix!(
    A::AbstractGBArray{T}; 
    desc = nothing, incrementindices = true, attachfinalizer = false, allowiso = false
) where {T}
    desc = _handledescriptor(desc)
    colptr = Ref{Ptr{LibGraphBLAS.GrB_Index}}(C_NULL)
    rowidx = Ref{Ptr{LibGraphBLAS.GrB_Index}}(C_NULL)
    values = Ref{Ptr{Cvoid}}(C_NULL)
    colptrsize = Ref{LibGraphBLAS.GrB_Index}()
    rowidxsize = Ref{LibGraphBLAS.GrB_Index}()
    valsize = Ref{LibGraphBLAS.GrB_Index}()
    isiso = Ref{Bool}(allowiso ? true : C_NULL)
    isjumbled = C_NULL
    nnonzeros = nnz(A)
    @wraperror LibGraphBLAS.GxB_Matrix_unpack_CSC(
        A,
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
    colptr = unsafe_wrap(Array, Ptr{Int64}(colptr[]), size(A, 2) + 1)
    rowidx = unsafe_wrap(Array, Ptr{Int64}(rowidx[]), nnonzeros)
    nstored = isiso[] ? 1 : nnonzeros
    vals = unsafe_wrap(Array, Ptr{T}(values[]), nstored)

    if attachfinalizer
        colptr = finalizer(colptr) do x
            _jlfree(x)
        end
        rowidx = finalizer(rowidx) do x
            _jlfree(x)
        end
        vals = finalizer(vals) do x
            _jlfree(x)
        end
    end

    if incrementindices
        increment!(colptr)
        increment!(rowidx)
    end
    return colptr, rowidx, vals
end

function _unpackcsrmatrix!(
    A::AbstractGBArray{T}; 
    desc = nothing, incrementindices = true, attachfinalizer = false, allowiso = false
) where {T}
    desc = _handledescriptor(desc)
    rowptr = Ref{Ptr{LibGraphBLAS.GrB_Index}}(C_NULL)
    colidx = Ref{Ptr{LibGraphBLAS.GrB_Index}}(C_NULL)
    values = Ref{Ptr{Cvoid}}(C_NULL)
    rowptrsize = Ref{LibGraphBLAS.GrB_Index}()
    colidxsize = Ref{LibGraphBLAS.GrB_Index}()
    valsize = Ref{LibGraphBLAS.GrB_Index}()
    isiso = Ref{Bool}(allowiso ? true : C_NULL)
    isjumbled = C_NULL
    nnonzeros = nnz(A)
    @wraperror LibGraphBLAS.GxB_Matrix_unpack_CSC(
        A,
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
    rowptr = unsafe_wrap(Array, Ptr{Int64}(rowptr[]), size(A, 1) + 1)
    colidx = unsafe_wrap(Array, Ptr{Int64}(rowidx[]), colidxsize[])
    nstored = isiso[] ? 1 : nnonzeros
    vals = unsafe_wrap(Array, Ptr{T}(values[]), nstored)
    if attachfinalizer
        rowptr = finalizer(rowptr) do x
            _jlfree(x)
        end
        colidx = finalizer(colidx) do x
            _jlfree(x)
        end
        vals = finalizer(vals) do x
            _jlfree(x)
        end
    end
    if incrementindices
        increment!(rowptr)
        increment!(colidx)
    end
    return resize!(rowptr, size(A, 1) + 1),
    colidx,
    vals
end

function _unpackbitmapmatrix!(
    A::AbstractGBArray{T};
    desc = nothing, attachfinalizer = false, allowiso = false
) where T
    szA = size(A)
    desc = _handledescriptor(desc)
    Csize = Ref{LibGraphBLAS.GrB_Index}(length(A) * sizeof(T))
    Bsize = Ref{LibGraphBLAS.GrB_Index}(length(A) * sizeof(Bool))
    values = Ref{Ptr{Cvoid}}(C_NULL)
    bytemap = Ref{Ptr{Bool}}(C_NULL)
    isiso = Ref{Bool}(allowiso ? true : C_NULL)
    nnz = Ref{LibGraphBLAS.GrB_Index}(nnz(A))
    @wraperror LibGraphBLAS.GxB_Matrix_unpack_BitmapC(
        A,
        bytemap,
        values,
        Bsize,
        Csize,
        isiso,
        nnz,
        desc
    )
    nstored = isiso[] ? 1 : szA
    v = unsafe_wrap(Array, Ptr{T}(values[]), nstored)
    b = unsafe_wrap(Array, bytemap[], szA)
    if attachfinalizer
        v = finalizer(v) do f
            _jlfree(f)
        end
        b = finalizer(b) do f
            _jlfree(f)
        end
    end
    return v, b
end

function _unpackbitmapmatrixR!(
    A::AbstractGBArray{T};
    desc = nothing, attachfinalizer = false, allowiso = false
) where T
    szA = size(A)
    desc = _handledescriptor(desc)
    Csize = Ref{LibGraphBLAS.GrB_Index}(length(A) * sizeof(T))
    Bsize = Ref{LibGraphBLAS.GrB_Index}(length(A) * sizeof(Int8))
    values = Ref{Ptr{Cvoid}}(C_NULL)
    bytemap = Ref{Ptr{Int8}}(C_NULL)
    isiso = Ref{Bool}(allowiso ? true : C_NULL)
    nonzeros = Ref{LibGraphBLAS.GrB_Index}(0)
    @wraperror LibGraphBLAS.GxB_Matrix_unpack_BitmapR(
        A,
        bytemap,
        values,
        Bsize,
        Csize,
        isiso,
        nonzeros,
        desc
    )
    nstored = isiso[] ? 1 : szA
    v = unsafe_wrap(Array, Ptr{T}(values[]), nstored)
    b = unsafe_wrap(Array, bytemap[], szA)
    if attachfinalizer
        v = finalizer(v) do f
            _jlfree(f)
        end
        b = finalizer(b) do f
            _jlfree(f)
        end
    end
    return v, b
end

function _unpackhypermatrix!(
    A::AbstractGBArray{T};
    desc = nothing, incrementindices = false, attachfinalizer = false, allowiso = false
) where T
    desc = _handledescriptor(desc)
    colptr = Ref{Ptr{LibGraphBLAS.GrB_Index}}(C_NULL)
    colidx = Ref{Ptr{LibGraphBLAS.GrB_Index}}(C_NULL)
    rowidx = Ref{Ptr{LibGraphBLAS.GrB_Index}}(C_NULL)
    values = Ref{Ptr{Cvoid}}(C_NULL)
    colptrsize = Ref{LibGraphBLAS.GrB_Index}()
    colidxsize = Ref{LibGraphBLAS.GrB_Index}()
    rowidxsize = Ref{LibGraphBLAS.GrB_Index}()
    valsize = Ref{LibGraphBLAS.GrB_Index}()
    nvec = Ref{LibGraphBLAS.GrB_Index}()
    isiso = Ref{Bool}(allowiso ? true : C_NULL)
    isjumbled = C_NULL
    nnonzeros = nnz(A)

    @wraperror LibGraphBLAS.GxB_Matrix_unpack_HyperCSC(
        A,
        colptr,
        colidx,
        rowidx,
        values,
        colptrsize,
        colidxsize,
        rowidxsize,
        valsize,
        isiso,
        nvec,
        isjumbled,
        desc
    )
    colptr = unsafe_wrap(Array, Ptr{Int64}(colptr[]), size(A, 2) + 1)
    colidx = unsafe_wrap(Array, Ptr{Int64}(colidx), colidxsize[])
    rowidx = unsafe_wrap(Array, Ptr{Int64}(rowidx), nnonzeros)
    nstored = isiso[] ? 1 : nnonzeros
    vals = unsafe_wrap(Array, Ptr{T}(values[]), nstored)

    if attachfinalizer
        colptr = finalizer(colptr) do x
            _jlfree(x)
        end
        colidx = finalizer(colidx) do x
            _jlfree(x)
        end
        rowidx = finalizer(rowidx) do x
            _jlfree(x)
        end
        vals = finalizer(vals) do x
            _jlfree(x)
        end
    end
    
    if incrementindices
        increment!(colptr)
        increment!(colidx)
        increment!(rowidx)
    end
    return colptr, colidx, rowidx, vals
end

function _unpackhypermatrixR!(
    A::AbstractGBArray{T};
    desc = nothing, incrementindices = false, attachfinalizer = false, allowiso = false
) where T
desc = _handledescriptor(desc)
    rowptr = Ref{Ptr{LibGraphBLAS.GrB_Index}}(C_NULL)
    rowidx = Ref{Ptr{LibGraphBLAS.GrB_Index}}(C_NULL)
    colidx = Ref{Ptr{LibGraphBLAS.GrB_Index}}(C_NULL)
    values = Ref{Ptr{Cvoid}}(C_NULL)
    rowptrsize = Ref{LibGraphBLAS.GrB_Index}()
    rowidxsize = Ref{LibGraphBLAS.GrB_Index}()
    colidxsize = Ref{LibGraphBLAS.GrB_Index}()
    valsize = Ref{LibGraphBLAS.GrB_Index}()
    nvec = Ref{LibGraphBLAS.GrB_Index}()
    isiso = Ref{Bool}(allowiso ? true : C_NULL)
    isjumbled = C_NULL
    nnonzeros = nnz(A)

    @wraperror LibGraphBLAS.GxB_Matrix_unpack_HyperCSC(
        A,
        rowptr,
        rowidx,
        colidx,
        values,
        rowptrsize,
        rowidxsize,
        colidxsize,
        valsize,
        isiso,
        nvec,
        isjumbled,
        desc
    )
    rowptr = unsafe_wrap(Array, Ptr{Int64}(rowptr[]), size(A, 2) + 1)
    rowidx = unsafe_wrap(Array, Ptr{Int64}(rowidx[]), rowidxsize[])
    colidx = unsafe_wrap(Array, Ptr{Int64}(colidx[]), nnonzeros)
    nstored = isiso[] ? 1 : nnonzeros
    vals = unsafe_wrap(Array, Ptr{T}(values[]), nstored)

    if attachfinalizer
        rowptr = finalizer(rowptr) do x
            _jlfree(x)
        end
        rowidx = finalizer(rowidx) do x
            _jlfree(x)
        end
        colidx = finalizer(colidx) do x
            _jlfree(x)
        end
        vals = finalizer(vals) do x
            _jlfree(x)
        end
    end
    
    if incrementindices
        increment!(rowptr)
        increment!(rowidx)
        increment!(colidx)
    end
    return rowptr, rowidx, colidx, vals
end

function unsafeunpack!(
    A::AbstractGBVector{T}, ::Dense; 
    order = ColMajor(), attachfinalizer = false, incrementindices = false
) where {T}
    incrementindices && throw(ArgumentError("Cannot increment indices for Dense unpack."))
    wait(A)
    sparsity = sparsitystatus(A)
    sparsity === Dense() || (A .+= (similar(A) .= zero(T)))
    if order === ColMajor()
        return _unpackdensematrix!(A; attachfinalizer)::Vector{T}
    else
        return _unpackdensematrixR!(A; attachfinalizer)::Vector{T}
    end
end

function unsafeunpack!(
    A::AbstractGBMatrix{T}, ::Dense; 
    order = ColMajor(), attachfinalizer = false, incrementindices = false
) where {T}
    incrementindices && throw(ArgumentError("Cannot increment indices for Dense unpack."))
    wait(A)
    sparsity = sparsitystatus(A)
    sparsity === Dense() || (A .+= (similar(A) .= zero(T)))
    if order === ColMajor()
        return _unpackdensematrix!(A; attachfinalizer)::Matrix{T}
    else
        return _unpackdensematrixR!(A; attachfinalizer)::Matrix{T}
    end
end

function unsafeunpack!(
    A::AbstractGBArray, ::Type{Vector}; 
    order = ColMajor(), attachfinalizer = false, incrementindices = false
    )
    reshape(unsafeunpack!(A, Dense(); attachfinalizer, order, incrementindices), :)::Vector{T}
end

unsafeunpack!(
    A::AbstractGBArray, ::Type{Matrix}; 
    attachfinalizer = false, order = ColMajor(), incrementindices = false
) = unsafeunpack!(A, Dense(); order, incrementindices, attachfinalizer)

function unsafeunpack!(
    A::AbstractGBArray, ::Bytemap;
    attachfinalizer = false, order = ColMajor(), incrementindices = false
)
    incrementindices && throw(ArgumentError("Cannot increment indices for Bytemap unpack."))
    wait(A)
     if order === ColMajor()
        return _unpackbitmapmatrix!(A; attachfinalizer)
     else
        return _unpackbitmapmatrixR!(A; attachfinalizer)
     end
end

function unsafeunpack!(
    A::AbstractGBArray{T}, ::Sparse; 
    order = ColMajor(), incrementindices = true, attachfinalizer = false
) where {T}
    wait(A)
    if order === ColMajor()
        return _unpackcscmatrix!(A; incrementindices, attachfinalizer)::Tuple{Vector{Int64}, Vector{Int64}, Vector{T}}
    else
        return _unpackcsrmatrix!(A; incrementindices, attachfinalizer)::Tuple{Vector{Int64}, Vector{Int64}, Vector{T}}
    end
end
unsafeunpack!(A::AbstractGBArray, ::Type{SparseMatrixCSC}; attachfinalizer = false) = 
    SparseMatrixCSC(size(A)..., unsafeunpack!(A, Sparse(); attachfinalizer)...)

# remove colptr for this, colptr doesn't really exist anyway, it should just be [0] (or [1] in 1-based).
unsafeunpack!(A::AbstractGBVector, ::Type{SparseVector}; attachfinalizer = false) = 
    SparseVector(size(A)..., unsafeunpack!(A, Sparse(); attachfinalizer)[2:end]...)

function unsafeunpack!(A::AbstractGBArray; attachfinalizer = false, )
    sparsity, order = format(A)
    return unsafeunpack!(A, sparsity; order, attachfinalizer)
end

function unsafeunpack!(
    A::AbstractGBArray, ::Hypersparse;
    attachfinalizer = false, order = ColMajor(), incrementindices = false
)
    wait(A)
    if order === ColMajor()
        return _unpackhypermatrix!(A; incrementindices, attachfinalizer)
    else
        return _unpackhypermatrixR!(A; incrementindices, attachfinalizer)
    end
end



# we will never attachfinalizer here because it is assumed that this is a temporary unpack.
function tempunpack!(A::AbstractGBArray, sparsity::Dense; order = ColMajor(), incrementindices = false)
    shallowA = isshallow(A)
    out = unsafeunpack!(A, sparsity; order, incrementindices)
    function repack!(mat = out, shallow = shallowA; order = order, decrementindices = incrementindices)
        return unsafepack!(A, mat, shallow; order, decrementindices)
    end
    return (out, repack!)
end

# we will never attachfinalizer here because it is assumed that this is a temporary unpack.
function tempunpack!(A::AbstractGBArray, sparsity::Bytemap; order = ColMajor(), incrementindices = false)
    shallowA = isshallow(A)
    bytemap, values = unsafeunpack!(A, sparsity; order, incrementindices)
    function repack!(bytemap = bytemap, values = values, shallow = shallowA; 
        order = order, decrementindices = incrementindices)
        return unsafepack!(A, bytemap, values, shallow; order, decrementindices)
    end
    return (bytemap, values, repack!)
end

function tempunpack!(A::AbstractGBArray, sparsity::Sparse; order = ColMajor(), incrementindices = false)
    shallowA = isshallow(A)
    ptr, idx, nzval = unsafeunpack!(A, sparsity; order, incrementindices)
    function repack!(ptr = ptr, idx = idx, nzval = nzval, shallow = shallowA;
        order = order, decrementindices = incrementindices)
        return unsafepack!(A, ptr, idx, nzval, shallow; order, decrementindices)
    end
    return (ptr, idx, nzval, repack!)
end

function tempunpack!(A::AbstractGBArray, sparsity::Hypersparse; order = ColMajor(), incrementindices = false)
    shallowA = isshallow(A)
    ptr, idx1, idx2, nzval = unsafeunpack!(A, sparsity; order, incrementindices)
    function repack!(ptr = ptr, idx1 = idx1, idx2 = idx2, nzval = nzval, shallow = shallowA;
        order = order, decrementindices = incrementindices)
        return unsafepack!(A, ptr, idx1, idx2, nzval, shallow; order, decrementindices)
    end
    return (ptr, idx1, idx2, nzval, repack!)
end

function tempunpack_noformat!(A::AbstractGBArray, incrementindices = false)
    sparsity, order = format(A)
    return tempunpack!(A, sparsity; order, incrementindices)
end

# TODO: BITMAP && HYPER
# TODO: A reunsafepack! api?