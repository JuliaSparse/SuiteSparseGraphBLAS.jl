function importcscmat(
    m::Integer,
    n::Integer,
    colptr,
    rowindices,
    values::Vector{T};
    jumbled::Bool = false,
    desc::Descriptor = Descriptors.NULL,
    iso = false
) where {T}
    A = Ref{libgb.GrB_Matrix}() #Pointer to new GBMatrix
    m = libgb.GrB_Index(m) #nrows
    n = libgb.GrB_Index(n) #ncols
    colsize = libgb.GrB_Index(sizeof(colptr)) #Size of colptr vector
    rowsize = libgb.GrB_Index(sizeof(rowindices)) #Size of rowindex vector
    valsize = libgb.GrB_Index(sizeof(values)) #Size of nzval vector

    # This section comes after some chatting with Keno Fisher.
    # Cannot directly pass Julia arrays to GraphBLAS, it expects malloc'd arrays.
    # Instead we'll malloc some memory for each of the three vectors, and unsafe_copyto!
    # into them.
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
        iso,
        jumbled,
        desc
    )
    return GBMatrix{T}(A[])
end
"""
    GBMatrix(S::SparseMatrixCSC)

Create a GBMatrix from SparseArrays sparse matrix `S`.
"""
function GBMatrix(S::SparseMatrixCSC)
    return importcscmat(S.m, S.n, S.colptr, S.rowval, S.nzval)
end

function GBMatrix(v::SparseVector)
    S = SparseMatrixCSC(v)
    return GBMatrix(S)
end

function importcscvec(
    n::Integer, vi, vx::Vector{T};
    jumbled::Bool = false, desc::Descriptor = Descriptors.NULL, iso = false
) where {T}
    v = Ref{libgb.GrB_Vector}()
    n = libgb.GrB_Index(n)
    vi_size = libgb.GrB_Index(sizeof(vi))
    vx_size = libgb.GrB_Index(sizeof(vx))

    indices = Ptr{libgb.GrB_Index}(Libc.malloc(vi_size))
    unsafe_copyto!(indices, Ptr{UInt64}(pointer(vi .- 1)), length(vi))

    values = Ptr{T}(Libc.malloc(vx_size))
    unsafe_copyto!(values, pointer(vx), length(vx))
    libgb.GxB_Vector_import_CSC(
        v,
        toGBType(T),
        n,
        Ref{Ptr{libgb.GrB_Index}}(indices),
        Ref{Ptr{Cvoid}}(values),
        vi_size,
        vx_size,
        iso,
        length(vx),
        false,
        desc
    )
    return GBVector{T}(v[])
end

"""
    GBVector(v::SparseVector)

Create a GBVector from SparseArrays sparse vector `v`.
"""
function GBVector(v::SparseVector)
    return importcscvec(v.n, v.nzind, v.nzval)
end

function importdensematrix(
    m::Integer, n::Integer, A::VecOrMat{T};
    desc::Descriptor = Descriptors.NULL, iso = false
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
        iso,
        desc
    )
    return GBMatrix{T}(C[])
end

"""
    GBMatrix(M::Matrix)

Create a GBMatrix from a Julia dense matrix.
"""
function GBMatrix(M::VecOrMat)
    return importdensematrix(size(M, 1), size(M, 2), M)
end

function importdensevec(
    n::Integer, v::Vector{T};
    desc::Descriptor = Descriptors.NULL, iso = false
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
        iso,
        desc
    )
    return GBVector{T}(w[])
end

"""
    GBVector(v::SparseVector)

Create a GBVector from a Julia dense vector.
"""
function GBVector(v::Vector)
    return importdensevec(size(v)..., v)
end
