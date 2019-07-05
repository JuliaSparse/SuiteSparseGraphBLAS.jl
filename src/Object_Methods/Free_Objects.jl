import GraphBLASInterface:
        GrB_UnaryOp_free, GrB_BinaryOp_free, GrB_Monoid_free, GrB_Semiring_free,
        GrB_Vector_free, GrB_Matrix_free, GrB_Descriptor_free

"""
    GrB_UnaryOp_free(unaryop)

Free unary operator.
"""
function GrB_UnaryOp_free(unaryop::GrB_UnaryOp)
    unaryop_ptr = pointer_from_objref(unaryop)

    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_UnaryOp_free"),
                Cint,
                (Ptr{Cvoid}, ),
                unaryop_ptr
            )
        )
end

"""
    GrB_BinaryOp_free(binaryop)

Free binary operator.
"""
function GrB_BinaryOp_free(binaryop::GrB_BinaryOp)
    binaryop_ptr = pointer_from_objref(binaryop)

    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_BinaryOp_free"),
                Cint,
                (Ptr{Cvoid}, ),
                binaryop_ptr
            )
        )
end

"""
    GrB_Monoid_free(monoid)

Free monoid.
"""
function GrB_Monoid_free(monoid::GrB_Monoid)
    monoid_ptr = pointer_from_objref(monoid)

    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_Monoid_free"),
                Cint,
                (Ptr{Cvoid}, ),
                monoid_ptr
            )
        )
end

"""
    GrB_Semiring_free(semiring)

Free semiring.
"""
function GrB_Semiring_free(semiring::GrB_Semiring)
    semiring_ptr = pointer_from_objref(semiring)

    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_Semiring_free"),
                Cint,
                (Ptr{Cvoid}, ),
                semiring_ptr
            )
        )
end

"""
    GrB_Vector_free(v)

Free vector.
"""
function GrB_Vector_free(v::GrB_Vector)
    v_ptr = pointer_from_objref(v)

    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_Vector_free"),
                Cint,
                (Ptr{Cvoid}, ),
                v_ptr
            )
        )
end

"""
    GrB_Matrix_free(A)

Free matrix.
"""
function GrB_Matrix_free(A::GrB_Matrix)
    A_ptr = pointer_from_objref(A)

    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_Matrix_free"),
                Cint,
                (Ptr{Cvoid}, ),
                A_ptr
            )
        )
end

"""
    GrB_Descriptor_free(desc)

Free descriptor.
"""
function GrB_Descriptor_free(desc::GrB_Descriptor)
    desc_ptr = pointer_from_objref(desc)

    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_Descriptor_free"),
                Cint,
                (Ptr{Cvoid}, ),
                desc_ptr
            )
        )
end
