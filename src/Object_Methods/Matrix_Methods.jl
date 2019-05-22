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
    if nrows[] > typemax(Int64)
        return nrows[]
    end
    return Int64(nrows[])
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
    if ncols[] > typemax(Int64)
        return ncols[]
    end
    return Int64(ncols[])
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
    if nvals[] > typemax(Int64)
        return nvals[]
    end
    return Int64(nvals[])
end

function GrB_Matrix_dup(C::GrB_Matrix, A::GrB_Matrix)
    C_ptr = pointer_from_objref

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
                dlsym(graphblas_lib, "GrB_Matrix_dup"),
                Cint,
                (Ptr{Cvoid}, ),
                A.p
            )
        )
end

function GrB_Matrix_setElement(C::GrB_Matrix, X::T, I::U, J::U) where {U <: GrB_Index, T <: valid_types}
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

function GrB_Matrix_extractElement(A::GrB_Matrix, row_index::U, col_index::U) where U <: GrB_Index
    res, A_type = GxB_Matrix_type(A)
    res != GrB_SUCCESS && return res
    suffix, T = get_suffix_and_type(A_type)
    fn_name = "GrB_Matrix_extractElement_" * suffix

    element = Ref(UInt64(0))
    result = GrB_Info(
                ccall(
                        dlsym(graphblas_lib, fn_name),
                        Cint,
                        (Ptr{UInt64}, Ptr{Cvoid}, Cintmax_t, Cintmax_t),
                        element, A.p, row_index, col_index
                    )
                )
    result != GrB_SUCCESS && return result
    return T(element[])
end
