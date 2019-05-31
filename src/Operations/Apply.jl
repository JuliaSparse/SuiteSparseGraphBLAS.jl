"""
    GrB_apply(C, Mask, accum, op, A, desc)

Generic matrix/vector apply.
"""
function GrB_apply(                 # w<mask> = accum (w, op(u))
    C::X,                           # input/output vector for results
    Mask::T,                        # optional mask for w, unused if NULL
    accum::U,                       # optional accum for z=accum(w,t)
    op::GrB_UnaryOp,                # operator to apply to the entries
    A::X,                           # first input:  vector u
    desc::V                         # descriptor for w and mask
) where {X <: Union{GrB_Vector, GrB_Matrix}, T <: Union{GrB_Vector, GrB_Matrix, GrB_NULL_Type}, U <: valid_accum_types, V <: valid_desc_types}

    fn_name = "GrB_" * get_struct_name(C) * "_apply"

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, fn_name),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, op.p, A.p, desc.p
                    )
                )
end

"""
    GrB_Vector_apply(w, mask, accum, op, u, desc)

Compute the transformation of the values of the elements of a vector using a unary function.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> u = GrB_Vector{Int64}()
GrB_Vector{Int64}

julia> GrB_Vector_new(u, GrB_INT64, 3)
GrB_SUCCESS::GrB_Info = 0

julia> I = [0, 2]; X = [10, 20]; n = 2;

julia> GrB_Vector_build(u, I, X, n, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> w = GrB_Vector{Int64}()
GrB_Vector{Int64}

julia> GrB_Vector_new(w, GrB_INT64, 3)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Vector_apply(w, GrB_NULL, GrB_NULL, GrB_AINV_INT64, u, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_fprint(w, GxB_COMPLETE)

GraphBLAS vector: w 
nrows: 3 ncols: 1 max # entries: 2
format: standard CSC vlen: 3 nvec_nonempty: 1 nvec: 1 plen: 1 vdim: 1
hyper_ratio 0.0625
GraphBLAS type:  int64_t size: 8
number of entries: 2 
column: 0 : 2 entries [0:1]
    row 0: int64 -10
    row 2: int64 -20

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
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Matrix{Int64}()
GrB_Matrix{Int64}

julia> GrB_Matrix_new(A, GrB_INT64, 2, 2)
GrB_SUCCESS::GrB_Info = 0

julia> I = [0, 0, 1]; J = [0, 1, 1]; X = [10, 20, 30]; n = 3;

julia> GrB_Matrix_build(A, I, J, X, n, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> B = GrB_Matrix{Int64}()
GrB_Matrix{Int64}

julia> GrB_Matrix_new(B, GrB_INT64, 2, 2)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Matrix_apply(B, GrB_NULL, GrB_NULL, GrB_AINV_INT64, A, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_fprint(B, GxB_COMPLETE)

GraphBLAS matrix: B
nrows: 2 ncols: 2 max # entries: 3
format: standard CSR vlen: 2 nvec_nonempty: 2 nvec: 2 plen: 2 vdim: 2
hyper_ratio 0.0625
GraphBLAS type:  int64_t size: 8
number of entries: 3
row: 0 : 2 entries [0:1]
    column 0: int64 -10
    column 1: int64 -20
row: 1 : 1 entries [2:2]
    column 1: int64 -30

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
