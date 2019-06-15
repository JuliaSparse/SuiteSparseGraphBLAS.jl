"""
    GrB_Matrix(I, J, X,[ nrows, ncols, nvals, dup])

Create a GraphBLAS matrix of dimensions nrows x ncols such that A[I[k], J[k]] = X[k].
dup is a GraphBLAS binary operator used to combine duplicates, it defaults to `FIRST`.
If nrows and ncols are not specified, they are set to maximum(I) and maximum(J) respectively.
nvals is set to length(I) is not specified.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> A = GrB_Matrix([1, 1, 2, 3], [1, 1, 2, 3], UInt32[1, 10, 1, 1], dup = GrB_PLUS_UINT32)
GrB_Matrix{UInt32}

julia> A[1, 1]
0x0000000b
```
"""
function GrB_Matrix(
        I::Vector{U},
        J::Vector{U},
        X::Vector{T};
        nrows::U = maximum(I),
        ncols::U = maximum(J),
        nvals::U = length(I),
        dup::GrB_BinaryOp = default_dup(T)) where {T <: valid_types, U <: GrB_Index}

    A = GrB_Matrix{T}()
    GrB_T = get_GrB_Type(T)
    res = GrB_Matrix_new(A, GrB_T, nrows, ncols)
    if res != GrB_SUCCESS
        error(res)
    end
    res = GrB_Matrix_build(A, I.-1, J.-1, X, nvals, dup)
    if res != GrB_SUCCESS
        error(res)
    end
    return A
end

"""
    GrB_Matrix(T, nrows, ncols)

Create an empty GraphBLAS matrix of type T and dimensions nrows x ncols.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Matrix(Float64, 4, 4)
GrB_Matrix{Float64}

julia> nnz(A)
0
```
"""
function GrB_Matrix(T::DataType, nrows::GrB_Index, ncols::GrB_Index)
    A = GrB_Matrix{T}()
    GrB_T = get_GrB_Type(T)
    res = GrB_Matrix_new(A, GrB_T, nrows, ncols)
    if res != GrB_SUCCESS
        error(res)
    end
    return A
end

"""
    findnz(A)

Return a tuple (I, J, X) where I and J are the row and column indices of the stored values in GraphBLAS matrix A,
and X is a vector of the values.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Matrix([1, 2, 3], [1, 2, 3], [1, 1, 1])
GrB_Matrix{Int64}

julia> findnz(A)
([1, 2, 3], [1, 2, 3], [1, 1, 1])
```
"""
function findnz(A::GrB_Matrix)
    res = GrB_Matrix_extractTuples(A)
    if typeof(res) == GrB_Info
        error(res)
    end
    I, J, X = res
    return I.+1, J.+1, X
end

"""
    nnz(A)

Return the number of stored (filled) elements in a GraphBLAS matrix.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Matrix([1, 2, 3], [1, 2, 3], [1, 1, 1])
GrB_Matrix{Int64}

julia> nnz(A)
3
```
"""
function nnz(A::GrB_Matrix)
    nvals = GrB_Matrix_nvals(A)
    if typeof(nvals) == GrB_Info
        error(nvals)
    end
    return nvals
end

"""
    size(A,[ dim])

Return number of rows or/and columns in a GraphBLAS matrix.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Matrix([1, 2, 3], [1, 2, 3], [1, 1, 1])
GrB_Matrix{Int64}

julia> size(A)
(3, 3)

julia> size(A, 1)
3

julia> size(A, 2)
3
```
"""
function size(A::GrB_Matrix)
    nrows = GrB_Matrix_nrows(A)
    if typeof(nrows) == GrB_Info
        error(nrows)
    end
    ncols = GrB_Matrix_ncols(A)
    if typeof(ncols) == GrB_Info
        error(ncols)
    end
    return (nrows, ncols)
end

function size(A::GrB_Matrix, dim::Int64)
    if dim <= 0
        return error("dimension out of range")
    end

    if dim == 1
        nrows = GrB_Matrix_nrows(A)
        if typeof(nrows) == GrB_Info
            error(nrows)
        end
        return nrows
    elseif dim == 2
        ncols = GrB_Matrix_ncols(A)
        if typeof(ncols) == GrB_Info
            error(ncols)
        end
        return ncols
    end

    return 1
end

"""
    getindex(A, row_index, col_index)

Return A[row_index, col_index] where A is a GraphBLAS matrix.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Matrix([1, 2, 3], [1, 2, 3], [1, 1, 1])
GrB_Matrix{Int64}

julia> A[1, 1]
1
```
"""
function getindex(A::GrB_Matrix, row_index::GrB_Index, col_index::GrB_Index)
    res = GrB_Matrix_extractElement(A, row_index-1, col_index-1)
    if typeof(res) == GrB_Info
        error(res)
    end
    return res
end

"""
    setindex!(A, X, I, J)

Set A[I, J] = X where A is a GraphBLAS matrix.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Matrix([1, 2, 3], [1, 2, 3], [1, 1, 1])
GrB_Matrix{Int64}

julia> A[1, 1]
1

julia> A[1, 1] = 5
5

julia> A[1, 1]
5
```
"""
function setindex!(A::GrB_Matrix{T}, X::T, I::GrB_Index, J::GrB_Index) where {T <: valid_types}
    res = GrB_Matrix_setElement(A, X, I-1, J-1)
    if res != GrB_SUCCESS
        error(res)
    end
end

"""
    empty!(A)

Remove all stored entries from GraphBLAS matrix A.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Matrix([1, 2, 3], [1, 2, 3], [1, 1, 1])
GrB_Matrix{Int64}

julia> nnz(A)
3

julia> empty!(A)

julia> nnz(A)
0
```
"""
function empty!(A::GrB_Matrix)
    res = GrB_Matrix_clear(A)
    if res != GrB_SUCCESS
        error(res)
    end
end

"""
    copy(A)

Create a new GraphBLAS matrix with the same domain, dimensions, and contents as GraphBLAS matrix A.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Matrix([1, 2, 3], [1, 2, 3], [1, 1, 1])
GrB_Matrix{Int64}

julia> B = copy(A)
GrB_Matrix{Int64}

julia> findnz(B)
([1, 2, 3], [1, 2, 3], [1, 1, 1])
```
"""
function copy(A::GrB_Matrix{T}) where T <: valid_types
    C = GrB_Matrix{T}()
    res = GrB_Matrix_dup(C, A)
    if res != GrB_SUCCESS
        error(res)
    end
    return C
end
