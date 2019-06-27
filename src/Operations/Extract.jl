"""
    GrB_extract(arg1, Mask, accum, arg4, ...)

Generic matrix/vector extraction.
"""
GrB_extract(w::GrB_Vector, mask, accum, u::GrB_Vector, I, ni, desc) = GrB_Vector_extract(w, mask, accum, u, I, ni, desc)
GrB_extract(C::GrB_Matrix, Mask, accum, A::GrB_Matrix, I, ni, J, nj, desc) = GrB_Matrix_extract(C, Mask, accum, A, I, ni, J, nj, desc)
GrB_extract(w::GrB_Vector, mask, accum, A::GrB_Matrix, I, ni, j, desc) = GrB_Col_extract(w, mask, accum, A, I, ni, j, desc)

"""
    GrB_Vector_extract(w, mask, accum, u, I, ni, desc)

Extract a sub-vector from a larger vector as specified by a set of indices.
The result is a vector whose size is equal to the number of indices.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> V = GrB_Vector{Int64}()
GrB_Vector{Int64}

julia> GrB_Vector_new(V, GrB_INT64, 5)
GrB_SUCCESS::GrB_Info = 0

julia> I = [1, 2, 4]; X = [15, 32, 84]; n = 3;

julia> GrB_Vector_build(V, I, X, n, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_Vector_fprint(V, GxB_COMPLETE)

GraphBLAS vector: V
nrows: 5 ncols: 1 max # entries: 3
format: standard CSC vlen: 5 nvec_nonempty: 1 nvec: 1 plen: 1 vdim: 1
hyper_ratio 0.0625
GraphBLAS type:  int64_t size: 8
number of entries: 3
column: 0 : 3 entries [0:2]
    row 1: int64 15
    row 2: int64 32
    row 4: int64 84


julia> W = GrB_Vector{Int64}()
GrB_Vector{Int64}

julia> GrB_Vector_new(W, GrB_INT64, 2)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Vector_extract(W, GrB_NULL, GrB_NULL, V, [1, 4], 2, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Vector_extractTuples(W)[2]
2-element Array{Int64,1}:
 15
 84
```
"""
function GrB_Vector_extract(            # w<mask> = accum (w, u(I))
        w::GrB_Vector,                  # input/output vector for results
        mask::T,                        # optional mask for w, unused if NULL
        accum::U,                       # optional accum for z=accum(w,t)
        u::GrB_Vector,                  # first input:  vector u
        I::Y,                           # row indices
        ni::X,                          # number of row indices
        desc::V                         # descriptor for w and mask
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, Y <: valid_indices_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Vector_extract"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Y}, Cuintmax_t, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, u.p, pointer(I), ni, desc.p
                    )
                )
end

"""
    GrB_Matrix_extract(C, Mask, accum, A, I, ni, J, nj, desc)

Extract a sub-matrix from a larger matrix as specified by a set of row indices and a set of column indices.
The result is a matrix whose size is equal to size of the sets of indices.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> MAT = GrB_Matrix{Int8}()
GrB_Matrix{Int8}

julia> GrB_Matrix_new(MAT, GrB_INT8, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I = [1, 2, 2, 2, 3]; J = [1, 2, 1, 3, 3]; X = Int8[2, 3, 4, 5, 6]; n = 5;


julia> GrB_Matrix_build(MAT, I, J, X, n, GrB_FIRST_INT8)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_Matrix_fprint(MAT, GxB_COMPLETE)

GraphBLAS matrix: MAT 
nrows: 4 ncols: 4 max # entries: 5
format: standard CSR vlen: 4 nvec_nonempty: 3 nvec: 4 plen: 4 vdim: 4
hyper_ratio 0.0625
GraphBLAS type:  int8_t size: 1
number of entries: 5 
row: 1 : 1 entries [0:0]
    column 1: int8 2
row: 2 : 3 entries [1:3]
    column 1: int8 4
    column 2: int8 3
    column 3: int8 5
row: 3 : 1 entries [4:4]
    column 3: int8 6


julia> OUT = GrB_Matrix{Int8}()
GrB_Matrix{Int8}

julia> GrB_Matrix_new(OUT, GrB_INT8, 2, 2)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Matrix_extract(OUT, GrB_NULL, GrB_NULL, MAT, [1, 3], 2, [1, 3], 2, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Matrix_extractTuples(OUT)[3]
2-element Array{Int8,1}:
 2
 6
```
"""
function GrB_Matrix_extract(            # C<Mask> = accum (C, A(I,J))
        C::GrB_Matrix,                  # input/output matrix for results
        Mask::T,                        # optional mask for C, unused if NULL
        accum::U,                       # optional accum for Z=accum(C,T)
        A::GrB_Matrix,                  # first input:  matrix A
        I::Y,                           # row indices
        ni::X,                          # number of row indices
        J::Z,                           # column indices
        nj::X,                          # number of column indices
        desc::V                         # descriptor for C, Mask, and A
) where {T <: valid_matrix_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, Y <: valid_indices_types, Z <: valid_indices_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Matrix_extract"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Y}, Cuintmax_t, Ptr{Y}, Cuintmax_t, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, A.p, pointer(I), ni, pointer(J), nj, desc.p
                    )
                )
end

"""
    GrB_Col_extract(w, mask, accum, A, I, ni, j, desc)

Extract from one column of a matrix into a vector. With the transpose descriptor for the source matrix, 
elements of an arbitrary row of the matrix can be extracted with this function as well.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> MAT = GrB_Matrix{Int8}()
GrB_Matrix{Int8}

julia> GrB_Matrix_new(MAT, GrB_INT8, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I = [1, 2, 2, 2, 3]; J = [1, 2, 1, 3, 3]; X = Int8[23, 34, 43, 57, 61]; n = 5;

julia> GrB_Matrix_build(MAT, I, J, X, n, GrB_FIRST_INT8)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_Matrix_fprint(MAT, GxB_COMPLETE)

GraphBLAS matrix: MAT 
nrows: 4 ncols: 4 max # entries: 5
format: standard CSR vlen: 4 nvec_nonempty: 3 nvec: 4 plen: 4 vdim: 4
hyper_ratio 0.0625
GraphBLAS type:  int8_t size: 1
number of entries: 5 
row: 1 : 1 entries [0:0]
    column 1: int8 23
row: 2 : 3 entries [1:3]
    column 1: int8 43
    column 2: int8 34
    column 3: int8 57
row: 3 : 1 entries [4:4]
    column 3: int8 61


julia> desc = GrB_Descriptor()
GrB_Descriptor

julia> GrB_Descriptor_new(desc)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Descriptor_set(desc, GrB_INP0, GrB_TRAN) # descriptor to transpose first input
GrB_SUCCESS::GrB_Info = 0

julia> out = GrB_Vector{Int8}()
GrB_Vector{Int8}

julia> GrB_Vector_new(out, GrB_INT8, 3)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Col_extract(out, GrB_NULL, GrB_NULL, MAT, [1, 2, 3], 3, 2, desc) # extract elements of row 2
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Vector_extractTuples(out)[2]
3-element Array{Int8,1}:
 43
 34
 57
```
"""
function GrB_Col_extract(               # w<mask> = accum (w, A(I,j))
        w::GrB_Vector,                  # input/output matrix for results
        mask::T,                        # optional mask for w, unused if NULL
        accum::U,                       # optional accum for z=accum(w,t)
        A::GrB_Matrix,                  # first input:  matrix A
        I::Y,                           # row indices
        ni::X,                          # number of row indices
        j::X,                           # column index
        desc::V                         # descriptor for w, mask, and A
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, Y <: valid_indices_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Col_extract"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Y}, Cuintmax_t, Cuintmax_t, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, A.p, pointer(I), ni, j, desc.p
                    )
                )
end
