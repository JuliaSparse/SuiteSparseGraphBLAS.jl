function importcscmat(
    m::Integer,
    n::Integer,
    colptr,
    rowindices,
    values::Vector{T};
    jumbled::Bool = false,
    desc::Descriptor = Descriptors.NULL
) where {T}
A = Ref{libgb.GrB_Matrix}()
m = libgb.GrB_Index(m)
n = libgb.GrB_Index(n)
colsize = libgb.GrB_Index(sizeof(colptr))
rowsize = libgb.GrB_Index(sizeof(rowindices))
valsize = libgb.GrB_Index(sizeof(values))

col = Ptr{libgb.GrB_Index}(Libc.malloc(colsize))
unsafe_copyto!(col, Ptr{UInt64}(pointer(colptr .- 1)), length(colptr))
row = Ptr{libgb.GrB_Index}(Libc.malloc(rowsize))
unsafe_copyto!(row, Ptr{UInt64}(pointer(rowindices .- 1)), length(rowindices))
val = Ptr{T}(Libc.malloc(valsize))
unsafe_copyto!(val, pointer(values), length(values))
libgb.GxB_Matrix_import_CSC(
    A,
    toGBType(T),
    m,
    n,
    Ref{Ptr{libgb.GrB_Index}}(col),
    Ref{Ptr{libgb.GrB_Index}}(row),
    Ref{Ptr{Cvoid}}(val),
    colsize,
    rowsize,
    valsize,
    false,
    jumbled,
    desc
)
return GBMatrix{T}(A[])
end

function GBMatrix(S::SparseMatrixCSC)
    return importcscmat(S.m, S.n, S.colptr, S.rowval, S.nzval)
end

function importcscvec(
    n::Integer, vi, vx::Vector{T};
    jumbled::Bool = false, desc::Descriptor = Descriptors.NULL
) where {T}
    v = Ref{libgb.GrB_Vector}
    n = libgb.GrB_Index(n)
    vi_size = libgb.GrB_Index(sizeof(vi))
    vx_size = libgb.GrB_Index(sizeof(vx))

    indices = Ptr{libgb.GrB_Index}(Libc.malloc(vi_size))
    unsafe_copyto!(indices, Ptr{UInt64}(pointer(vi .- 1)), length(vi))

    values = Ptr{libgb.GrB_Index}(Libc.malloc(vx_size))
    unsafe_copyto!(values, pointer(vx), length(vx))
    libgb.GxB_Vector_import_CSC(
        v,
        toGBType(T),
        n,
        Ref{Ptr{libgb.GrB_Index}}(indices),
        Ref{Ptr{Cvoid}}(values),
        vi_size,
        vx_size,
        false,
        length(vx),
        false,
        desc
    )
end

function GBVector(v::SparseVector)
    return importcscvec(v.n, v.nzind, v.nzval)
end

function importdensematrix(
    m::Integer, n::Integer, A::Matrix{T};
    desc::Descriptor = Descriptors.NULL
) where {T}
    C = Ref{libgb.GrB_Matrix}()
    m = libgb.GrB_Index(m)
    n = libgb.GrB_Index(n)
    Asize = libgb.GrB_Index(sizeof(A))

    Ax = Ptr{T}(Libc.malloc(Asize))
    unsafe_copyto!(Ax, pointer(A), length(A))
    libgb.GxB_Matrix_import_FullC(
        C,
        toGBType(T),
        m,
        n,
        Ref{Ptr{Cvoid}}(Ax),
        Asize,
        false,
        desc
    )
    return GBMatrix{T}(C[])
end

function GBMatrix(M::Matrix)
    return importdensematrix(size(M, 1), size(M, 2), M)
end


function importdensevec(
    n::Integer, v::Vector{T};
    desc::Descriptor = Descriptors.NULL
) where {T}
    w = Ref{libgb.GrB_Vector}()
    n = libgb.GrB_Index(n)
    vsize = libgb.GrB_Index(sizeof(v))

    vx = Ptr{T}(Libc.malloc(vsize))
    unsafe_copyto!(vx, pointer(v), length(v))
    libgb.GxB_Vector_import_Full(
        w,
        toGBType(T),
        n,
        Ref{Ptr{Cvoid}}(vx),
        vsize,
        false,
        desc
    )
    return GBVector{T}(w[])
end

function GBVector(v::Vector)
    return importdensevec(size(v)..., v)
end
