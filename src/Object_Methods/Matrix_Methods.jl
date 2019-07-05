import GraphBLASInterface:
        GrB_Matrix_new, GrB_Matrix_build, GrB_Matrix_dup, GrB_Matrix_clear,
        GrB_Matrix_nrows, GrB_Matrix_ncols, GrB_Matrix_nvals, GrB_Matrix_setElement,
        GrB_Matrix_extractElement, GrB_Matrix_extractTuples

function GrB_Matrix_new(A::GrB_Matrix{T}, type::GrB_Type{T}, nrows::U, ncols::U) where {T, U <: GrB_Index}
    A_ptr = pointer_from_objref(A)
    
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_Matrix_new"),
                Cint,
                (Ptr{Cvoid}, Ptr{Cvoid}, Cuintmax_t, Cuintmax_t),
                A_ptr, type.p, nrows, ncols
            )
        )
end

function GrB_Matrix_build(C::GrB_Matrix{T}, I::Vector{U}, J::Vector{U}, X::Vector{T}, nvals::U, dup::GrB_BinaryOp) where {T, U <: GrB_Index}
    I_ptr = pointer(I)
    J_ptr = pointer(J)
    X_ptr = pointer(X)
    fn_name = "GrB_Matrix_build_" * suffix(T)
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, fn_name),
                Cint,
                (Ptr{Cvoid}, Ptr{U}, Ptr{U}, Ptr{T}, Cuintmax_t, Ptr{Cvoid}),
                C.p, I_ptr, J_ptr, X_ptr, nvals, dup.p
            )
        )
end

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

function GrB_Matrix_dup(C::GrB_Matrix{T}, A::GrB_Matrix{T}) where T
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

function GrB_Matrix_setElement(C::GrB_Matrix{T}, X::T, I::U, J::U) where {T, U <: GrB_Index}
    fn_name = "GrB_Matrix_setElement_" * suffix(T)
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, fn_name),
                Cint,
                (Ptr{Cvoid}, Cintmax_t, Cuintmax_t, Cuintmax_t),
                C.p, X, I, J
            )
        )
end

function GrB_Matrix_setElement(C::GrB_Matrix{UInt64}, X::UInt64, I::U, J::U) where U <: GrB_Index
    fn_name = "GrB_Matrix_setElement_UINT64"
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, fn_name),
                Cint,
                (Ptr{Cvoid}, Cuintmax_t, Cuintmax_t, Cuintmax_t),
                C.p, X, I, J
            )
        )
end

function GrB_Matrix_setElement(C::GrB_Matrix{Float32}, X::Float32, I::U, J::U) where U <: GrB_Index
    fn_name = "GrB_Matrix_setElement_FP32"
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, fn_name),
                Cint,
                (Ptr{Cvoid}, Cfloat, Cuintmax_t, Cuintmax_t),
                C.p, X, I, J
            )
        )
end

function GrB_Matrix_setElement(C::GrB_Matrix{Float64}, X::Float64, I::U, J::U) where U <: GrB_Index
    fn_name = "GrB_Matrix_setElement_FP64"
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, fn_name),
                Cint,
                (Ptr{Cvoid}, Cdouble, Cuintmax_t, Cuintmax_t),
                C.p, X, I, J
            )
        )
end

function GrB_Matrix_extractElement(A::GrB_Matrix{T}, row_index::U, col_index::U) where {T, U <: GrB_Index}
    fn_name = "GrB_Matrix_extractElement_" * suffix(T)

    element = Ref(T(0))
    result = GrB_Info(
                ccall(
                        dlsym(graphblas_lib, fn_name),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Cuintmax_t, Cuintmax_t),
                        element, A.p, row_index, col_index
                    )
                )
    result != GrB_SUCCESS && return result
    return element[]
end

function GrB_Matrix_extractTuples(A::GrB_Matrix{T}) where T
    nvals = GrB_Matrix_nvals(A)
    if typeof(nvals) == GrB_Info
        return nvals
    end
    U = typeof(nvals)
    row_indices = Vector{U}(undef, nvals)
    col_indices = Vector{U}(undef, nvals)
    vals = Vector{T}(undef, nvals)
    n = Ref(UInt64(nvals))

    fn_name = "GrB_Matrix_extractTuples_" * suffix(T)
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
