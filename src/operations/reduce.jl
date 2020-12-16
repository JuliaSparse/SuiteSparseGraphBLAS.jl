import GraphBLASInterface:
        GrB_reduce, GrB_Matrix_reduce_Monoid, GrB_Matrix_reduce_BinaryOp, 
        GrB_Matrix_reduce, GrB_Vector_reduce

"""
    GrB_reduce(arg1, arg2, arg3, arg4, ...)

Generic method for matrix/vector reduction to a vector or scalar.
"""
function GrB_reduce end

"""
    GrB_Matrix_reduce_Monoid(w, mask, accum, monoid, A, desc)

Reduce the entries in a matrix to a vector. By default these methods compute a column vector w
such that w(i) = sum(A(i,:)), where "sum" is a commutative and associative monoid with an identity value.
A can be transposed, which reduces down the columns instead of the rows.

# Examples
```jldoctest
julia> using GraphBLASInterface, SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Matrix{Int64}()
GrB_Matrix{Int64}

julia> GrB_Matrix_new(A, GrB_INT64, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I = ZeroBasedIndex[0, 0, 2, 2]; J = ZeroBasedIndex[1, 2, 0, 2]; X = [10, 20, 30, 40]; n = 4;

julia> GrB_Matrix_build(A, I, J, X, n, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> w = GrB_Vector{Int64}()
GrB_Vector{Int64}

julia> GrB_Vector_new(w, GrB_INT64, 4)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Matrix_reduce_Monoid(w, GrB_NULL, GrB_NULL, GxB_PLUS_INT64_MONOID, A, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_fprint(w, GxB_COMPLETE)

4x1 GraphBLAS int64_t vector, sparse by col:
w, 2 entries

  (0,0)   30
  (2,0)   70
```
"""
function GrB_Matrix_reduce_Monoid(          # w<mask> = accum (w,reduce(A))
    w::GrB_Vector,                          # input/output vector for results
    mask::T,                                # optional mask for w, unused if NULL
    accum::U,                               # optional accum for z=accum(w,t)
    monoid::GrB_Monoid,                     # reduce operator for t=reduce(A)
    A::GrB_Matrix,                          # first input:  matrix A
    desc::V                                 # descriptor for w, mask, and A
    ) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Matrix_reduce_Monoid"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, monoid.p, A.p, desc.p
                    )
                )
end

"""
    GrB_Matrix_reduce_BinaryOp(w, mask, accum, op, A, desc)

Reduce the entries in a matrix to a vector. By default these methods compute a column vector w such that
w(i) = sum(A(i,:)), where "sum" is a commutative and associative binary operator. A can be transposed,
which reduces down the columns instead of the rows.

# Examples
```jldoctest
julia> using GraphBLASInterface, SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Matrix{Int64}()
GrB_Matrix{Int64}

julia> GrB_Matrix_new(A, GrB_INT64, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I = ZeroBasedIndex[0, 0, 2, 2]; J = ZeroBasedIndex[1, 2, 0, 2]; X = [10, 20, 30, 40]; n = 4;

julia> GrB_Matrix_build(A, I, J, X, n, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> w = GrB_Vector{Int64}()
GrB_Vector{Int64}

julia> GrB_Vector_new(w, GrB_INT64, 4)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Matrix_reduce_BinaryOp(w, GrB_NULL, GrB_NULL, GrB_TIMES_INT64, A, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_fprint(w, GxB_COMPLETE)

4x1 GraphBLAS int64_t vector, sparse by col:
w, 2 entries

    (0,0)   200
    (2,0)   1200
```
"""
function GrB_Matrix_reduce_BinaryOp(        # w<mask> = accum (w,reduce(A))
    w::GrB_Vector,                          # input/output vector for results
    mask::T,                                # optional mask for w, unused if NULL
    accum::U,                               # optional accum for z=accum(w,t)
    op::GrB_BinaryOp,                       # reduce operator for t=reduce(A)
    A::GrB_Matrix,                          # first input:  matrix A
    desc::V                                 # descriptor for w, mask, and A
    ) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Matrix_reduce_BinaryOp"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, op.p, A.p, desc.p
                    )
                )
end

"""
    GrB_Vector_reduce(monoid, u, desc)

Reduce entries in a vector to a scalar. All entries in the vector are "summed"
using the reduce monoid, which must be associative (otherwise the results are undefined).
If the vector has no entries, the result is the identity value of the monoid.

# Examples
```jldoctest
julia> using GraphBLASInterface, SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> u = GrB_Vector{Int64}()
GrB_Vector{Int64}

julia> GrB_Vector_new(u, GrB_INT64, 5)
GrB_SUCCESS::GrB_Info = 0

julia> I = ZeroBasedIndex[0, 2, 4]; X = [10, 20, 30]; n = 3;

julia> GrB_Vector_build(u, I, X, n, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Vector_reduce(GxB_MAX_INT64_MONOID, u, GrB_NULL)
30
```
"""
function GrB_Vector_reduce(                 # c = reduce_to_scalar(u)
    monoid::GrB_Monoid,                     # monoid to do the reduction
    u::GrB_Vector{T},                       # vector to reduce
    desc::V                                 # descriptor (currently unused)
    ) where {T, V <: valid_desc_types}

    scalar = Ref(T(0))
    fn_name = "GrB_Vector_reduce_" * suffix(T)

    res =   GrB_Info(
                ccall(
                        dlsym(graphblas_lib, fn_name),
                        Cint,
                        (Ptr{T}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        scalar, C_NULL, monoid.p, u.p, desc.p
                    )
                )

    res != GrB_SUCCESS && return res
    return scalar[]
end

"""
    GrB_Matrix_reduce(monoid, A, desc)

Reduce entries in a matrix to a scalar. All entries in the matrix are "summed"
using the reduce monoid, which must be associative (otherwise the results are undefined).
If the matrix has no entries, the result is the identity value of the monoid.

# Examples
```jldoctest
julia> using GraphBLASInterface, SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Matrix{Int64}()
GrB_Matrix{Int64}

julia> GrB_Matrix_new(A, GrB_INT64, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I = ZeroBasedIndex[0, 0, 2, 2]; J = ZeroBasedIndex[1, 2, 0, 2]; X = [10, 20, 30, 40]; n = 4;

julia> GrB_Matrix_build(A, I, J, X, n, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Matrix_reduce(GxB_MIN_INT64_MONOID, A, GrB_NULL)
10
```
"""
function GrB_Matrix_reduce(                 # c = reduce_to_scalar(A)
    monoid::GrB_Monoid,                     # monoid to do the reduction
    A::GrB_Matrix{T},                       # matrix to reduce
    desc::V                                 # descriptor (currently unused)
    ) where {T, V <: valid_desc_types}

    scalar = Ref(T(0))
    fn_name = "GrB_Matrix_reduce_" * suffix(T)

    res =   GrB_Info(
                ccall(
                        dlsym(graphblas_lib, fn_name),
                        Cint,
                        (Ptr{T}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        scalar, C_NULL, monoid.p, A.p, desc.p
                    )
                )

    res != GrB_SUCCESS && return res
    return scalar[]
end
