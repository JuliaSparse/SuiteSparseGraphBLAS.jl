function _unpackdensematrix!(A::AbstractGBArray{T}; desc = nothing) where {T}
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
    return unsafe_wrap(Array, Ptr{T}(values[]), szA)
    # lock(memlock)
    # M = try
    #     pop!(PTRTOJL, values[])
    # finally
    #     unlock(memlock)
    # end
    # return size(A, 2) == 1 ? reshape(M, :) : reshape(M, szA)
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
    return unsafe_wrap(Array, values[], szA)
    # lock(memlock)
    # M = try
    #     pop!(PTRTOJL, values[])
    # finally
    #     unlock(memlock)
    # end
    # return size(A, 2) == 1 ? reshape(M, :) : reshape(M, szA)
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
    # lock(memlock)
    # colptr, rowidx = try
    #     (pop!(PTRTOJL, colptr[]), pop!(PTRTOJL, rowidx[]))
    # finally
    #     unlock(memlock)
    # end
    # lock(memlock)
    # vals = try
    #     pop!(PTROJL, values[])
    # finally
    #     unlock(memlock)
    # end
    colptr = unsafe_wrap(Array{Int64}, Ptr{Int64}(colptr[]), size(A, 2) + 1)
    rowidx = unsafe_wrap(Array{Int64}, Ptr{Int64}(rowidx[]), nnonzeros)

    # if isiso[]
    #     vals = fill(vals[1], nnonzeros)
    # end
    if isiso[]
        val = unsafe_wrap(Array{T}, Ptr{T}(values[]), 1)[1]
        vals = ccall(:jl_realloc, Ptr{Cvoid}, (Ptr{T}, Int64), Ptr{T}(values[]), nnonzeros * sizeof(T))
        vals = unsafe_wrap(Array{T}, Ptr{T}(vals), nnonzeros)
        vals .= val
    else
        vals = unsafe_wrap(Array{T}, Ptr{T}(values[]), nnonzeros)
    end
    if incrementindices
        increment!(colptr)
        increment!(rowidx)
    end
    return colptr,
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
    @wraperror LibGraphBLAS.GxB_Matrix_unpack_CSR(
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
    # lock(memlock)
    # rowptr, colidx = try
    #     (pop!(PTRTOJL, rowptr[]), pop!(PTRTOJL, colidx[]))
    # finally
    #     unlock(memlock)
    # end
    # lock(memlock)
    # vals = try
    #     pop!(PTROJL, values[])
    # finally
    #     unlock(memlock)
    # end
    # if isiso[]
    #     vals = fill(vals[1], nnonzeros)
    # end

    rowptr = unsafe_wrap(Array{Int64}, Ptr{Int64}(rowptr[]), size(A, 1) + 1)
    colidx = unsafe_wrap(Array{Int64}, Ptr{Int64}(colidx[]), nnonzeros)

    if isiso[]
        val = unsafe_wrap(Array{T}, Ptr{T}(values[]), 1)[1]
        vals = ccall(:jl_realloc, Ptr{Cvoid}, (Ptr{T}, Int64), Ptr{T}(values[]), nnonzeros * sizeof(T))
        vals = unsafe_wrap(Array{T}, Ptr{T}(vals), nnonzeros)
        vals .= val
        valsize = nnonzeros * sizeof(T)
    else
        vals = unsafe_wrap(Array{T}, Ptr{T}(values[]), nnonzeros)
        valsize = valsize[]
    end

    if incrementindices
        increment!(rowptr)
        increment!(colidx)
    end
    return rowptr,
    colidx,
    vals
end

function unpack!(A::AbstractGBArray{T, N, F}, ::Dense; order = ColMajor()) where {T, N, F}
    if sparsitystatus(A) !== Dense()
        X = similar(A)
        if T === F
            filler = A.fill
        else
            filler = zero(T)
        end
        if X isa GBVector
            X[:] = zero(T)
        else
            X[:,:] = zero(T)
        end
        eadd!(A, X, A; mask=A, desc = Descriptor(complement_mask=true, structural_mask=true))
        gbset(A, :sparsity_control, Dense())
    end
    wait(A)
    if order === ColMajor()
        return _unpackdensematrix!(A)
    else
        return _unpackdensematrixR!(A)
    end
end

function unpack!(A::AbstractGBVector, ::Type{Vector})
    unpack!(A, Dense())
end
unpack!(A::AbstractGBMatrix, ::Type{Matrix}) = unpack!(A, Dense())

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
function unpack!(A::AbstractGBVector, ::Type{SparseVector}) 
    colptr, rowidx, vals = unpack!(A, Sparse())
    _jlfree(colptr) # We need to free  this dangling [0]/[1] otherwise it will leak when we repack.
    # TODO: remove this when we switch to cheatmalloc.
    return SparseVector(size(A)..., rowidx, vals)
end

function unpack!(A::AbstractGBArray)
    sparsity, order = format(A)
    return unpack!(A, sparsity; order)
end


# TODO: BITMAP && HYPER
# TODO: A repack! api?