function _importcscmat(
    m::Integer,
    n::Integer,
    colptr::Ptr{UInt64},
    colsize,
    rowindices::Ptr{UInt64},
    rowsize,
    values::Ptr{T},
    valsize;
    jumbled::Bool = false,
    desc::Descriptor = DEFAULTDESC,
    iso = false
) where {T}
    A = Ref{libgb.GrB_Matrix}() #Pointer to new GBMatrix
    m = libgb.GrB_Index(m) #nrows
    n = libgb.GrB_Index(n) #ncols
    libgb.GxB_Matrix_import_CSC(
        A,
        toGBType(T),
        m,
        n,
        Ref{Ptr{libgb.GrB_Index}}(colptr),
        Ref{Ptr{libgb.GrB_Index}}(rowindices),
        Ref{Ptr{Cvoid}}(values),
        colsize,
        rowsize,
        valsize,
        iso,
        jumbled,
        desc
    )
    return GBMatrix{T}(A[])
end

function _importcscmat(
    m::Integer,
    n::Integer,
    colptr::Vector{U},
    rowindices::Vector{U},
    values::Vector{T};
    jumbled::Bool = false,
    desc::Descriptor = DEFAULTDESC,
    iso = false
) where {U, T}
    # This section comes after some chatting with Keno Fisher.
    # Cannot directly pass Julia arrays to GraphBLAS, it expects malloc'd arrays.
    # Instead we'll malloc some memory for each of the three vectors, and unsafe_copyto!
    # into them.
    colsize = libgb.GrB_Index(sizeof(colptr)) #Size of colptr vector
    rowsize = libgb.GrB_Index(sizeof(rowindices)) #Size of rowindex vector
    valsize = libgb.GrB_Index(sizeof(values)) #Size of nzval vector
    col = ccall(:jl_malloc, Ptr{libgb.GrB_Index}, (UInt, ), colsize)
    unsafe_copyto!(col, Ptr{UInt64}(pointer(colptr .- 1)), length(colptr))
    row = ccall(:jl_malloc, Ptr{libgb.GrB_Index}, (UInt, ), rowsize)
    unsafe_copyto!(row, Ptr{UInt64}(pointer(rowindices .- 1)), length(rowindices))
    val = ccall(:jl_malloc, Ptr{T}, (UInt, ), valsize)
    unsafe_copyto!(val, pointer(values), length(values))
    return _importcscmat(m, n, col, colsize, row, rowsize, val, valsize; jumbled, desc, iso)
end

"""
    GBMatrix(S::SparseMatrixCSC)

Create a GBMatrix from SparseArrays sparse matrix `S`.
"""
function GBMatrix(S::SparseMatrixCSC)
    return _importcscmat(S.m, S.n, S.colptr, S.rowval, S.nzval)
end

function GBMatrix(v::SparseVector)
    S = SparseMatrixCSC(v)
    return GBMatrix(S)
end

function _importcscvec(
    n::Integer, vi::Ptr{UInt64}, vi_size, vx::Ptr{T}, vx_size, nnz;
    jumbled::Bool = false, desc::Descriptor = DEFAULTDESC, iso = false
) where {T}
    v = Ref{libgb.GrB_Vector}()
    n = libgb.GrB_Index(n)
    libgb.GxB_Vector_import_CSC(
        v,
        toGBType(T),
        n,
        Ref{Ptr{libgb.GrB_Index}}(vi),
        Ref{Ptr{Cvoid}}(vx),
        vi_size,
        vx_size,
        iso,
        nnz,
        jumbled,
        desc
    )
    return GBVector{T}(v[])
end

function _importcscvec(
    n::Integer, vi::Vector{U}, vx::Vector{T}, nnz;
    jumbled::Bool = false, desc::Descriptor = DEFAULTDESC, iso = false
) where {U,T}
    vi_size = libgb.GrB_Index(sizeof(vi))
    vx_size = libgb.GrB_Index(sizeof(vx))
    indices = ccall(:jl_malloc, Ptr{libgb.GrB_Index}, (UInt, ), vi_size)
    unsafe_copyto!(indices, Ptr{UInt64}(pointer(vi .- 1)), length(vi))
    values = ccall(:jl_malloc, Ptr{T}, (UInt, ), vx_size)
    unsafe_copyto!(values, pointer(vx), length(vx))
    return _importcscvec(n, indices, vi_size, values, vx_size, nnz; jumbled, desc, iso)
end

"""
    GBVector(v::SparseVector)

Create a GBVector from SparseArrays sparse vector `v`.
"""
function GBVector(v::SparseVector)
    return _importcscvec(size(v, 1), v.nzind, v.nzval, nnz(v))
end

function _importcsrmat(
    m::Integer,
    n::Integer,
    rowptr::Vector{U},
    rowsize,
    colindices::Vector{U},
    colsize,
    values::Ptr{T},
    valsize;
    jumbled::Bool = false,
    desc::Descriptor = DEFAULTDESC,
    iso = false
) where {U, T}
    A = Ref{libgb.GrB_Matrix}() #Pointer to new GBMatrix
    m = libgb.GrB_Index(m) #nrows
    n = libgb.GrB_Index(n) #ncols
    libgb.GxB_Matrix_import_CSR(
        A,
        toGBType(T),
        m,
        n,
        Ref{Ptr{libgb.GrB_Index}}(rowptr),
        Ref{Ptr{libgb.GrB_Index}}(colindices),
        Ref{Ptr{Cvoid}}(values),
        rowsize,
        colsize,
        valsize,
        iso,
        jumbled,
        desc
    )
    return GBMatrix{T}(A[])
end

function _importcsrmat(
    m::Integer,
    n::Integer,
    rowptr,
    colindices,
    values::Vector{T};
    jumbled::Bool = false,
    desc::Descriptor = DEFAULTDESC,
    iso = false
) where {T}
    rowsize = libgb.GrB_Index(sizeof(rowptr)) #Size of colptr vector
    colsize = libgb.GrB_Index(sizeof(colindices)) #Size of rowindex vector
    valsize = libgb.GrB_Index(sizeof(values)) #Size of nzval vector

    # This section comes after some chatting with Keno Fisher.
    # Cannot directly pass Julia arrays to GraphBLAS, it expects malloc'd arrays.
    # Instead we'll malloc some memory for each of the three vectors, and unsafe_copyto!
    # into them.
    #NOTE: The use of `:jl_malloc` instead of `Libc.malloc` is because *GraphBLAS* will free
    # this memory using `:jl_free`. These functions have to match.
    row = ccall(:jl_malloc, Ptr{libgb.GrB_Index}, (UInt, ), rowsize)
    unsafe_copyto!(row, Ptr{UInt64}(pointer(colptr .- 1)), length(rowptr))
    col = ccall(:jl_malloc, Ptr{libgb.GrB_Index}, (UInt, ), colsize)
    unsafe_copyto!(col, Ptr{UInt64}(pointer(rowindices .- 1)), length(colindices))
    val = ccall(:jl_malloc, Ptr{T}, (UInt, ), valsize)
    unsafe_copyto!(val, pointer(values), length(values))

    return _importcsrmat(m, n, row, rowsize, col, colsize, val, valsize; jumbled, desc, iso)
end

function _importdensematrix(
    m::Integer, n::Integer, A::Ptr{T}, Asize;
    desc::Descriptor = DEFAULTDESC, iso = false
) where {T}
    C = Ref{libgb.GrB_Matrix}()
    m = libgb.GrB_Index(m)
    n = libgb.GrB_Index(n)
    libgb.GxB_Matrix_import_FullC(
        C,
        toGBType(T),
        m,
        n,
        Ref{Ptr{Cvoid}}(A),
        Asize,
        iso,
        desc
    )
    return GBMatrix{T}(C[])
end

function _importdensematrix(
    m::Integer, n::Integer, A::VecOrMat{T};
    desc::Descriptor = DEFAULTDESC, iso = false
) where {T}
    m = libgb.GrB_Index(m)
    n = libgb.GrB_Index(n)
    Asize = libgb.GrB_Index(sizeof(A))
    Ax = ccall(:jl_malloc, Ptr{T}, (UInt, ), Asize)
    #Ax = Ptr{T}(Libc.malloc(Asize))
    unsafe_copyto!(Ax, pointer(A), length(A))
    return _importdensematrix(m, n, Ax, Asize; desc, iso)
end

"""
    GBMatrix(M::Matrix)

Create a GBMatrix from a Julia dense matrix.
"""
function GBMatrix(M::VecOrMat)
    return _importdensematrix(size(M, 1), size(M, 2), M)
end

function _importdensevec(
    n::Integer, v::Ptr{T}, vsize;
    desc::Descriptor = DEFAULTDESC, iso = false
) where {T}
    w = Ref{libgb.GrB_Vector}()
    n = libgb.GrB_Index(n)
    libgb.GxB_Vector_import_Full(
        w,
        toGBType(T),
        n,
        Ref{Ptr{Cvoid}}(v),
        vsize,
        iso,
        desc
    )
    wout = GBVector{T}(w[])
    return wout
end

function _importdensevec(
    n::Integer, v::Vector{T};
    desc::Descriptor = DEFAULTDESC, iso = false
) where {T}
    n = libgb.GrB_Index(n)
    vsize = libgb.GrB_Index(sizeof(v))
    # We have to do this instead of Libc.malloc because GraphBLAS will use :jl_free, not Libc.free
    vx = ccall(:jl_malloc, Ptr{T}, (UInt, ), vsize)
    unsafe_copyto!(vx, pointer(v), length(v))
    return _importdensevec(n, vx, vsize; desc, iso)
end

"""
    GBVector(v::SparseVector)

Create a GBVector from a Julia dense vector.
"""
function GBVector(v::Vector)
    return _importdensevec(size(v)..., v)
end
