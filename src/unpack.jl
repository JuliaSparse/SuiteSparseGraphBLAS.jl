function _unpackdensematrix!(A::GBVecOrMat{T}; desc = nothing) where {T}
    desc = _handledescriptor(desc)
    Csize = Ref{libgb.GrB_Index}(length(A) * sizeof(T))
    values = Ref{Ptr{Cvoid}}(Ptr{T}())
    isiso = Ref{Bool}(false)
    libgb.GxB_Matrix_unpack_FullC(
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
    colptr = Ref{Ptr{libgb.GrB_Index}}()
    rowidx = Ref{Ptr{libgb.GrB_Index}}()
    values = Ref{Ptr{Cvoid}}(Ptr{T}())
    colptrsize = Ref{libgb.GrB_Index}()
    rowidxsize = Ref{libgb.GrB_Index}()
    valsize = Ref{libgb.GrB_Index}()
    isiso = Ref{Bool}(false)
    isjumbled = Ref{Bool}(false)
    libgb.GxB_Matrix_unpack_CSC(
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
    colptr = unsafe_wrap(Array{libgb.GrB_Index}, colptr[], colptrsize[] ÷ sizeof(libgb.GrB_Index))
    rowidx = unsafe_wrap(Array{libgb.GrB_Index}, rowidx[], rowidxsize[] ÷ sizeof(libgb.GrB_Index))
    colptr .+= 1
    rowidx .+= 1
    return colptr,
    rowidx,
    unsafe_wrap(Array{T}, Ptr{T}(values[]), valsize[] ÷ sizeof(T))
end
