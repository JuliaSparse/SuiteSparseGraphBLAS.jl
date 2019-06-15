"""
    GrB_Vector(I, X,[ n, nvals, dup])

Create a GraphBLAS vector of size n such that A[I[k]] = X[k].
dup is a GraphBLAS binary operator used to combine duplicates, it defaults to `FIRST`.
If n is not specified, it is set to maximum(I).
nvals is set to length(I) is not specified.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Vector([1, 2, 4], Float64[10, 12, 14], n = 5)
GrB_Vector{Float64}

julia> A[2]
12.0

julia> findnz(A)
([1, 2, 4], [10.0, 12.0, 14.0])

julia> nnz(A)
3
```
"""
function GrB_Vector(
        I::Vector{U},
        X::Vector{T};
        n::U = maximum(I),
        nvals::U = length(I),
        dup::GrB_BinaryOp = default_dup(T)) where {T <: valid_types, U <: GrB_Index}

    V = GrB_Vector{T}()
    GrB_T = get_GrB_Type(T)
    res = GrB_Vector_new(V, GrB_T, n)
    if res != GrB_SUCCESS
        error(res)
    end
    res = GrB_Vector_build(V, I.-1, X, nvals, dup)
    if res != GrB_SUCCESS
        error(res)
    end
    return V
end

"""
    GrB_Vector(T, n)

Create an empty GraphBLAS vector of type T and size n.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Vector(Int64, 5)
GrB_Vector{Int64}

julia> size(A)
(5,)

julia> nnz(A)
0
```
"""
function GrB_Vector(T::DataType, n::GrB_Index)
    V = GrB_Vector{T}()
    GrB_T = get_GrB_Type(T)
    res = GrB_Vector_new(V, GrB_T, n)
    if res != GrB_SUCCESS
        error(res)
    end
    return V
end

"""
    size(V,[ dim])

Return the size of a vector.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Vector(Int64, 5)
GrB_Vector{Int64}

julia> size(A)
(5,)

julia> size(A, 1)
5
```
"""
function size(V::GrB_Vector)
    n = GrB_Vector_size(V)
    if typeof(n) == GrB_Info
        error(n)
    end
    return (n, )
end

function size(V::GrB_Vector, dim::Int64)
    if dim <= 0
        return error("dimension out of range")
    end

    if dim == 1
        n = GrB_Vector_size(V)
        if typeof(n) == GrB_Info
            error(n)
        end
        return n
    end

    return 1
end

"""
    nnz(V)

Return the number of stored (filled) elements in a GraphBLAS vector.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Vector([1, 2, 4], Float64[10, 12, 14], n = 5)
GrB_Vector{Float64}

julia> nnz(A)
3
```
"""
function nnz(V::GrB_Vector)
    nvals = GrB_Vector_nvals(V)
    if typeof(nvals) == GrB_Info
        error(nvals)
    end
    return nvals
end

"""
    findnz(V)

Return a tuple (I, X) where I is the indices of the stored values in GraphBLAS vector V and X is a vector of the values.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Vector([1, 2, 4], Float64[10, 12, 14], n = 5)
GrB_Vector{Float64}

julia> findnz(A)
([1, 2, 4], [10.0, 12.0, 14.0])
```
"""
function findnz(V::GrB_Vector)
    res = GrB_Vector_extractTuples(V)
    if typeof(res) == GrB_Info
        error(res)
    end
    I, X = res
    return I.+1, X
end

"""
    setindex!(V, x, i)

Set V[i] = x where V is a GraphBLAS vector.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Vector([1, 2, 4], Float64[10, 12, 14], n = 5)
GrB_Vector{Float64}

julia> A[2]
12.0

julia> A[2] = 3.0
3.0

julia> A[5] = 1.2
1.2

julia> findnz(A)
([1, 2, 4, 5], [10.0, 3.0, 14.0, 1.2])
```
"""
function setindex!(V::GrB_Vector{T}, x::T, i::GrB_Index) where {T <: valid_types}
    res = GrB_Vector_setElement(V, x, i-1)
    if res != GrB_SUCCESS
        error(res)
    end
end

"""
    getindex(V, i)

Return V[i] where V is a GraphBLAS vector.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Vector([1, 2, 4], Float64[10, 12, 14], n = 5)
GrB_Vector{Float64}

julia> A[2]
12.0
```
"""
function getindex(V::GrB_Vector, i::GrB_Index)
    res = GrB_Vector_extractElement(V, i-1)
    if typeof(res) == GrB_Info
        error(res)
    end
    return res
end

"""
    empty!(V)

Remove all stored entries from GraphBLAS vector V.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Vector([1, 2, 4], Float64[10, 12, 14], n = 5)
GrB_Vector{Float64}

julia> nnz(A)
3

julia> empty!(A)

julia> nnz(A)
0
```
"""
function empty!(V::GrB_Vector)
    res = GrB_Vector_clear(V)
    if res != GrB_SUCCESS
        error(res)
    end
end

"""
    copy(V)

Create a new vector with the same domain, size, and contents as GraphBLAS vector V.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Vector([1, 2, 4], Float64[10, 12, 14], n = 5)
GrB_Vector{Float64}

julia> B = copy(A)
GrB_Vector{Float64}

julia> findnz(B)
([1, 2, 4], [10.0, 12.0, 14.0])
```
"""
function copy(V::GrB_Vector{T}) where T <: valid_types
    W = GrB_Vector{T}()
    res = GrB_Vector_dup(W, V)
    if res != GrB_SUCCESS
        error(res)
    end
    return W
end
