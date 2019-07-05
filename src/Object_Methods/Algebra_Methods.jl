import GraphBLASInterface:
        GrB_UnaryOp_new, GrB_BinaryOp_new, GrB_Monoid_new, GrB_Semiring_new

function GrB_UnaryOp_new(
    op::GrB_UnaryOp,
    fn::Function,
    ztype::GrB_Type{T},
    xtype::GrB_Type{U}) where {T, U}

    op_ptr = pointer_from_objref(op)

    function unaryop_fn(z, x)
        unsafe_store!(z, fn(x))
        return nothing
    end

    unaryop_fn_C = @cfunction($unaryop_fn, Cvoid, (Ptr{T}, Ref{U}))

    return GrB_Info(
            ccall(
                    dlsym(graphblas_lib, "GrB_UnaryOp_new"),
                    Cint,
                    (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                    op_ptr, unaryop_fn_C, ztype.p, xtype.p
                )
            )
end

function GrB_BinaryOp_new(
    op::GrB_BinaryOp,
    fn::Function,
    ztype::GrB_Type{T},
    xtype::GrB_Type{U},
    ytype::GrB_Type{V}) where {T, U, V}

    op_ptr = pointer_from_objref(op)

    function binaryop_fn(z, x, y)
        unsafe_store!(z, fn(x, y))
        return nothing
    end

    binaryop_fn_C = @cfunction($binaryop_fn, Cvoid, (Ptr{T}, Ref{U}, Ref{V}))

    return GrB_Info(
            ccall(
                    dlsym(graphblas_lib, "GrB_BinaryOp_new"),
                    Cint,
                    (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                    op_ptr, binaryop_fn_C, ztype.p, xtype.p, ytype.p
                )
            )
end

function GrB_Monoid_new(monoid::GrB_Monoid, binary_op::GrB_BinaryOp, identity::T) where T
    monoid_ptr = pointer_from_objref(monoid)
    fn_name = "GrB_Monoid_new_" * suffix(T)

    return GrB_Info(
            ccall(
                    dlsym(graphblas_lib, fn_name),
                    Cint,
                    (Ptr{Cvoid}, Ptr{Cvoid}, Cintmax_t),
                    monoid_ptr, binary_op.p, identity
                )
            )
end

function GrB_Monoid_new(monoid::GrB_Monoid, binary_op::GrB_BinaryOp, identity::UInt64)
    monoid_ptr = pointer_from_objref(monoid)
    fn_name = "GrB_Monoid_new_UINT64"
    
    return GrB_Info(
            ccall(
                    dlsym(graphblas_lib, fn_name),
                    Cint,
                    (Ptr{Cvoid}, Ptr{Cvoid}, Cuintmax_t),
                    monoid_ptr, binary_op.p, identity
                )
            )
end

function GrB_Monoid_new(monoid::GrB_Monoid, binary_op::GrB_BinaryOp, identity::Float32)
    monoid_ptr = pointer_from_objref(monoid)
    fn_name = "GrB_Monoid_new_FP32"

    return GrB_Info(
            ccall(
                    dlsym(graphblas_lib, fn_name),
                    Cint,
                    (Ptr{Cvoid}, Ptr{Cvoid}, Cfloat),
                    monoid_ptr, binary_op.p, identity
                )
            )
end

function GrB_Monoid_new(monoid::GrB_Monoid, binary_op::GrB_BinaryOp, identity::Float64)
    monoid_ptr = pointer_from_objref(monoid)
    fn_name = "GrB_Monoid_new_FP64"

    return GrB_Info(
            ccall(
                    dlsym(graphblas_lib, fn_name),
                    Cint,
                    (Ptr{Cvoid}, Ptr{Cvoid}, Cdouble),
                    monoid_ptr, binary_op.p, identity
                )
            )
end

function GrB_Semiring_new(semiring::GrB_Semiring, monoid::GrB_Monoid, binary_op::GrB_BinaryOp)
    semiring_ptr = pointer_from_objref(semiring)

    return GrB_Info(
            ccall(
                    dlsym(graphblas_lib, "GrB_Semiring_new"),
                    Cint,
                    (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                    semiring_ptr, monoid.p, binary_op.p
                )
            )
end

function GxB_SelectOp_new(op::GxB_SelectOp, GxB_select_function::Function, xtype::GrB_Type{T}, ktype::GrB_Type{U}) where {T, U}

    GxB_select_function_C = @cfunction(
                                    $GxB_select_function, 
                                    Bool, 
                                    (Cintmax_t, Cintmax_t, Cintmax_t, Cintmax_t, Ref{T}, Ref{U})
                                )
    
    return GrB_Info(
            ccall(
                    dlsym(graphblas_lib, "GxB_SelectOp_new"),
                    Cint,
                    (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                    op.p, GxB_select_function_C, xtype.p
                )
            )
end
