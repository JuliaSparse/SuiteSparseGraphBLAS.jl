function _unpackdensematrix!(A::GBVecOrMat{T}; desc = nothing) where {T}
    desc = _handledescriptor(desc)
    Csize = Ref{LibGraphBLAS.GrB_Index}(length(A) * sizeof(T))
    values = Ref{Ptr{Cvoid}}(Ptr{T}())
    isiso = Ref{Bool}(false)
    @wraperror LibGraphBLAS.GxB_Matrix_unpack_FullC(
        A.p,
        values,
        Csize,
        isiso,
        desc
    )
    return unsafe_wrap(Array{T}, Ptr{T}(values[]), size(A))
end

function _unpackcscmatrix!(A::GBVecOrMat{T}; desc = nothing) where {T}
    desc = _handledescriptor(desc)
    colptr = Ref{Ptr{LibGraphBLAS.GrB_Index}}()
    rowidx = Ref{Ptr{LibGraphBLAS.GrB_Index}}()
    values = Ref{Ptr{Cvoid}}(Ptr{T}())
    colptrsize = Ref{LibGraphBLAS.GrB_Index}()
    rowidxsize = Ref{LibGraphBLAS.GrB_Index}()
    valsize = Ref{LibGraphBLAS.GrB_Index}()
    isiso = Ref{Bool}(false)
    isjumbled = Ref{Bool}(false)
    @wraperror LibGraphBLAS.GxB_Matrix_unpack_CSC(
        A.p,
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
    colptr = unsafe_wrap(Array{LibGraphBLAS.GrB_Index}, colptr[], colptrsize[] ÷ sizeof(LibGraphBLAS.GrB_Index))
    rowidx = unsafe_wrap(Array{LibGraphBLAS.GrB_Index}, rowidx[], rowidxsize[] ÷ sizeof(LibGraphBLAS.GrB_Index))
    colptr .+= 1
    rowidx .+= 1
    return colptr,
    rowidx,
    unsafe_wrap(Array{T}, Ptr{T}(values[]), valsize[] ÷ sizeof(T))
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
    isjumbled = Ref{Bool}(false)
    @wraperror LibGraphBLAS.GxB_Matrix_unpack_CSR(
        A.p,
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
    rowptr = unsafe_wrap(Array{LibGraphBLAS.GrB_Index}, rowptr[], rowptrsize[] ÷ sizeof(LibGraphBLAS.GrB_Index))
    colidx = unsafe_wrap(Array{LibGraphBLAS.GrB_Index}, colidx[], colidxsize[] ÷ sizeof(LibGraphBLAS.GrB_Index))
    rowptr .+= 1
    colidx .+= 1
    return rowptr,
    colidx,
    unsafe_wrap(Array{T}, Ptr{T}(values[]), valsize[] ÷ sizeof(T))
end
