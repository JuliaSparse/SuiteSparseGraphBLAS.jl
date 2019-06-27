GxB_select(C::GrB_Matrix, Mask, accum, op, A, k, desc) = GxB_Matrix_select(C, Mask, accum, op, A, k, desc)
GxB_select(C::GrB_Vector, Mask, accum, op, A, k, desc) = GxB_Vectorselect(C, Mask, accum, op, A, k, desc)

function GxB_Vector_select(             # w<mask> = accum (w, op(u,k))
        w::GrB_Vector,                  # input/output vector for results
        mask::T,                        # optional mask for w, unused if NULL
        accum::U,                       # optional accum for z=accum(w,t)
        op::GxB_SelectOp,               # operator to apply to the entries
        u::GrB_Vector,                  # first input:  vector u
        thunk,                          # optional input for the select operator
        desc::V                         # descriptor for w and mask
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GxB_Vector_select"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, op.p, u.p, Ref(thunk), desc.p
                    )
                )
end

function GxB_Matrix_select(             # C<Mask> = accum (C, op(A,k)) or op(A',k)
        C::GrB_Matrix,                  # input/output matrix for results
        Mask::T,                        # optional mask for C, unused if NULL
        accum::U,                       # optional accum for Z=accum(C,T)
        op::GxB_SelectOp,               # operator to apply to the entries
        A::GrB_Matrix,                  # first input:  matrix A
        thunk,                          # optional input for the select operator
        desc::V                         # descriptor for C, mask, and A
) where {T <: valid_matrix_mask_types, U <: valid_accum_types, V <: valid_desc_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GxB_Matrix_select"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, op.p, A.p, Ref(thunk), desc.p
                    )
                )
end
