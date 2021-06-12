function exportdensematrix(
    A::GBMatrix{T};
    desc::Descriptor = Descriptors.NULL
) where {T}
    nrows = Ref{libgb.GrB_Index}(size(A,1))
    ncols = Ref{libgb.GrB_Index}(size(A,2))
    Csize = Ref{libgb.GrB_Index}(length(A) * sizeof(T))
    Cx = Ptr{T}(Libc.malloc(length(A) * sizeof(T)))
    CRef = Ref{Ptr{Cvoid}}(Cx)
    isuniform = Ref{Bool}(false)
    libgb.GxB_Matrix_export_FullC(
        Ref(A.p),
        Ref(toGBType(T).p),
        nrows,
        ncols,
        CRef,
        Csize,
        isuniform,
        desc
    )
    C = Matrix{T}(undef, nrows[], ncols[])
    unsafe_copyto!(pointer(C), Ptr{T}(CRef[]), length(C))
    return C
end

function Matrix(A::GBMatrix)
    return exportdensematrix(A)
end

function exportcscmatrix(
    A::GBMatrix{T};
    desc::Descriptor = Descriptors.NULL
    ) where {T}
    nrows = Ref{libgb.GrB_Index}()
    ncols = Ref{libgb.GrB_Index}()
    t = Ref{libgb.GrB_Type}()
    colptr = Ref{Ptr{libgb.GrB_Index}}()
    rowidx = Ref{Ptr{libgb.GrB_Index}}()
    Ax = Ref{Ptr{T}}()
    colptrsize = Ref{libgb.GrB_Index}()
    rowidxsize = Ref{libgb.GrB_Index}()
    Axsize = Ref{libgb.GrB_Index}()
    isuniform = Ref{Bool}(false)
    isjumbled = C_NULL
    
    libgb.GxB_Matrix_export_CSC(A.p, t, nrows, ncols, colptr, rowidx, Ax, colptrsize, rowidxsize, Axsize, isuniform, isjumbled, desc)
    A.p = C_NULL
    t = t[]
    nrows = nrows[]
    ncols = ncols[]
    colptr = colptr[]
    rowidx = rowidx[]
    Ax = Ax[]
    colptrsize = colptrsize[]
    rowidxsize = rowidxsize[]
    Axsize = Axsize[]
    values = Vector{T}(undef, Axsize ÷ sizeof(T))
    col = Vector{libgb.GrB_Index}(colptrsize ÷ sizeof(libgb.GrB_Index))
    row = Vector{libgb.GrB_Index}(rowidxsize ÷ sizeof(libgb.GrB_Index))
    unsafe_copyto!(pointer(values), Ptr{T}(Ax), length(values))
    unsafe_copyto!(pointer(col), Ptr{libgb.GrB_Index}(colptr), length(col))
    unsafe_copyto!(pointer(row), Ptr{libgb.GrB_Index}(rowidx), length(row))
    return SparseMatrixCSC(nrows, ncols, col .+ 1, row .+ 1, values)
end

function SparseMatrixCSC(A::GBMatrix; desc::Descriptor = Descriptors.NULL)

function exportdensevec(
    v::GBVector{T};
    desc::Descriptor = Descriptors.NULL
    ) where {T}
    n = Ref{libgb.GrB_Index}(size(v,1))
    vsize = Ref{libgb.GrB_Index}(length(v) * sizeof(T))
    vx = Ptr{T}(Libc.malloc(length(v) * sizeof(T)))
    CRef = Ref{Ptr{Cvoid}}(vx)
    isuniform = Ref{Bool}(false)
    libgb.GxB_Vector_export_Full(
        Ref(v.p),
        Ref(toGBType(T).p),
        n,
        CRef,
        vsize,
        isuniform,
        desc
    )
    v = Vector{T}(undef, n[])
    unsafe_copyto!(pointer(v), Ptr{T}(CRef[]), length(v))
    return v
end

function Vector(v::GBVector)
    return exportdensevec(v)
end
