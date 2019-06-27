"""
    GrB_reduce(arg1, arg2, arg3, arg4, ...)

Generic method for matrix/vector reduction to a vector or scalar.
"""
GrB_reduce(w, mask, accum, monoid::GrB_Monoid, A, desc) = GrB_Matrix_reduce_Monoid(w, mask, accum, monoid, A, desc)
GrB_reduce(w, mask, accum, op::GrB_BinaryOp, A, desc) = GrB_Matrix_reduce_BinaryOp(w, mask, accum, op, A, desc)
GrB_reduce(monoid, u::GrB_Vector, desc) = GrB_Vector_reduce(monoid, u, desc)
GrB_reduce(monoid, A::GrB_Matrix, desc) = GrB_Matrix_reduce(monoid, A, desc)

"""
    GrB_Matrix_reduce_Monoid(w, mask, accum, monoid, A, desc)

Reduce the entries in a matrix to a vector. By default these methods compute a column vector w
such that w(i) = sum(A(i,:)), where "sum" is a commutative and associative monoid with an identity value.
A can be transposed, which reduces down the columns instead of the rows.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Matrix{Int64}()
GrB_Matrix{Int64}

julia> GrB_Matrix_new(A, GrB_INT64, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I = [0, 0, 2, 2]; J = [1, 2, 0, 2]; X = [10, 20, 30, 40]; n = 4;

julia> GrB_Matrix_build(A, I, J, X, n, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> w = GrB_Vector{Int64}()
GrB_Vector{Int64}

julia> GrB_Vector_new(w, GrB_INT64, 4)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Matrix_reduce_Monoid(w, GrB_NULL, GrB_NULL, GxB_PLUS_INT64_MONOID, A, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_fprint(w, GxB_COMPLETE)

GraphBLAS vector: w
nrows: 4 ncols: 1 max # entries: 2
format: standard CSC vlen: 4 nvec_nonempty: 1 nvec: 1 plen: 1 vdim: 1
hyper_ratio 0.0625
GraphBLAS type:  int64_t size: 8
number of entries: 2
column: 0 : 2 entries [0:1]
    row 0: int64 30
    row 2: int64 70

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
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Matrix{Int64}()
GrB_Matrix{Int64}

julia> GrB_Matrix_new(A, GrB_INT64, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I = [0, 0, 2, 2]; J = [1, 2, 0, 2]; X = [10, 20, 30, 40]; n = 4;

julia> GrB_Matrix_build(A, I, J, X, n, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> w = GrB_Vector{Int64}()
GrB_Vector{Int64}

julia> GrB_Vector_new(w, GrB_INT64, 4)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Matrix_reduce_BinaryOp(w, GrB_NULL, GrB_NULL, GrB_TIMES_INT64, A, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_fprint(w, GxB_COMPLETE)

GraphBLAS vector: w
nrows: 4 ncols: 1 max # entries: 2
format: standard CSC vlen: 4 nvec_nonempty: 1 nvec: 1 plen: 1 vdim: 1
hyper_ratio 0.0625
GraphBLAS type:  int64_t size: 8
number of entries: 2
column: 0 : 2 entries [0:1]
    row 0: int64 200
    row 2: int64 1200

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
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> u = GrB_Vector{Int64}()
GrB_Vector{Int64}

julia> GrB_Vector_new(u, GrB_INT64, 5)
GrB_SUCCESS::GrB_Info = 0

julia> I = [0, 2, 4]; X = [10, 20, 30]; n = 3;

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
) where {T <: valid_types, V <: valid_desc_types}

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
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Matrix{Int64}()
GrB_Matrix{Int64}

julia> GrB_Matrix_new(A, GrB_INT64, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I = [0, 0, 2, 2]; J = [1, 2, 0, 2]; X = [10, 20, 30, 40]; n = 4;

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
) where {T <: valid_types, V <: valid_desc_types}

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
