import GraphBLASInterface:
        GrB_apply, GrB_Vector_apply, GrB_Matrix_apply

"""
    GrB_apply(C, Mask, accum, op, A, desc)

Generic matrix/vector apply.
"""
function GrB_apply end

"""
    GrB_Vector_apply(w, mask, accum, op, u, desc)

Compute the transformation of the values of the elements of a vector using a unary function.

# Examples
```jldoctest
julia> using GraphBLASInterface, SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> u = GrB_Vector{Int64}()
GrB_Vector{Int64}

julia> GrB_Vector_new(u, GrB_INT64, 3)
GrB_SUCCESS::GrB_Info = 0

julia> I = ZeroBasedIndex[0, 2]; X = [10, 20]; n = 2;

julia> GrB_Vector_build(u, I, X, n, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> w = GrB_Vector{Int64}()
GrB_Vector{Int64}

julia> GrB_Vector_new(w, GrB_INT64, 3)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Vector_apply(w, GrB_NULL, GrB_NULL, GrB_AINV_INT64, u, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_fprint(w, GxB_COMPLETE)

3x1 GraphBLAS int64_t vector, sparse by col:
w, 2 entries

    (0,0)   -10
    (2,0)   -20
```
"""
function GrB_Vector_apply(          # w<mask> = accum (w, op(u))
    w::GrB_Vector,                  # input/output vector for results
    mask::T,                        # optional mask for w, unused if NULL
    accum::U,                       # optional accum for z=accum(w,t)
    op::GrB_UnaryOp,                # operator to apply to the entries
    u::GrB_Vector,                  # first input:  vector u
    desc::V                         # descriptor for w and mask
    ) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Vector_apply"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, op.p, u.p, desc.p
                    )
                )
end

"""
    GrB_Matrix_apply(C, Mask, accum, op, A, desc)

Compute the transformation of the values of the elements of a matrix using a unary function.

# Examples
```jldoctest
julia> using GraphBLASInterface, SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Matrix{Int64}()
GrB_Matrix{Int64}

julia> GrB_Matrix_new(A, GrB_INT64, 2, 2)
GrB_SUCCESS::GrB_Info = 0

julia> I = ZeroBasedIndex[0, 0, 1]; J = ZeroBasedIndex[0, 1, 1]; X = [10, 20, 30]; n = 3;

julia> GrB_Matrix_build(A, I, J, X, n, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> B = GrB_Matrix{Int64}()
GrB_Matrix{Int64}

julia> GrB_Matrix_new(B, GrB_INT64, 2, 2)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Matrix_apply(B, GrB_NULL, GrB_NULL, GrB_AINV_INT64, A, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_fprint(B, GxB_COMPLETE)

2x2 GraphBLAS int64_t matrix, sparse by row:
B, 3 entries

    (0,0)   -10
    (0,1)   -20
    (1,1)   -30
```
"""
function GrB_Matrix_apply(          # C<Mask> = accum (C, op(A)) or op(A')
    C::GrB_Matrix,                  # input/output matrix for results
    Mask::T,                        # optional mask for C, unused if NULL
    accum::U,                       # optional accum for Z=accum(C,T)
    op::GrB_UnaryOp,                # operator to apply to the entries
    A::GrB_Matrix,                  # first input:  matrix A
    desc::V                         # descriptor for C, mask, and A
    ) where {T <: valid_matrix_mask_types, U <: valid_accum_types, V <: valid_desc_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Matrix_apply"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, op.p, A.p, desc.p
                    )
                )
end
