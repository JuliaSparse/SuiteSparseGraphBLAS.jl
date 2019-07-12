"""
    GrB_Matrix(I, J, X,[ nrows, ncols, nvals, dup])

Create a GraphBLAS matrix of dimensions nrows x ncols such that A[I[k], J[k]] = X[k].
dup is a GraphBLAS binary operator used to combine duplicates, it defaults to `FIRST`.
If nrows and ncols are not specified, they are set to maximum(I)+1 and maximum(J)+1 (because of 0-based indexing)
respectively. nvals is set to length(I) is not specified.
"""
function GrB_Matrix(
        I::Vector{U},
        J::Vector{U},
        X::Vector{T};
        nrows::U = maximum(I)+1,
        ncols::U = maximum(J)+1,
        nvals::U = length(I),
        dup::GrB_BinaryOp = default_dup(T)) where {T, U <: GrB_Index}

    A = GrB_Matrix{T}()
    GrB_T = get_GrB_Type(T)
    res = GrB_Matrix_new(A, GrB_T, nrows, ncols)
    if res != GrB_SUCCESS
        error(res)
    end
    res = GrB_Matrix_build(A, I, J, X, nvals, dup)
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
function GrB_Matrix(T, nrows::GrB_Index, ncols::GrB_Index)
    A = GrB_Matrix{T}()
    GrB_T = get_GrB_Type(T)
    res = GrB_Matrix_new(A, GrB_T, nrows, ncols)
    if res != GrB_SUCCESS
        error(res)
    end
    return A
end

"""
    ==(A, B)

Check if two GraphBLAS matrices are equal.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Matrix([1, 2, 3], [2, 4, 5], [1, 1, 1])
GrB_Matrix{Int64}

julia> B = GrB_Matrix([1, 2, 3], [2, 4, 5], [1, 1, 1])
GrB_Matrix{Int64}

julia> A == B
true

julia> B = GrB_Matrix([1, 2, 3], [2, 4, 5], [1, 1, 2])
GrB_Matrix{Int64}

julia> A == B
false

julia> B = GrB_Matrix([1, 2, 3], [2, 4, 3], [1, 1, 1])
GrB_Matrix{Int64}

julia> A == B
false
```
"""
function ==(A::GrB_Matrix{T}, B::GrB_Matrix{U}) where {T, U}
    T != U && return false

    Asize = size(A)
    Anvals = nnz(A)

    Asize == size(B) || return false
    Anvals == nnz(B) || return false

    C = GrB_Matrix(Bool, Asize...)
    op = equal_op(T)

    res = GrB_eWiseMult(C, GrB_NULL, GrB_NULL, op, A, B, GrB_NULL)

    if res != GrB_SUCCESS
        GrB_free(C)
        error(res)
    end

    if nnz(C) != Anvals
        GrB_free(C)
        return false
    end

    result = GrB_reduce(GxB_LAND_BOOL_MONOID, C, GrB_NULL)

    GrB_free(C)

    if typeof(result) == GrB_Info
        error(result)
    end

    return result
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
    return I, J, X
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

julia> A = GrB_Matrix([0, 1, 2], [0, 1, 2], [1, 1, 1])
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
    res = GrB_Matrix_extractElement(A, row_index, col_index)
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
function setindex!(A::GrB_Matrix{T}, X::T, I::GrB_Index, J::GrB_Index) where T
    res = GrB_Matrix_setElement(A, X, I, J)
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
function copy(A::GrB_Matrix{T}) where T
    C = GrB_Matrix{T}()
    res = GrB_Matrix_dup(C, A)
    if res != GrB_SUCCESS
        error(res)
    end
    return C
end

"""
    adjoint(A)

Compute transpose of a GraphBLAS matrix.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> M = GrB_Matrix([1, 1], [2, 3], [1, 1])
GrB_Matrix{Int64}

julia> findnz(M')
([2, 3], [1, 1], [1, 1])
```
"""
function adjoint(A::GrB_Matrix{T}) where T
    C = GrB_Matrix(T, size(A, 2), size(A, 1))
    res = GrB_transpose(C, GrB_NULL, GrB_NULL, A, GrB_NULL)
    if res != GrB_SUCCESS
        error(res)
    end
    return C
end

"""
    LowerTriangular(A)

Return lower triangle of a GraphBLAS matrix.
"""
function LowerTriangular(A::GrB_Matrix{T}) where T 
    nrows, ncols = size(A)
    if nrows != ncols
        error("Matrix is not square")
    end
    L = GrB_Matrix(T, nrows, ncols)
    res = GxB_select(L, GrB_NULL, GrB_NULL, GxB_TRIL, A, 0, GrB_NULL)
    if res != GrB_SUCCESS
        error(res)
    end
    return L
end

"""
    UpperTriangular(A)

Return upper triangle of a GraphBLAS matrix.
"""
function UpperTriangular(A::GrB_Matrix{T}) where T 
    nrows, ncols = size(A)
    if nrows != ncols
        error("Matrix is not square")
    end
    U = GrB_Matrix(T, nrows, ncols)
    res = GxB_select(U, GrB_NULL, GrB_NULL, GxB_TRIU, A, 0, GrB_NULL)
    if res != GrB_SUCCESS
        error(res)
    end
    return U
end

"""
    Diagonal(A)

Return diagonal of a GraphBLAS matrix.
"""
function Diagonal(A::GrB_Matrix{T}) where T 
    nrows, ncols = size(A)
    D = GrB_Matrix(T, nrows, ncols)
    res = GxB_select(D, GrB_NULL, GrB_NULL, GxB_DIAG, A, 0, GrB_NULL)
    if res != GrB_SUCCESS
        error(res)
    end
    return D
end

"""
    dropzeros!(A)

Remove all zero entries from GraphBLAS matrix.
"""
function dropzeros!(A::GrB_Matrix)
    outp_replace_desc = GrB_Descriptor(Dict(GrB_OUTP => GrB_REPLACE))
    res = GrB_assign(A, A, GrB_NULL, A, GrB_ALL, 0, GrB_ALL, 0, outp_replace_desc)
    if res != GrB_SUCCESS
        error(res)
    end
    res = GrB_free(outp_replace_desc)
    if res != GrB_SUCCESS
        error(res)
    end
end
