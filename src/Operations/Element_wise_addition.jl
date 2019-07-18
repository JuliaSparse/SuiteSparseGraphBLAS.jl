import GraphBLASInterface:
        GrB_eWiseAdd, GrB_eWiseAdd_Vector_Semiring, GrB_eWiseAdd_Vector_Monoid, GrB_eWiseAdd_Vector_BinaryOp,
        GrB_eWiseAdd_Matrix_Semiring, GrB_eWiseAdd_Matrix_Monoid, GrB_eWiseAdd_Matrix_BinaryOp

"""
    GrB_eWiseAdd(C, mask, accum, op, A, B, desc)

Generic method for element-wise matrix and vector operations: using set union.

`GrB_eWiseAdd` computes `C<Mask> = accum (C, A + B)`, where pairs of elements in two matrices (or two vectors)
are pairwise "added". The "add" operator can be any binary operator. With the plus operator,
this is the same matrix addition in conventional linear algebra. The pattern of the result T = A + B is
the set union of A and B. Entries outside of the union are not computed. That is, if both A(i, j) and B(i, j)
are present in the pattern of A and B, then T(i, j) = A(i, j) "+" B(i, j). If only A(i, j) is present
then T(i, j) = A (i, j) and the "+" operator is not used. Likewise, if only B(i, j) is in the pattern of B
but A(i, j) is not in the pattern of A, then T(i, j) = B(i, j). For a semiring, the mult operator is the
semiring's add operator.
"""
function GrB_eWiseAdd end

"""
    GrB_eWiseAdd_Vector_Semiring(w, mask, accum, semiring, u, v, desc)

Compute element-wise vector addition using semiring. Semiring's add operator is used.
`w<mask> = accum (w, u + v)`

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

julia> GrB_eWiseAdd_Vector_Semiring(w, GrB_NULL, GrB_NULL, GxB_PLUS_TIMES_FP64, u, v, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_fprint(w, GxB_COMPLETE)

GraphBLAS vector: w 
nrows: 5 ncols: 1 max # entries: 4
format: standard CSC vlen: 5 nvec_nonempty: 1 nvec: 1 plen: 1 vdim: 1
hyper_ratio 0.0625
GraphBLAS type:  double size: 8
number of entries: 4 
column: 0 : 4 entries [0:3]
    row 0: double 11.1
    row 1: double 2.2
    row 2: double 20
    row 4: double 6.3
```
"""
function GrB_eWiseAdd_Vector_Semiring(          # w<Mask> = accum (w, u+v)
        w::GrB_Vector,                          # input/output vector for results
        mask::T,                                # optional mask for w, unused if NULL
        accum::U,                               # optional accum for z=accum(w,t)
        semiring::GrB_Semiring,                 # defines '+' for t=u+v
        u::GrB_Vector,                          # first input:  vector u
        v::GrB_Vector,                          # second input: vector v
        desc::V                                 # descriptor for w and mask
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_eWiseAdd_Vector_Semiring"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, semiring.p, u.p, v.p, desc.p
                    )
                )
end


"""
    GrB_eWiseAdd_Vector_Monoid(w, mask, accum, monoid, u, v, desc)

Compute element-wise vector addition using monoid.
`w<mask> = accum (w, u + v)`

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

julia> GrB_eWiseAdd_Vector_Monoid(w, GrB_NULL, GrB_NULL, GxB_MAX_FP64_MONOID, u, v, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_fprint(w, GxB_COMPLETE)

GraphBLAS vector: w 
nrows: 5 ncols: 1 max # entries: 4
format: standard CSC vlen: 5 nvec_nonempty: 1 nvec: 1 plen: 1 vdim: 1
hyper_ratio 0.0625
GraphBLAS type:  double size: 8
number of entries: 4 
column: 0 : 4 entries [0:3]
    row 0: double 10
    row 1: double 2.2
    row 2: double 20
    row 4: double 3.3
```
"""
function GrB_eWiseAdd_Vector_Monoid(            # w<Mask> = accum (w, u+v)
        w::GrB_Vector,                          # input/output vector for results
        mask::T,                                # optional mask for w, unused if NULL
        accum::U,                               # optional accum for z=accum(w,t)
        monoid::GrB_Monoid,                     # defines '+' for t=u+v
        u::GrB_Vector,                          # first input:  vector u
        v::GrB_Vector,                          # second input: vector v
        desc::V                                 # descriptor for w and mask
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_eWiseAdd_Vector_Monoid"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, monoid.p, u.p, v.p, desc.p
                    )
                )
end

"""
    GrB_eWiseAdd_Vector_BinaryOp(w, mask, accum, add, u, v, desc)

Compute element-wise vector addition using binary operator.
`w<mask> = accum (w, u + v)`

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

julia> GrB_eWiseAdd_Vector_BinaryOp(w, GrB_NULL, GrB_NULL, GrB_PLUS_FP64, u, v, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_fprint(w, GxB_COMPLETE)

GraphBLAS vector: w 
nrows: 5 ncols: 1 max # entries: 4
format: standard CSC vlen: 5 nvec_nonempty: 1 nvec: 1 plen: 1 vdim: 1
hyper_ratio 0.0625
GraphBLAS type:  double size: 8
number of entries: 4 
column: 0 : 4 entries [0:3]
    row 0: double 11.1
    row 1: double 2.2
    row 2: double 20
    row 4: double 6.3
```
"""
function GrB_eWiseAdd_Vector_BinaryOp(          # w<Mask> = accum (w, u+v)
        w::GrB_Vector,                          # input/output vector for results
        mask::T,                                # optional mask for w, unused if NULL
        accum::U,                               # optional accum for z=accum(w,t)
        add::GrB_BinaryOp,                      # defines '+' for t=u+v
        u::GrB_Vector,                          # first input:  vector u
        v::GrB_Vector,                          # second input: vector v
        desc::V                                 # descriptor for w and mask
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_eWiseAdd_Vector_BinaryOp"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, add.p, u.p, v.p, desc.p
                    )
                )
end

"""
    GrB_eWiseAdd_Matrix_Semiring(C, Mask, accum, semiring, A, B, desc)

Compute element-wise matrix addition using semiring. Semiring's add operator is used.
`C<Mask> = accum (C, A + B)`

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

julia> GrB_eWiseAdd_Matrix_Semiring(C, GrB_NULL, GrB_NULL, GxB_PLUS_TIMES_INT64, A, B, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_fprint(C, GxB_COMPLETE)

GraphBLAS matrix: C 
nrows: 4 ncols: 4 max # entries: 5
format: standard CSR vlen: 4 nvec_nonempty: 2 nvec: 4 plen: 4 vdim: 4
hyper_ratio 0.0625
GraphBLAS type:  int64_t size: 8
number of entries: 5 
row: 0 : 3 entries [0:2]
    column 1: int64 10
    column 2: int64 36
    column 3: int64 15
row: 2 : 2 entries [3:4]
    column 0: int64 47
    column 2: int64 40
```
"""
function GrB_eWiseAdd_Matrix_Semiring(          # C<Mask> = accum (C, A+B)
    C::GrB_Matrix,                              # input/output matrix for results
    Mask::T,                                    # optional mask for C, unused if NULL
    accum::U,                                   # optional accum for Z=accum(C,T)
    semiring::GrB_Semiring,                     # defines '+' for T=A+B
    A::GrB_Matrix,                              # first input:  matrix A
    B::GrB_Matrix,                              # second input: matrix B
    desc::V                                     # descriptor for C, Mask, A, and B
) where {T <: valid_matrix_mask_types, U <: valid_accum_types, V <: valid_desc_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_eWiseAdd_Matrix_Semiring"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, semiring.p, A.p, B.p, desc.p
                    )
                )
end

"""
    GrB_eWiseAdd_Matrix_Monoid(C, Mask, accum, monoid, A, B, desc)

Compute element-wise matrix addition using monoid.
`C<Mask> = accum (C, A + B)`

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

julia> mask = GrB_Matrix{Bool}()
GrB_Matrix{Bool}

julia> GrB_Matrix_new(mask, GrB_BOOL, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Matrix_build(mask, ZeroBasedIndex[0, 0], ZeroBasedIndex[1, 2], [true, true], 2, GrB_FIRST_BOOL)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_eWiseAdd_Matrix_Monoid(C, mask, GrB_NULL, GxB_PLUS_INT64_MONOID, A, B, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_fprint(C, GxB_COMPLETE)

GraphBLAS matrix: C 
nrows: 4 ncols: 4 max # entries: 5
format: standard CSR vlen: 4 nvec_nonempty: 1 nvec: 4 plen: 4 vdim: 4
hyper_ratio 0.0625
GraphBLAS type:  int64_t size: 8
number of entries: 2 
row: 0 : 2 entries [0:1]
    column 1: int64 10
    column 2: int64 36
```
"""
function GrB_eWiseAdd_Matrix_Monoid(            # C<Mask> = accum (C, A+B)
    C::GrB_Matrix,                              # input/output matrix for results
    Mask::T,                                    # optional mask for C, unused if NULL
    accum::U,                                   # optional accum for Z=accum(C,T)
    monoid::GrB_Monoid,                         # defines '+' for T=A+B
    A::GrB_Matrix,                              # first input:  matrix A
    B::GrB_Matrix,                              # second input: matrix B
    desc::V                                     # descriptor for C, Mask, A, and B
) where {T <: valid_matrix_mask_types, U <: valid_accum_types, V <: valid_desc_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_eWiseAdd_Matrix_Monoid"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, monoid.p, A.p, B.p, desc.p
                    )
                )
end

"""
    GrB_eWiseAdd_Matrix_BinaryOp(C, Mask, accum, add, A, B, desc)

Compute element-wise matrix addition using binary operator.
`C<Mask> = accum (C, A + B)`

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

julia> I2 = [0, 0, 2]; J2 = [3, 2, 0]; X2 = [15, 16, 17]; n2 = 3;

julia> GrB_Matrix_build(B, I2, J2, X2, n2, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> C = GrB_Matrix{Int64}()
GrB_Matrix{Int64}

julia> GrB_Matrix_new(C, GrB_INT64, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_eWiseAdd_Matrix_BinaryOp(C, GrB_NULL, GrB_NULL, GrB_PLUS_INT64, A, B, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Matrix_extractTuples(C)
julia> @GxB_fprint(C, GxB_COMPLETE)

GraphBLAS matrix: C 
nrows: 4 ncols: 4 max # entries: 5
format: standard CSR vlen: 4 nvec_nonempty: 2 nvec: 4 plen: 4 vdim: 4
hyper_ratio 0.0625
GraphBLAS type:  int64_t size: 8
number of entries: 5 
row: 0 : 3 entries [0:2]
    column 1: int64 10
    column 2: int64 36
    column 3: int64 15
row: 2 : 2 entries [3:4]
    column 0: int64 47
    column 2: int64 40
```
"""
function GrB_eWiseAdd_Matrix_BinaryOp(          # C<Mask> = accum (C, A+B)
    C::GrB_Matrix,                              # input/output matrix for results
    Mask::T,                                    # optional mask for C, unused if NULL
    accum::U,                                   # optional accum for Z=accum(C,T)
    add::GrB_BinaryOp,                          # defines '+' for T=A+B
    A::GrB_Matrix,                              # first input:  matrix A
    B::GrB_Matrix,                              # second input: matrix B
    desc::V                                     # descriptor for C, Mask, A, and B
) where {T <: valid_matrix_mask_types, U <: valid_accum_types, V <: valid_desc_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_eWiseAdd_Matrix_BinaryOp"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, add.p, A.p, B.p, desc.p
                    )
                )
end
