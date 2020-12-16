import GraphBLASInterface:
        GrB_eWiseMult, GrB_eWiseMult_Vector_Semiring, GrB_eWiseMult_Vector_Monoid, GrB_eWiseMult_Vector_BinaryOp,
        GrB_eWiseMult_Matrix_Semiring, GrB_eWiseMult_Matrix_Monoid, GrB_eWiseMult_Matrix_BinaryOp

"""
    GrB_eWiseMult(C, mask, accum, op, A, B, desc)

Generic method for element-wise matrix and vector operations: using set intersection.

`GrB_eWiseMult` computes `C<Mask> = accum (C, A .* B)`, where pairs of elements in two matrices (or vectors) are
pairwise "multiplied" with C(i, j) = mult (A(i, j), B(i, j)). The "multiplication" operator can be any binary operator.
The pattern of the result T = A .* B is the set intersection (not union) of A and B. Entries outside of the intersection
are not computed. This is primary difference with `GrB_eWiseAdd`. The input matrices A and/or B may be transposed first,
via the descriptor. For a semiring, the mult operator is the semiring's multiply operator; this differs from the
eWiseAdd methods which use the semiring's add operator instead.
"""
function GrB_eWiseMult end

"""
    GrB_eWiseMult_Vector_Semiring(w, mask, accum, semiring, u, v, desc)

Compute element-wise vector multiplication using semiring. Semiring's multiply operator is used.
`w<mask> = accum (w, u .* v)`

# Examples
```jldoctest
julia> using GraphBLASInterface, SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> u = GrB_Vector{Int64}()
GrB_Vector{Int64}

julia> GrB_Vector_new(u, GrB_INT64, 5)
GrB_SUCCESS::GrB_Info = 0

julia> I1 = ZeroBasedIndex[0, 2, 4]; X1 = [10, 20, 3]; n1 = 3;

julia> GrB_Vector_build(u, I1, X1, n1, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> v = GrB_Vector{Float64}()
GrB_Vector{Float64}

julia> GrB_Vector_new(v, GrB_FP64, 5)
GrB_SUCCESS::GrB_Info = 0

julia> I2 = ZeroBasedIndex[0, 1, 4]; X2 = [1.1, 2.2, 3.3]; n2 = 3;

julia> GrB_Vector_build(v, I2, X2, n2, GrB_FIRST_FP64)
GrB_SUCCESS::GrB_Info = 0

julia> w = GrB_Vector{Float64}()
GrB_Vector{Float64}

julia> GrB_Vector_new(w, GrB_FP64, 5)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_eWiseMult_Vector_Semiring(w, GrB_NULL, GrB_NULL, GxB_PLUS_TIMES_FP64, u, v, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_fprint(w, GxB_COMPLETE)

5x1 GraphBLAS double vector, sparse by col:
w, 2 entries

  (0,0)    11
  (4,0)    9.9
```
"""
function GrB_eWiseMult_Vector_Semiring(         # w<Mask> = accum (w, u.*v)
        w::GrB_Vector,                          # input/output vector for results
        mask::T,                                # optional mask for w, unused if NULL
        accum::U,                               # optional accum for z=accum(w,t)
        semiring::GrB_Semiring,                 # defines '.*' for t=u.*v
        u::GrB_Vector,                          # first input:  vector u
        v::GrB_Vector,                          # second input: vector v
        desc::V                                 # descriptor for w and mask
        ) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_eWiseMult_Vector_Semiring"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, semiring.p, u.p, v.p, desc.p
                    )
                )
end

"""
    GrB_eWiseMult_Vector_Monoid(w, mask, accum, monoid, u, v, desc)

Compute element-wise vector multiplication using monoid.
`w<mask> = accum (w, u .* v)`

# Examples
```jldoctest
julia> using GraphBLASInterface, SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> u = GrB_Vector{Int64}()
GrB_Vector{Int64}

julia> GrB_Vector_new(u, GrB_INT64, 5)
GrB_SUCCESS::GrB_Info = 0

julia> I1 = ZeroBasedIndex[0, 2, 4]; X1 = [10, 20, 3]; n1 = 3;

julia> GrB_Vector_build(u, I1, X1, n1, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> v = GrB_Vector{Float64}()
GrB_Vector{Float64}

julia> GrB_Vector_new(v, GrB_FP64, 5)
GrB_SUCCESS::GrB_Info = 0

julia> I2 = ZeroBasedIndex[0, 1, 4]; X2 = [1.1, 2.2, 3.3]; n2 = 3;

julia> GrB_Vector_build(v, I2, X2, n2, GrB_FIRST_FP64)
GrB_SUCCESS::GrB_Info = 0

julia> w = GrB_Vector{Float64}()
GrB_Vector{Float64}

julia> GrB_Vector_new(w, GrB_FP64, 5)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_eWiseMult_Vector_Monoid(w, GrB_NULL, GrB_NULL, GxB_MAX_FP64_MONOID, u, v, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_fprint(w, GxB_COMPLETE)

5x1 GraphBLAS double vector, sparse by col:
w, 2 entries

  (0,0)    10
  (4,0)    3.3
```
"""
function GrB_eWiseMult_Vector_Monoid(           # w<Mask> = accum (w, u.*v)
        w::GrB_Vector,                          # input/output vector for results
        mask::T,                                # optional mask for w, unused if NULL
        accum::U,                               # optional accum for z=accum(w,t)
        monoid::GrB_Monoid,                     # defines '.*' for t=u.*v
        u::GrB_Vector,                          # first input:  vector u
        v::GrB_Vector,                          # second input: vector v
        desc::V                                 # descriptor for w and mask
        ) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_eWiseMult_Vector_Monoid"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, monoid.p, u.p, v.p, desc.p
                    )
                )
end

"""
    GrB_eWiseMult_Vector_BinaryOp(w, mask, accum, mult, u, v, desc)

Compute element-wise vector multiplication using binary operator.
`w<mask> = accum (w, u .* v)`

# Examples
```jldoctest
julia> using GraphBLASInterface, SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> u = GrB_Vector{Int64}()
GrB_Vector{Int64}

julia> GrB_Vector_new(u, GrB_INT64, 5)
GrB_SUCCESS::GrB_Info = 0

julia> I1 = ZeroBasedIndex[0, 2, 4]; X1 = [10, 20, 30]; n1 = 3;

julia> GrB_Vector_build(u, I1, X1, n1, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> v = GrB_Vector{Float64}()
GrB_Vector{Float64}

julia> GrB_Vector_new(v, GrB_FP64, 5)
GrB_SUCCESS::GrB_Info = 0

julia> I2 = ZeroBasedIndex[0, 1, 4]; X2 = [1.1, 2.2, 3.3]; n2 = 3;

julia> GrB_Vector_build(v, I2, X2, n2, GrB_FIRST_FP64)
GrB_SUCCESS::GrB_Info = 0

julia> w = GrB_Vector{Float64}()
GrB_Vector{Float64}

julia> GrB_Vector_new(w, GrB_FP64, 5)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_eWiseMult_Vector_BinaryOp(w, GrB_NULL, GrB_NULL, GrB_TIMES_FP64, u, v, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_fprint(w, GxB_COMPLETE)

5x1 GraphBLAS double vector, sparse by col:
w, 2 entries

  (0,0)    11
  (4,0)    99
```
"""
function GrB_eWiseMult_Vector_BinaryOp(         # w<Mask> = accum (w, u.*v)
        w::GrB_Vector,                          # input/output vector for results
        mask::T,                                # optional mask for w, unused if NULL
        accum::U,                               # optional accum for z=accum(w,t)
        mult::GrB_BinaryOp,                     # defines '.*' for t=u.*v
        u::GrB_Vector,                          # first input:  vector u
        v::GrB_Vector,                          # second input: vector v
        desc::V                                 # descriptor for w and mask
        ) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_eWiseMult_Vector_BinaryOp"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, mult.p, u.p, v.p, desc.p
                    )
                )
end

"""
    GrB_eWiseMult_Matrix_Semiring(C, Mask, accum, semiring, A, B, desc)

Compute element-wise matrix multiplication using semiring. Semiring's multiply operator is used.
`C<Mask> = accum (C, A .* B)`

# Examples
```jldoctest
julia> using GraphBLASInterface, SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Matrix{Int64}()
GrB_Matrix{Int64}

julia> GrB_Matrix_new(A, GrB_INT64, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I1 = ZeroBasedIndex[0, 0, 2, 2]; J1 = ZeroBasedIndex[1, 2, 0, 2]; X1 = [10, 20, 30, 40]; n1 = 4;

julia> GrB_Matrix_build(A, I1, J1, X1, n1, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> B = GrB_Matrix{Int64}()
GrB_Matrix{Int64}

julia> GrB_Matrix_new(B, GrB_INT64, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I2 = ZeroBasedIndex[0, 0, 2]; J2 = ZeroBasedIndex[3, 2, 0]; X2 = [15, 16, 17]; n2 = 3;

julia> GrB_Matrix_build(B, I2, J2, X2, n2, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> C = GrB_Matrix{Int64}()
GrB_Matrix{Int64}

julia> GrB_Matrix_new(C, GrB_INT64, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_eWiseMult_Matrix_Semiring(C, GrB_NULL, GrB_NULL, GxB_PLUS_TIMES_INT64, A, B, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_fprint(C, GxB_COMPLETE)

  4x4 GraphBLAS int64_t matrix, sparse by row:
  C, 2 entries

    (0,2)   320
    (2,0)   510
```
"""
function GrB_eWiseMult_Matrix_Semiring(         # C<Mask> = accum (C, A.*B)
    C::GrB_Matrix,                              # input/output matrix for results
    Mask::T,                                    # optional mask for C, unused if NULL
    accum::U,                                   # optional accum for Z=accum(C,T)
    semiring::GrB_Semiring,                     # defines '.*' for T=A.*B
    A::GrB_Matrix,                              # first input:  matrix A
    B::GrB_Matrix,                              # second input: matrix B
    desc::V                                     # descriptor for C, Mask, A, and B
    ) where {T <: valid_matrix_mask_types, U <: valid_accum_types, V <: valid_desc_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_eWiseMult_Matrix_Semiring"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, semiring.p, A.p, B.p, desc.p
                    )
                )
end

"""
    GrB_eWiseMult_Matrix_Monoid(C, Mask, accum, monoid, A, B, desc)

Compute element-wise matrix multiplication using monoid.
`C<Mask> = accum (C, A .* B)`

# Examples
```jldoctest
julia> using GraphBLASInterface, SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Matrix{Int64}()
GrB_Matrix{Int64}

julia> GrB_Matrix_new(A, GrB_INT64, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I1 = ZeroBasedIndex[0, 0, 2, 2]; J1 = ZeroBasedIndex[1, 2, 0, 2]; X1 = [10, 20, 30, 40]; n1 = 4;

julia> GrB_Matrix_build(A, I1, J1, X1, n1, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> B = GrB_Matrix{Int64}()
GrB_Matrix{Int64}

julia> GrB_Matrix_new(B, GrB_INT64, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I2 = ZeroBasedIndex[0, 0, 2]; J2 = ZeroBasedIndex[3, 2, 0]; X2 = [15, 16, 17]; n2 = 3;

julia> GrB_Matrix_build(B, I2, J2, X2, n2, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> C = GrB_Matrix{Int64}()
GrB_Matrix{Int64}

julia> GrB_Matrix_new(C, GrB_INT64, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_eWiseMult_Matrix_Monoid(C, GrB_NULL, GrB_NULL, GxB_PLUS_INT64_MONOID, A, B, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_fprint(C, GxB_COMPLETE)

4x4 GraphBLAS int64_t matrix, sparse by row:
C, 2 entries

    (0,2)   36
    (2,0)   47

```
"""
function GrB_eWiseMult_Matrix_Monoid(           # C<Mask> = accum (C, A.*B)
    C::GrB_Matrix,                              # input/output matrix for results
    Mask::T,                                    # optional mask for C, unused if NULL
    accum::U,                                   # optional accum for Z=accum(C,T)
    monoid::GrB_Monoid,                         # defines '.*' for T=A.*B
    A::GrB_Matrix,                              # first input:  matrix A
    B::GrB_Matrix,                              # second input: matrix B
    desc::V                                     # descriptor for C, Mask, A, and B
    ) where {T <: valid_matrix_mask_types, U <: valid_accum_types, V <: valid_desc_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_eWiseMult_Matrix_Monoid"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, monoid.p, A.p, B.p, desc.p
                    )
                )
end

"""
    GrB_eWiseMult_Matrix_BinaryOp(C, Mask, accum, mult, A, B, desc)

Compute element-wise matrix multiplication using binary operator.
`C<Mask> = accum (C, A .* B)`

# Examples
```jldoctest
julia> using GraphBLASInterface, SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Matrix{Int64}()
GrB_Matrix{Int64}

julia> GrB_Matrix_new(A, GrB_INT64, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I1 = ZeroBasedIndex[0, 0, 2, 2]; J1 = ZeroBasedIndex[1, 2, 0, 2]; X1 = [10, 20, 30, 40]; n1 = 4;

julia> GrB_Matrix_build(A, I1, J1, X1, n1, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> B = GrB_Matrix{Int64}()
GrB_Matrix{Int64}

julia> GrB_Matrix_new(B, GrB_INT64, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I2 = ZeroBasedIndex[0, 0, 2]; J2 = ZeroBasedIndex[3, 2, 0]; X2 = [15, 16, 17]; n2 = 3;

julia> GrB_Matrix_build(B, I2, J2, X2, n2, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> C = GrB_Matrix{Int64}()
GrB_Matrix{Int64}

julia> GrB_Matrix_new(C, GrB_INT64, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_eWiseMult_Matrix_BinaryOp(C, GrB_NULL, GrB_NULL, GrB_PLUS_INT64, A, B, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_fprint(C, GxB_COMPLETE)

4x4 GraphBLAS int64_t matrix, sparse by row:
C, 2 entries

    (0,2)   36
    (2,0)   47
```
"""
function GrB_eWiseMult_Matrix_BinaryOp(         # C<Mask> = accum (C, A.*B)
    C::GrB_Matrix,                              # input/output matrix for results
    Mask::T,                                    # optional mask for C, unused if NULL
    accum::U,                                   # optional accum for Z=accum(C,T)
    mult::GrB_BinaryOp,                         # defines '.*' for T=A.*B
    A::GrB_Matrix,                              # first input:  matrix A
    B::GrB_Matrix,                              # second input: matrix B
    desc::V                                     # descriptor for C, Mask, A, and B
    ) where {T <: valid_matrix_mask_types, U <: valid_accum_types, V <: valid_desc_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_eWiseMult_Matrix_BinaryOp"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, mult.p, A.p, B.p, desc.p
                    )
                )
end
