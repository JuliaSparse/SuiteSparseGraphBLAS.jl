"""
    GrB_assign(arg1, Mask, accum, arg4, arg5, ...)

Generic method for submatrix/subvector assignment.
"""
function GrB_assign(arg1::T, Mask, accum, arg4::U, arg5::V, args...) where {T, U, V}
    if T <: GrB_Vector
        if U <: GrB_Vector
            return GrB_Vector_assign(arg1, Mask, accum, arg4, arg5, args...)
        elseif U <: valid_types
            return GrB_Vector_assign(arg1, Mask, accum, arg4, arg5, args...)
        end
    elseif T <: GrB_Matrix
        if U <: GrB_Vector
            if V <: Union{Vector{<: GrB_Index}, GrB_ALL_Type}
                return GrB_Col_assign(arg1, Mask, accum, arg4, arg5, args...)
            elseif V <: GrB_Index
                return GrB_Row_assign(arg1, Mask, accum, arg4, arg5, args...)
            end
        elseif U <: GrB_Matrix
            return GrB_Matrix_assign(arg1, Mask, accum, arg4, arg5, args...)
        elseif U <: valid_types
            return GrB_Matrix_assign(arg1, Mask, accum, arg4, arg5, args...)
        end
    end
end

"""
    GrB_Vector_assign(w, mask, accum, u, I, ni, desc)

Assign values from one GraphBLAS vector to a subset of a vector as specified by a set of 
indices. The size of the input vector is the same size as the index array provided.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> w = GrB_Vector{Int64}()
GrB_Vector{Int64}

julia> GrB_Vector_new(w, GrB_INT64, 5)
GrB_SUCCESS::GrB_Info = 0

julia> u = GrB_Vector{Int64}()
GrB_Vector{Int64}

julia> GrB_Vector_new(u, GrB_INT64, 2)
GrB_SUCCESS::GrB_Info = 0

julia> I = [0, 1]; X = [10, 20]; n = 2;

julia> GrB_Vector_build(u, I, X, n, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Vector_assign(w, GrB_NULL, GrB_NULL, u, [2, 4], 2, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Vector_extractTuples(w)
([2, 4], [10, 20])
```
"""
function GrB_Vector_assign(         # w<mask>(I) = accum (w(I),u)
        w::GrB_Vector,              # input/output matrix for results
        mask::T,                    # optional mask for w, unused if NULL
        accum::U,                   # optional accum for z=accum(w(I),t)
        u::GrB_Vector,              # first input:  vector u
        I::Y,                       # row indices
        ni::X,                      # number of row indices
        desc::V                     # descriptor for w and mask
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, Y <: valid_indices_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Vector_assign"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cintmax_t}, Cuintmax_t, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, u.p, pointer(I), ni, desc.p
                    )
                )
end

"""
    GrB_Matrix_assign(C, Mask, accum, A, I, ni, J, nj, desc)

Assign values from one GraphBLAS matrix to a subset of a matrix as specified by a set of 
indices.  The dimensions of the input matrix are the same size as the row and column index arrays provided.

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

julia> C = GrB_Matrix{Int64}()
GrB_Matrix{Int64}

julia> GrB_Matrix_new(C, GrB_INT64, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Matrix_assign(C, GrB_NULL, GrB_NULL, A, GrB_ALL, 4, GrB_ALL, 4, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Matrix_extractTuples(C)
([0, 0, 2, 2], [1, 2, 0, 2], [10, 20, 30, 40])
```
"""
function GrB_Matrix_assign(         # C<Mask>(I,J) = accum (C(I,J),A)
        C::GrB_Matrix,              # input/output matrix for results
        Mask::T,                    # optional mask for C, unused if NULL
        accum::U,                   # optional accum for Z=accum(C(I,J),T)
        A::GrB_Matrix,              # first input:  matrix A
        I::Y,                       # row indices
        ni::X,                      # number of row indices
        J::Y,                       # column indices
        nj::X,                      # number of column indices
        desc::V                     # descriptor for C, Mask, and A
) where {T <: valid_matrix_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, Y <: valid_indices_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Matrix_assign"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Y}, Cuintmax_t, Ptr{Y}, Cuintmax_t, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, A.p, pointer(I), ni, pointer(J), nj, desc.p
                    )
                )
end

"""
    GrB_Col_assign(C, Mask, accum, u, I, ni, j, desc)

Assign the contents a vector to a subset of elements in one column of a matrix.
Note that since the output cannot be transposed, a different variant of assign is provided 
to assign to a row of matrix.

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

julia> u = GrB_Vector{Int64}()
GrB_Vector{Int64}

julia> GrB_Vector_new(u, GrB_INT64, 2)
GrB_SUCCESS::GrB_Info = 0

julia> I2 = [0, 1]; X2 = [5, 6]; n2 = 2;

julia> GrB_Vector_build(u, I2, X2, n2, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Col_assign(A, GrB_NULL, GrB_NULL, u, [1, 2], 2, 0, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Matrix_extractTuples(A)
([0, 0, 1, 2, 2], [1, 2, 0, 0, 2], [10, 20, 5, 6, 40])
```
"""
function GrB_Col_assign(            # C<mask>(I,j) = accum (C(I,j),u)
        C::GrB_Matrix,              # input/output matrix for results
        mask::T,                    # optional mask for C(:,j), unused if NULL
        accum::U,                   # optional accum for z=accum(C(I,j),t)
        u::GrB_Vector,              # input vector
        I::S,                       # row indices
        ni::X,                      # number of row indices
        j::X,                       # column index
        desc::V                     # descriptor for C(:,j) and mask
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, S <: valid_indices_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Col_assign"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cuintmax_t}, Cuintmax_t, Cuintmax_t, Ptr{Cvoid}),
                        C.p, mask.p, accum.p, u.p, pointer(I), ni, j, desc.p
                    )
                )
end

"""
    GrB_Row_assign(C, mask, accum, u, i, J, nj, desc)

Assign the contents a vector to a subset of elements in one row of a matrix.
Note that since the output cannot be transposed, a different variant of assign is provided 
to assign to a column of a matrix.

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

julia> u = GrB_Vector{Int64}()
GrB_Vector{Int64}

julia> GrB_Vector_new(u, GrB_INT64, 2)
GrB_SUCCESS::GrB_Info = 0

julia> I2 = [0, 1]; X2 = [5, 6]; n2 = 2;

julia> GrB_Vector_build(u, I2, X2, n2, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Row_assign(A, GrB_NULL, GrB_NULL, u, 0, [1, 3], 2, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Matrix_extractTuples(A)
([0, 0, 0, 2, 2], [1, 2, 3, 0, 2], [5, 20, 6, 30, 40])
```
"""
function GrB_Row_assign(            # C<mask'>(i,J) = accum (C(i,J),u')
        C::GrB_Matrix,              # input/output matrix for results
        mask::T,                    # optional mask for C(i,:), unused if NULL
        accum::U,                   # optional accum for z=accum(C(i,J),t)
        u::GrB_Vector,              # input vector
        i::X,                       # row index
        J::S,                       # column indices
        nj::X,                      # number of column indices
        desc::V                     # descriptor for C(i,:) and mask
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, S <: valid_indices_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Row_assign"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Cuintmax_t, Ptr{Cuintmax_t}, Cuintmax_t, Ptr{Cvoid}),
                        C.p, mask.p, accum.p, u.p, i, pointer(J), nj, desc.p
                    )
                )
end

"""
    GrB_Vector_assign(w, mask, accum, x, I, ni, desc)

Assign the same value to a specified subset of vector elements.
With the use of `GrB_ALL`, the entire destination vector can be filled with the constant.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> w = GrB_Vector{Float64}()
GrB_Vector{Float64}

julia> GrB_Vector_new(w, GrB_FP64, 4)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Vector_assign(w, GrB_NULL, GrB_NULL, 2.3, [0, 3], 2, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Vector_extractTuples(w)
([0, 3], [2.3, 2.3])
```
"""
function GrB_Vector_assign(         # w<mask>(I) = accum (w(I),x)
        w::GrB_Vector{Y},           # input/output vector for results
        mask::T,                    # optional mask for w, unused if NULL
        accum::U,                   # optional accum for Z=accum(w(I),x)
        x::Z,                       # scalar to assign to w(I)
        I::S,                       # row indices
        ni::X,                      # number of row indices
        desc::V                     # descriptor for w and mask
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, Y <: valid_int_types, Z <: valid_types, S <: valid_indices_types}

    fn_name = "GrB_Vector_assign_" * suffix(Z)

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, fn_name),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Cintmax_t, Ptr{Cuintmax_t}, Cuintmax_t, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, x, pointer(I), ni, desc.p
                    )
                )
end

function GrB_Vector_assign(         # w<mask>(I) = accum (w(I),x)
        w::GrB_Vector{UInt64},      # input/output vector for results
        mask::T,                    # optional mask for w, unused if NULL
        accum::U,                   # optional accum for Z=accum(w(I),x)
        x::Y,                       # scalar to assign to w(I)
        I::S,                       # row indices
        ni::X,                      # number of row indices
        desc::V                     # descriptor for w and mask
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, Y <: valid_types, S <: valid_indices_types}

    fn_name = "GrB_Vector_assign_UINT64"

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, fn_name),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Cuintmax_t, Ptr{Cuintmax_t}, Cuintmax_t, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, x, pointer(I), ni, desc.p
                    )
                )
end

function GrB_Vector_assign(         # w<mask>(I) = accum (w(I),x)
        w::GrB_Vector{Float64},     # input/output vector for results
        mask::T,                    # optional mask for w, unused if NULL
        accum::U,                   # optional accum for Z=accum(w(I),x)
        x::Y,                       # scalar to assign to w(I)
        I::S,                       # row indices
        ni::X,                      # number of row indices
        desc::V                     # descriptor for w and mask
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, Y <: valid_types, S <: valid_indices_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Vector_assign_FP64"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Cdouble, Ptr{Cuintmax_t}, Cuintmax_t, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, x, pointer(I), ni, desc.p
                    )
                )
end

function GrB_Vector_assign(         # w<mask>(I) = accum (w(I),x)
        w::GrB_Vector{Float32},     # input/output vector for results
        mask::T,                    # optional mask for w, unused if NULL
        accum::U,                   # optional accum for Z=accum(w(I),x)
        x::Y,                       # scalar to assign to w(I)
        I::S,                       # row indices
        ni::X,                      # number of row indices
        desc::V                     # descriptor for w and mask
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, Y <: valid_types, S <: valid_indices_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Vector_assign_FP32"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Cfloat, Ptr{Cuintmax_t}, Cuintmax_t, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, x, pointer(I), ni, desc.p
                    )
                )
end

"""
    GrB_Matrix_assign(C, Mask, accum, x, I, ni, J, nj, desc)

Assign the same value to a specified subset of matrix elements.
With the use of `GrB_ALL`, the entire destination matrix can be filled with the constant.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> A = GrB_Matrix{Bool}()
GrB_Matrix{Bool}

julia> GrB_Matrix_new(A, GrB_BOOL, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Matrix_assign(A, GrB_NULL, GrB_NULL, true, [0, 1], 2, [0, 1], 2, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Matrix_extractTuples(A)
([0, 0, 1, 1], [0, 1, 0, 1], Bool[true, true, true, true])
```
"""
function GrB_Matrix_assign(         # C<Mask>(I,J) = accum (C(I,J),x)
        C::GrB_Matrix{Y},           # input/output matrix for results
        Mask::T,                    # optional mask for C, unused if NULL
        accum::U,                   # optional accum for Z=accum(C(I,J),x)
        x::Z,                       # scalar to assign to C(I,J)
        I::S,                       # row indices
        ni::X,                      # number of row indices
        J::S,                       # column indices
        nj::X,                      # number of column indices
        desc::V                     # descriptor for C and Mask
) where {T <: valid_matrix_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, Y <: valid_int_types, Z <: valid_types, S <: valid_indices_types}

    fn_name = "GrB_Matrix_assign_" * suffix(Z)

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, fn_name),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Cintmax_t, Ptr{S}, Cuintmax_t, Ptr{S}, Cuintmax_t, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, x, pointer(I), ni, pointer(J), nj, desc.p
                    )
                )
end

function GrB_Matrix_assign(         # C<Mask>(I,J) = accum (C(I,J),x)
        C::GrB_Matrix{UInt64},      # input/output matrix for results
        Mask::T,                    # optional mask for C, unused if NULL
        accum::U,                   # optional accum for Z=accum(C(I,J),x)
        x::Y,                       # scalar to assign to C(I,J)
        I::S,                       # row indices
        ni::X,                      # number of row indices
        J::S,                       # column indices
        nj::X,                      # number of column indices
        desc::V                     # descriptor for C and Mask
) where {T <: valid_matrix_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, Y <: valid_types, S <: valid_indices_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Matrix_assign_UINT64"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Cuintmax_t, Ptr{S}, Cuintmax_t, Ptr{S}, Cuintmax_t, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, x, pointer(I), ni, pointer(J), nj, desc.p
                    )
                )
end

function GrB_Matrix_assign(         # C<Mask>(I,J) = accum (C(I,J),x)
        C::GrB_Matrix{Float64},     # input/output matrix for results
        Mask::T,                    # optional mask for C, unused if NULL
        accum::U,                   # optional accum for Z=accum(C(I,J),x)
        x::Y,                       # scalar to assign to C(I,J)
        I::S,                       # row indices
        ni::X,                      # number of row indices
        J::S,                       # column indices
        nj::X,                      # number of column indices
        desc::V                     # descriptor for C and Mask
) where {T <: valid_matrix_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, Y <: valid_types, S <: valid_indices_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Matrix_assign_FP64"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Cdouble, Ptr{S}, Cuintmax_t, Ptr{S}, Cuintmax_t, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, x, pointer(I), ni, pointer(J), nj, desc.p
                    )
                )
end

function GrB_Matrix_assign(         # C<Mask>(I,J) = accum (C(I,J),x)
        C::GrB_Matrix{Float32},     # input/output matrix for results
        Mask::T,                    # optional mask for C, unused if NULL
        accum::U,                   # optional accum for Z=accum(C(I,J),x)
        x::Y,                       # scalar to assign to C(I,J)
        I::S,                       # row indices
        ni::X,                      # number of row indices
        J::S,                       # column indices
        nj::X,                      # number of column indices
        desc::V                     # descriptor for C and Mask
) where {T <: valid_matrix_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, Y <: valid_types, S <: valid_indices_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Matrix_assign_FP32"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Cfloat, Ptr{S}, Cuintmax_t, Ptr{S}, Cuintmax_t, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, x, pointer(I), ni, pointer(J), nj, desc.p
                    )
                )
end
