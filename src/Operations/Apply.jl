import GraphBLASInterface:
        GrB_Vector_apply, GrB_Matrix_apply

function GrB_Vector_apply(          # w<mask> = accum (w, op(u))
    w::GrB_Vector,                  # input/output vector for results
    mask::T,                        # optional mask for w, unused if NULL
    accum::U,                       # optional accum for z=accum(w,t)
    op::GrB_UnaryOp,                # operator to apply to the entries
    u::GrB_Vector,                  # first input:  vector u
    desc::V                         # descriptor for w and mask
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Vector_apply"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, op.p, u.p, desc.p
                    )
                )
end

function GrB_Matrix_apply(          # C<Mask> = accum (C, op(A)) or op(A')
    C::GrB_Matrix,                  # input/output matrix for results
    Mask::T,                        # optional mask for C, unused if NULL
    accum::U,                       # optional accum for Z=accum(C,T)
    op::GrB_UnaryOp,                # operator to apply to the entries
    A::GrB_Matrix,                  # first input:  matrix A
    desc::V                         # descriptor for C, mask, and A
) where {T <: valid_matrix_mask_types, U <: valid_accum_types, V <: valid_desc_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Matrix_apply"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, op.p, A.p, desc.p
                    )
                )
end
