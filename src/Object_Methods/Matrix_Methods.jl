function GrB_Matrix_new(A::GrB_Matrix, type::GrB_Type, nrows::T, ncols::T) where T <: GrB_Index
    A_ptr = pointer_from_objref(A)

    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_Matrix_new"),
                Cint, (Ptr{Cvoid}, Ptr{Cvoid}, Cintmax_t, Cintmax_t),
                A_ptr, type.p, nrows, ncols
            )
        )
end

function GrB_Matrix_build(C::GrB_Matrix, I::Vector{U}, J::Vector{U}, X::Vector{T}, nvals::U, dup::GrB_BinaryOp) where {U <: GrB_Index, T <: valid_types}
    I_ptr = pointer(I)
    J_ptr = pointer(J)
    X_ptr = pointer(X)

    fn_name = "GrB_Matrix_build_" * uppercase("$(T)")
    if T == Float32
        fn_name = "GrB_Matrix_build_FP32"
    elseif T == Float64
        fn_name = "GrB_Matrix_build_FP64"
    end

    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, fn_name),
                Cint,
                (Ptr{Cvoid}, Ptr{U}, Ptr{U}, Ptr{T}, Cintmax_t, Ptr{Cvoid}),
                C.p, I_ptr, J_ptr, X_ptr, nvals, dup.p
            )
        )
end
