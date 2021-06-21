function exportdensematrix!(
    A::GBMatrix{T};
    desc::Descriptor = Descriptors.NULL
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
    C = Matrix{T}(undef, nrows[], ncols[])
    unsafe_copyto!(pointer(C), Ptr{T}(values[]), length(C))
    Libc.free(values[])
    return C
end
function exportdensematrix(A::GBMatrix; desc::Descriptor = Descriptors.NULL)
    exportdensematrix!(copy(A); desc)
end
function Matrix(A::GBMatrix)
    return exportdensematrix(A)
end

function exportcscmatrix!(
    A::GBMatrix{T};
    desc::Descriptor = Descriptors.NULL
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
    t = t[]
    nrows = nrows[]
    ncols = ncols[]
    colptr = colptr[]
    rowidx = rowidx[]
    colptrsize = colptrsize[]
    rowidxsize = rowidxsize[]
    Axsize = Axsize[]
    outvalues = Vector{T}(undef, Axsize ÷ sizeof(T))
    col = Vector{libgb.GrB_Index}(undef, Int(colptrsize ÷ sizeof(libgb.GrB_Index)))
    row = Vector{libgb.GrB_Index}(undef, Int(rowidxsize ÷ sizeof(libgb.GrB_Index)))
    unsafe_copyto!(pointer(outvalues), Ptr{T}(values[]), length(outvalues))
    unsafe_copyto!(pointer(col), Ptr{libgb.GrB_Index}(colptr), length(col))
    unsafe_copyto!(pointer(row), Ptr{libgb.GrB_Index}(rowidx), length(row))
    Libc.free(colptr)
    Libc.free(rowidx)
    Libc.free(values[])
    return SparseArrays.SparseMatrixCSC(nrows, ncols, col .+ 1, row .+ 1, outvalues)
end

function exportcscmatrix(A::GBMatrix; desc::Descriptor = Descriptors.NULL)
    return exportcscmatrix!(copy(A); desc)
end

function SparseArrays.SparseMatrixCSC(A::GBMatrix; desc::Descriptor = Descriptors.NULL)
    return exportcscmatrix(A; desc)
end
function exportdensevec!(
    v::GBVector{T};
    desc::Descriptor = Descriptors.NULL
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
    v = Vector{T}(undef, n[])
    unsafe_copyto!(pointer(v), Ptr{T}(values[]), length(v))
    Libc.free(values[])
    return v
end

function exportdensevec(v::GBVector; desc::Descriptor = Descriptors.NULL)
    v = copy(v)
    return exportdensevec!(v; desc)
end

function Vector(v::GBVector)
    return exportdensevec(v)
end
