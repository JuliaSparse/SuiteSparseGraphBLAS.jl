const Packable{T} = Union{DenseVecOrMat{T}, Ptr{T}, Ref{T}}

function _packdensematrix!(A::AbstractGBArray{T}, M::Packable{T}; desc = nothing) where {T}
    desc = _handledescriptor(desc)
    Csize = length(A) * sizeof(T)
    values = Ref{Ptr{Cvoid}}(M isa DenseVecOrMat ? pointer(M) : M)
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

function _packdensematrixR!(A::AbstractGBArray{T}, M::Packable{T}; desc = nothing) where {T}
    desc = _handledescriptor(desc)
    Csize = length(A) * sizeof(T)
    values = Ref{Ptr{Cvoid}}(M isa DenseVecOrMat ? pointer(M) : M)
    isuniform = false
    @wraperror LibGraphBLAS.GxB_Matrix_pack_FullR(
        gbpointer(A),
        values,
        Csize,
        isuniform,
        desc
    )
    return A
end

function _packcscmatrix!(
    A::AbstractGBArray{T},
    colptr::Packable{Ti},
    rowidx::Packable{Ti},
    values::Packable{T};
    desc = nothing,
    colptrsize = length(colptr) * sizeof(LibGraphBLAS.GrB_Index),
    rowidxsize = length(rowidx) * sizeof(LibGraphBLAS.GrB_Index),
    valsize = length(values) * sizeof(T),
    rebaseindices = true
    ) where {T, Ti}
    rebaseindices && colptr isa DenseVecOrMat && decrement!(colptr)
    rebaseindices && rowidx isa DenseVecOrMat && decrement!(rowidx)

    colptr = Ref{Ptr{LibGraphBLAS.GrB_Index}}(colptr isa DenseVecOrMat ? pointer(colptr) : colptr)
    rowidx = Ref{Ptr{LibGraphBLAS.GrB_Index}}(rowidx isa DenseVecOrMat ? pointer(rowidx) : rowidx)
    values = Ref{Ptr{Cvoid}}(values isa DenseVecOrMat ? pointer(values) : values)
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
    rowptr::Packable{Ti},
    colidx::Packable{Ti},
    values::Packable{T};
    desc = nothing,
    rowptrsize = length(rowptr) * sizeof(LibGraphBLAS.GrB_Index),
    colidxsize = length(colidx) * sizeof(LibGraphBLAS.GrB_Index),
    valsize = length(values) * sizeof(T),
    rebaseindices = true
    ) where {T, Ti}
    rebaseindices && rowptr isa DenseVecOrMat && decrement!(rowptr)
    rebaseindices && colidx isa DenseVecOrMat && decrement!(colidx)

    rowptr = Ref{Ptr{LibGraphBLAS.GrB_Index}}(rowptr isa DenseVecOrMat ? pointer(rowptr) : rowptr)
    colidx = Ref{Ptr{LibGraphBLAS.GrB_Index}}(colidx isa DenseVecOrMat ? pointer(colidx) : colidx)
    values = Ref{Ptr{Cvoid}}(values isa DenseVecOrMat ? pointer(values) : values)
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

function pack!(A::AbstractGBArray, M::Packable; order = ColMajor(), shallow = true)
    if order === ColMajor()
        _packdensematrix!(A, M)
    else
        _packdensematrixR!(A, M)
    end
    shallow && _makeshallow!(A)
    return A
end

function pack!(
    A::AbstractGBArray, ptr::Packable, idx::Packable, values::Packable; 
    order = ColMajor(), shallow = true, rebaseindices = true
)
    if order === ColMajor()
        _packcscmatrix!(A, ptr, idx, values; rebaseindices)
    else
        _packcsrmatrix!(A, ptr, idx, values; rebaseindices)
    end
    shallow && _makeshallow!(A)
    return A
end