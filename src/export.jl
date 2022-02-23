
function _exportdensematrix!(
    A::GBVecOrMat{T};
    desc = nothing
) where {T}
    desc = _handledescriptor(desc)
    nrows = Ref{LibGraphBLAS.GrB_Index}(size(A,1))
    ncols = Ref{LibGraphBLAS.GrB_Index}(size(A,2))
    Csize = Ref{LibGraphBLAS.GrB_Index}(length(A) * sizeof(T))
    values = Ref{Ptr{Cvoid}}(Ptr{T}())
    isuniform = Ref{Bool}(false)
    @wraperror LibGraphBLAS.GxB_Matrix_export_FullC(
        Ref(A.p),
        Ref(gbtype(T).p),
        nrows,
        ncols,
        values,
        Csize,
        isuniform,
        desc
    )
    A.p = C_NULL
    finalize(A)
    return nrows[], ncols[], values[]
end
function _exportdensematrix(A::GBMatrix; desc = nothing)
    return _exportdensematrix!(copy(A); desc)
end

function _exportcscmatrix!(
    A::GBMatrix{T};
    desc = nothing
    ) where {T}
    desc = _handledescriptor(desc)
    nrows = Ref{LibGraphBLAS.GrB_Index}(size(A, 1))
    ncols = Ref{LibGraphBLAS.GrB_Index}(size(A, 2))
    t = Ref{LibGraphBLAS.GrB_Type}(gbtype(T).p)
    colptr = Ref{Ptr{LibGraphBLAS.GrB_Index}}()
    rowidx = Ref{Ptr{LibGraphBLAS.GrB_Index}}()
    values = Ref{Ptr{Cvoid}}(Ptr{T}())
    colptrsize = Ref{LibGraphBLAS.GrB_Index}()
    rowidxsize = Ref{LibGraphBLAS.GrB_Index}()
    Axsize = Ref{LibGraphBLAS.GrB_Index}()
    isuniform = Ref{Bool}(false)
    isjumbled = C_NULL

    @wraperror LibGraphBLAS.GxB_Matrix_export_CSC(
        Ref(A.p),
        t,
        nrows,
        ncols,
        colptr,
        rowidx,
        values,
        colptrsize,
        rowidxsize,
        Axsize,
        isuniform,
        isjumbled,
        desc
    )
    A.p = C_NULL
    finalize(A)
    return (nrows[], ncols[], colptr[], rowidx[], colptrsize[], rowidxsize[], values[], Axsize[])
end

function _exportcscmatrix(A::GBMatrix; desc = nothing)
    return _exportcscmatrix!(copy(A); desc)
end

#function SparseArrays.SparseMatrixCSC(A::GBMatrix{T}; desc = nothing) where {T}
#    nrows, ncols, colptr, rowidx, colptrsize, rowidxsize, val, valsize = _exportcscmatrix(A; desc)
#    outvalues = Vector{T}(undef, valsize ÷ sizeof(T))
#    col = Vector{LibGraphBLAS.GrB_Index}(undef, Int(colptrsize ÷ sizeof(LibGraphBLAS.GrB_Index)))
#    row = Vector{LibGraphBLAS.GrB_Index}(undef, Int(rowidxsize ÷ sizeof(LibGraphBLAS.GrB_Index)))
#    unsafe_copyto!(pointer(outvalues), Ptr{T}(val), length(outvalues))
#    unsafe_copyto!(pointer(col), Ptr{LibGraphBLAS.GrB_Index}(colptr), length(col))
#    unsafe_copyto!(pointer(row), Ptr{LibGraphBLAS.GrB_Index}(rowidx), length(row))
#    ccall(:jl_free, Cvoid, (Ptr{LibGraphBLAS.GrB_Index},), colptr)
#    ccall(:jl_free, Cvoid, (Ptr{LibGraphBLAS.GrB_Index},), rowidx)
#    ccall(:jl_free, Cvoid, (Ptr{T},), val)
#    return SparseArrays.SparseMatrixCSC(nrows, ncols, col .+= 1, row .+= 1, outvalues)
#end
#function SparseArrays.SparseVector(A::GBMatrix{T}; desc = nothing) where {T}
#    SparseVector(SparseMatrixCSC(A; desc))
#end
#
#function SparseArrays.SparseVector(v::GBVector{T}; desc = nothing) where {T}
#    SparseVector(SparseMatrixCSC(GBMatrix(v); desc))
#end

function _exportdensevec!(
    v::GBVector{T};
    desc = nothing
    ) where {T}
    desc = _handledescriptor(desc)
    n = Ref{LibGraphBLAS.GrB_Index}(size(v,1))
    vsize = Ref{LibGraphBLAS.GrB_Index}(length(v) * sizeof(T))
    values = Ref{Ptr{Cvoid}}(Ptr{T}())
    isuniform = Ref{Bool}(false)
    @wraperror LibGraphBLAS.GxB_Vector_export_Full(
        Ref(v.p),
        Ref(gbtype(T).p),
        n,
        values,
        vsize,
        isuniform,
        desc
    )
    return n[], values[]
end

function _exportdensevec(v::GBVector; desc = nothing)
    return _exportdensevec!(copy(v); desc)
end
