"""
    GrB_Matrix_new(A, type, nrows, ncols)

Create a new matrix with specified domain and dimensions.
"""
function GrB_Matrix_new(A::GrB_Matrix, type::GrB_Type, nrows::T, ncols::T) where T <: GrB_Index
    A_ptr = pointer_from_objref(A)

    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_Matrix_new"),
                Cint,
                (Ptr{Cvoid}, Ptr{Cvoid}, Cintmax_t, Cintmax_t),
                A_ptr, type.p, nrows, ncols
            )
        )
end

"""
    GrB_Matrix_build(C, I, J, X, nvals, dup)

Store elements from tuples into a vector.
"""
function GrB_Matrix_build(C::GrB_Matrix, I::Vector{U}, J::Vector{U}, X::Vector{T}, nvals::U, dup::GrB_BinaryOp) where{U <: GrB_Index, T <: valid_types}
    I_ptr = pointer(I)
    J_ptr = pointer(J)
    X_ptr = pointer(X)
    fn_name = "GrB_Matrix_build_" * get_suffix(T)
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, fn_name),
                Cint,
                (Ptr{Cvoid}, Ptr{U}, Ptr{U}, Ptr{T}, Cintmax_t, Ptr{Cvoid}),
                C.p, I_ptr, J_ptr, X_ptr, nvals, dup.p
            )
        )
end

"""
    GrB_Matrix_nrows(A)

Return the number of rows in a matrix if successful.
Else return value of type GrB Info.
"""
function GrB_Matrix_nrows(A::GrB_Matrix)
    nrows = Ref(UInt64(0))
    result = GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Matrix_nrows"),
                        Cint,
                        (Ptr{UInt64}, Ptr{Cvoid}),
                        nrows, A.p
                    )
                )
    result != GrB_SUCCESS && return result
    return _GrB_Index(nrows[])
end

"""
    GrB_Matrix_ncols(A)

Return the number of columns in a matrix if successful.
Else return value of type GrB Info.
"""
function GrB_Matrix_ncols(A::GrB_Matrix)
    ncols = Ref(UInt64(0))
    result = GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Matrix_ncols"),
                        Cint,
                        (Ptr{UInt64}, Ptr{Cvoid}),
                        ncols, A.p
                    )
                )
    result != GrB_SUCCESS && return result
    return _GrB_Index(ncols[])
end

"""
    GrB_Matrix_nvals(A)

Return the number of stored elements in a matrix if successful.
Else return value of type GrB Info.
"""
function GrB_Matrix_nvals(A::GrB_Matrix)
    nvals = Ref(UInt64(0))
    result = GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Matrix_nvals"),
                        Cint,
                        (Ptr{UInt64}, Ptr{Cvoid}),
                        nvals, A.p
                    )
                )
    result != GrB_SUCCESS && return result
    return _GrB_Index(nvals[])
end

"""
    GrB_Matrix_dup(C, A)

Create a new matrix with the same domain, dimensions, and contents as another matrix.
"""
function GrB_Matrix_dup(C::GrB_Matrix, A::GrB_Matrix)
    C_ptr = pointer_from_objref(C)

    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_Matrix_dup"),
                Cint,
                (Ptr{Cvoid}, Ptr{Cvoid}),
                C_ptr, A.p
            )
        )
end

"""
    GrB_Matrix_clear(A)

Remove all elements from a matrix.
"""
function GrB_Matrix_clear(A::GrB_Matrix)
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_Matrix_clear"),
                Cint,
                (Ptr{Cvoid}, ),
                A.p
            )
        )
end

"""
    GrB_Matrix_setElement(C, X, I, J)

Set one element of a matrix to a given value, C[I][J] = X.
"""
function GrB_Matrix_setElement(C::GrB_Matrix, X::T, I::U, J::U) where {U <: GrB_Index, T <: valid_int_types}
    fn_name = "GrB_Matrix_setElement_" * get_suffix(T)
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, fn_name),
                Cint,
                (Ptr{Cvoid}, Cintmax_t, Cintmax_t, Cintmax_t),
                C.p, X, I, J
            )
        )
end

function GrB_Matrix_setElement(C::GrB_Matrix, X::Float32, I::U, J::U) where U <: GrB_Index
    fn_name = "GrB_Matrix_setElement_FP32"
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, fn_name),
                Cint,
                (Ptr{Cvoid}, Cfloat, Cintmax_t, Cintmax_t),
                C.p, X, I, J
            )
        )
end

function GrB_Matrix_setElement(C::GrB_Matrix, X::Float64, I::U, J::U) where U <: GrB_Index
    fn_name = "GrB_Matrix_setElement_FP64"
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, fn_name),
                Cint,
                (Ptr{Cvoid}, Cdouble, Cintmax_t, Cintmax_t),
                C.p, X, I, J
            )
        )
end

"""
    GrB_Matrix_extractElement(A, row_index, col_index)

Return element of a vector at a given index (A[row_index][col_index]) if successful.
Else return value of type GrB Info.
"""
function GrB_Matrix_extractElement(A::GrB_Matrix, row_index::U, col_index::U) where U <: GrB_Index
    res, A_type = GxB_Matrix_type(A)
    res != GrB_SUCCESS && return res
    suffix, T = get_suffix_and_type(A_type)
    fn_name = "GrB_Matrix_extractElement_" * suffix

    element = Ref(T(0))
    result = GrB_Info(
                ccall(
                        dlsym(graphblas_lib, fn_name),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Cintmax_t, Cintmax_t),
                        element, A.p, row_index, col_index
                    )
                )
    result != GrB_SUCCESS && return result
    return element[]
end

"""
    GrB_Matrix_extractTuples(A)

Return tuples stored in a matrix.
"""
function GrB_Matrix_extractTuples(A::GrB_Matrix)
    res, A_type = GxB_Matrix_type(A)
    res != GrB_SUCCESS && return res
    suffix, T = get_suffix_and_type(A_type)
    nvals = GrB_Matrix_nvals(A)
    U = typeof(nvals)
    row_indices = Vector{U}(undef, nvals)
    col_indices = Vector{U}(undef, nvals)
    vals = Vector{T}(undef, nvals)
    n = Ref(UInt64(nvals))

    fn_name = "GrB_Matrix_extractTuples_" * suffix
    result = GrB_Info(
                ccall(
                        dlsym(graphblas_lib, fn_name),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{UInt64}, Ptr{Cvoid}),
                        pointer(row_indices), pointer(col_indices), pointer(vals), n, A.p
                    )
                )
    result != GrB_SUCCESS && return result
    return row_indices, col_indices, vals
end
