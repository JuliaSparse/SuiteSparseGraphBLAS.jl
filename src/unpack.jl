function _unpackdensematrix!(A::AbstractGBArray{T}; desc = nothing) where {T}
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
    return unsafe_wrap(Array{T}, Ptr{T}(values[]), size(A))
end

function _unpackcscmatrix!(A::AbstractGBArray{T}; desc = nothing) where {T}
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
    colptr = unsafe_wrap(Array{LibGraphBLAS.GrB_Index}, colptr[], size(A, 2) + 1)
    rowidx = unsafe_wrap(Array{LibGraphBLAS.GrB_Index}, rowidx[], nnonzeros)
    
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
    increment!(colptr)
    increment!(rowidx)
    return colptr,
    colptrsize[],
    rowidx,
    rowidxsize[],
    vals,
    valsize
end

function _unpackcsrmatrix!(A::GBVecOrMat{T}; desc = nothing) where {T}
    desc = _handledescriptor(desc)
    rowptr = Ref{Ptr{LibGraphBLAS.GrB_Index}}()
    colidx = Ref{Ptr{LibGraphBLAS.GrB_Index}}()
    values = Ref{Ptr{Cvoid}}(Ptr{T}())
    colidxsize = Ref{LibGraphBLAS.GrB_Index}()
    rowptrsize = Ref{LibGraphBLAS.GrB_Index}()
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
    #TODO IMPROVE
    # rowptrsize isn't always exact. Or rather it can be bigger if GrB has allocated a bigger block.
    # For now I'll unsafe_wrap based on size(A, 1) + 1
    rowptr = unsafe_wrap(Array{LibGraphBLAS.GrB_Index}, rowptr[],size(A, 1) + 1)
    colidx = unsafe_wrap(Array{LibGraphBLAS.GrB_Index}, colidx[], nnonzeros)

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
    increment!(rowptr)
    increment!(colidx)

    return rowptr,
    rowptrsize[],
    colidx,
    colidxsize[],
    vals,
    valsize
end
