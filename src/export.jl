
function _exportdensematrix!(
    A::GBVecOrMat{T};
    desc = nothing
) where {T}
    desc = _handledescriptor(desc)
    nrows = Ref{libgb.GrB_Index}(size(A,1))
    ncols = Ref{libgb.GrB_Index}(size(A,2))
    Csize = Ref{libgb.GrB_Index}(length(A) * sizeof(T))
    values = Ref{Ptr{Cvoid}}(Ptr{T}())
    isuniform = Ref{Bool}(false)
    libgb.GxB_Matrix_export_FullC(
        Ref(A.p),
        Ref(toGBType(T).p),
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
    nrows = Ref{libgb.GrB_Index}(size(A, 1))
    ncols = Ref{libgb.GrB_Index}(size(A, 2))
    t = Ref{libgb.GrB_Type}(toGBType(T).p)
    colptr = Ref{Ptr{libgb.GrB_Index}}()
    rowidx = Ref{Ptr{libgb.GrB_Index}}()
    values = Ref{Ptr{Cvoid}}(Ptr{T}())
    colptrsize = Ref{libgb.GrB_Index}()
    rowidxsize = Ref{libgb.GrB_Index}()
    Axsize = Ref{libgb.GrB_Index}()
    isuniform = Ref{Bool}(false)
    isjumbled = C_NULL

    libgb.GxB_Matrix_export_CSC(
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
#    col = Vector{libgb.GrB_Index}(undef, Int(colptrsize ÷ sizeof(libgb.GrB_Index)))
#    row = Vector{libgb.GrB_Index}(undef, Int(rowidxsize ÷ sizeof(libgb.GrB_Index)))
#    unsafe_copyto!(pointer(outvalues), Ptr{T}(val), length(outvalues))
#    unsafe_copyto!(pointer(col), Ptr{libgb.GrB_Index}(colptr), length(col))
#    unsafe_copyto!(pointer(row), Ptr{libgb.GrB_Index}(rowidx), length(row))
#    ccall(:jl_free, Cvoid, (Ptr{libgb.GrB_Index},), colptr)
#    ccall(:jl_free, Cvoid, (Ptr{libgb.GrB_Index},), rowidx)
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
    n = Ref{libgb.GrB_Index}(size(v,1))
    vsize = Ref{libgb.GrB_Index}(length(v) * sizeof(T))
    values = Ref{Ptr{Cvoid}}(Ptr{T}())
    isuniform = Ref{Bool}(false)
    libgb.GxB_Vector_export_Full(
        Ref(v.p),
        Ref(toGBType(T).p),
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
