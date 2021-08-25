
function _exportdensematrix!(
    A::GBMatrix{T};
    desc::Descriptor = DEFAULTDESC
) where {T}
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
function _exportdensematrix(A::GBMatrix; desc::Descriptor = DEFAULTDESC)
    return _exportdensematrix!(copy(A); desc)
end
function Base.Matrix(A::GBMatrix{T}) where {T}
    if gbget(A, SPARSITY_STATUS) != GBDENSE
        X = similar(A)
        X[:] = zero(A)
        A = eadd(X, A)
    end
    nrows, ncols, values = _exportdensematrix(A)
    C = Matrix{T}(undef, nrows, ncols)
    unsafe_copyto!(pointer(C), Ptr{T}(values), length(C))
    ccall(:jl_free, Cvoid, (Ptr{T},), values)
    return C
end

function _exportcscmatrix!(
    A::GBMatrix{T};
    desc::Descriptor = DEFAULTDESC
    ) where {T}
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
    nrows = nrows[]
    ncols = ncols[]
    colptr = colptr[]
    rowidx = rowidx[]
    colptrsize = colptrsize[]
    rowidxsize = rowidxsize[]
    Axsize = Axsize[]
    val = values[]
    return nrows, ncols, colptr, rowidx, colptrsize, rowidxsize, val, Axsize


end

function _exportcscmatrix(A::GBMatrix; desc::Descriptor = DEFAULTDESC)
    return _exportcscmatrix!(copy(A); desc)
end

function SparseArrays.SparseMatrixCSC(A::GBMatrix{T}; desc::Descriptor = DEFAULTDESC) where {T}
    nrows, ncols, colptr, rowidx, colptrsize, rowidxsize, val, valsize = _exportcscmatrix(A; desc)
    outvalues = Vector{T}(undef, valsize ÷ sizeof(T))
    col = Vector{libgb.GrB_Index}(undef, Int(colptrsize ÷ sizeof(libgb.GrB_Index)))
    row = Vector{libgb.GrB_Index}(undef, Int(rowidxsize ÷ sizeof(libgb.GrB_Index)))
    unsafe_copyto!(pointer(outvalues), Ptr{T}(val), length(outvalues))
    unsafe_copyto!(pointer(col), Ptr{libgb.GrB_Index}(colptr), length(col))
    unsafe_copyto!(pointer(row), Ptr{libgb.GrB_Index}(rowidx), length(row))
    ccall(:jl_free, Cvoid, (Ptr{libgb.GrB_Index},), colptr)
    ccall(:jl_free, Cvoid, (Ptr{libgb.GrB_Index},), rowidx)
    ccall(:jl_free, Cvoid, (Ptr{T},), val)
    return SparseArrays.SparseMatrixCSC(nrows, ncols, col .+= 1, row .+= 1, outvalues)
end

function _exportdensevec!(
    v::GBVector{T};
    desc::Descriptor = DEFAULTDESC
    ) where {T}
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

function _exportdensevec(v::GBVector; desc::Descriptor = DEFAULTDESC)
    return _exportdensevec!(copy(v); desc)
end

function Vector(v::GBVector{T}) where {T}
    n, vals = _exportdensevec(v)
    v = Vector{T}(undef, n)
    unsafe_copyto!(pointer(v), Ptr{T}(vals), length(v))
    ccall(:jl_free, Cvoid, (Ptr{T},), vals)
    return v
end
