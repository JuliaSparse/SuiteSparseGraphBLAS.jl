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
    desc = nothing,
    iso = false
) where {T}
    A = Ref{LibGraphBLAS.GrB_Matrix}() #Pointer to new GBMatrix
    m = LibGraphBLAS.GrB_Index(m) #nrows
    n = LibGraphBLAS.GrB_Index(n) #ncols
    desc = _handledescriptor(desc)
    @wraperror LibGraphBLAS.GxB_Matrix_import_CSC(
        A,
        gbtype(T),
        m,
        n,
        Ref{Ptr{LibGraphBLAS.GrB_Index}}(colptr),
        Ref{Ptr{LibGraphBLAS.GrB_Index}}(rowindices),
        Ref{Ptr{Cvoid}}(values),
        colsize,
        rowsize,
        valsize,
        iso,
        jumbled,
        desc
    )
    return A
end

function _importcscmat(
    m::Integer,
    n::Integer,
    colptr::Vector{U},
    rowindices::Vector{U},
    values::Vector{T};
    jumbled::Bool = false,
    desc = nothing,
    iso = false
) where {U, T}
    colsize = LibGraphBLAS.GrB_Index(sizeof(colptr)) #Size of colptr vector
    rowsize = LibGraphBLAS.GrB_Index(sizeof(rowindices)) #Size of rowindex vector
    valsize = LibGraphBLAS.GrB_Index(sizeof(values)) #Size of nzval vector
    col = ccall(:jl_malloc, Ptr{LibGraphBLAS.GrB_Index}, (UInt, ), colsize)
    unsafe_copyto!(col, Ptr{UInt64}(pointer(decrement!(colptr))), length(colptr))
    row = ccall(:jl_malloc, Ptr{LibGraphBLAS.GrB_Index}, (UInt, ), rowsize)
    unsafe_copyto!(row, Ptr{UInt64}(pointer(decrement!(rowindices))), length(rowindices))
    val = ccall(:jl_malloc, Ptr{T}, (UInt, ), valsize)
    unsafe_copyto!(val, pointer(values), length(values))
    x = _importcscmat(m, n, col, colsize, row, rowsize, val, valsize; jumbled, desc, iso)
    increment!(colptr)
    increment!(rowindices)
    return x
end

"""
    GBMatrix(S::SparseMatrixCSC)

Create a GBMatrix from a SparseArrays.SparseMatrixCSC `S`.

Note, that unlike most other methods of construction, the resulting matrix will be held by column.
Use `gbset(A, :format, :byrow)` to switch to row orientation.
"""
function GBMatrix(S::SparseMatrixCSC{T}; fill::F = nothing) where {T, F}
    return GBMatrix{T, F}(_importcscmat(S.m, S.n, S.colptr, S.rowval, S.nzval), fill)
end

# TODO: should be able to do better here.
function GBMatrix(v::SparseVector)
    S = SparseMatrixCSC(v)
    return GBMatrix(S)
end

"""
    GBVector(v::SparseVector)

Create a GBVector from SparseArrays sparse vector `v`.
"""
function GBVector(v::SparseVector{T}; fill::F = nothing) where {T, F}
    return GBVector{T, F}(_importcscmat(v.n, 1, [1, length(v.nzind) + 1], v.nzind, v.nzval), fill)
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
    desc = nothing,
    iso = false
) where {U, T}
    A = Ref{LibGraphBLAS.GrB_Matrix}() #Pointer to new GBMatrix
    m = LibGraphBLAS.GrB_Index(m) #nrows
    n = LibGraphBLAS.GrB_Index(n) #ncols
    desc = _handledescriptor(desc)
    @wraperror LibGraphBLAS.GxB_Matrix_import_CSR(
        A,
        gbtype(T),
        m,
        n,
        Ref{Ptr{LibGraphBLAS.GrB_Index}}(rowptr),
        Ref{Ptr{LibGraphBLAS.GrB_Index}}(colindices),
        Ref{Ptr{Cvoid}}(values),
        rowsize,
        colsize,
        valsize,
        iso,
        jumbled,
        desc
    )
    return A
end

function _importcsrmat(
    m::Integer,
    n::Integer,
    rowptr,
    colindices,
    values::Vector{T};
    jumbled::Bool = false,
    desc = nothing,
    iso = false
) where {T}
    rowsize = LibGraphBLAS.GrB_Index(sizeof(rowptr)) #Size of colptr vector
    colsize = LibGraphBLAS.GrB_Index(sizeof(colindices)) #Size of rowindex vector
    valsize = LibGraphBLAS.GrB_Index(sizeof(values)) #Size of nzval vector

    # This section comes after some chatting with Keno Fisher.
    # Cannot directly pass Julia arrays to GraphBLAS, it expects malloc'd arrays.
    # Instead we'll malloc some memory for each of the three vectors, and unsafe_copyto!
    # into them.
    #NOTE: The use of `:jl_malloc` instead of `Libc.malloc` is because *GraphBLAS* will free
    # this memory using `:jl_free`. These functions have to match.
    row = ccall(:jl_malloc, Ptr{LibGraphBLAS.GrB_Index}, (UInt, ), rowsize)
    unsafe_copyto!(row, Ptr{UInt64}(pointer(colptr .- 1)), length(rowptr))
    col = ccall(:jl_malloc, Ptr{LibGraphBLAS.GrB_Index}, (UInt, ), colsize)
    unsafe_copyto!(col, Ptr{UInt64}(pointer(rowindices .- 1)), length(colindices))
    val = ccall(:jl_malloc, Ptr{T}, (UInt, ), valsize)
    unsafe_copyto!(val, pointer(values), length(values))

    return _importcsrmat(m, n, row, rowsize, col, colsize, val, valsize; jumbled, desc, iso)
end

function _importdensematrix(
    m::Integer, n::Integer, A::Ptr{T}, Asize;
    desc = nothing, iso = false
) where {T}
    C = Ref{LibGraphBLAS.GrB_Matrix}()
    m = LibGraphBLAS.GrB_Index(m)
    n = LibGraphBLAS.GrB_Index(n)
    desc = _handledescriptor(desc)
    @wraperror LibGraphBLAS.GxB_Matrix_import_FullC(
        C,
        gbtype(T),
        m,
        n,
        Ref{Ptr{Cvoid}}(A),
        Asize,
        iso,
        desc
    )
    return C
end

function _importdensematrix(
    m::Integer, n::Integer, A::VecOrMat{T};
    desc = nothing, iso = false
) where {T}
    m = LibGraphBLAS.GrB_Index(m)
    n = LibGraphBLAS.GrB_Index(n)
    Asize = LibGraphBLAS.GrB_Index(sizeof(A))
    Ax = ccall(:jl_malloc, Ptr{T}, (UInt, ), Asize)
    unsafe_copyto!(Ax, pointer(A), length(A))
    return _importdensematrix(m, n, Ax, Asize; desc, iso)
end

"""
    GBMatrix(M::Matrix)

Create a GBMatrix from a Julia dense matrix.
Note, that unlike other methods of construction, the resulting matrix will be held by column.
Use `gbset(A, :format, :byrow)` to switch to row orientation.
"""
function GBMatrix(M::Union{AbstractVector{T}, AbstractMatrix{T}}; fill::F = nothing) where {T, F}
    if M isa AbstractVector && !(M isa Vector)
        M = collect(M)
    end
    if M isa AbstractMatrix && !(M isa Matrix)
        M = Matrix(M)
    end
    return GBMatrix{T, F}(_importdensematrix(size(M, 1), size(M, 2), M), fill)
end

"""
    GBVector(v::AbstractVector)

Create a GBVector from a Julia dense vector.
"""
function GBVector(v::AbstractVector{T}; fill::F = nothing) where {T, F}
    if !(v isa Vector)
        v = collect(v)
    end
    return GBVector{T, F}(_importdensematrix(size(v, 1), 1, v), fill)
end