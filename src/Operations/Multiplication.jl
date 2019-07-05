import GraphBLASInterface:
        GrB_mxm, GrB_vxm, GrB_mxv

function GrB_mxm(              # C<Mask> = accum (C, A*B)
    C::GrB_Matrix,             # input/output matrix for results
    Mask::T,                   # optional mask for C, unused if NULL
    accum::U,                  # optional accum for Z=accum(C,T)
    semiring::GrB_Semiring,    # defines '+' and '*' for A*B
    A::GrB_Matrix,             # first input:  matrix A
    B::GrB_Matrix,             # second input: matrix B
    desc::V                    # descriptor for C, Mask, A, and B
) where {T <: valid_matrix_mask_types, U <: valid_accum_types, V <: valid_desc_types}
    
    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_mxm"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, semiring.p, A.p, B.p, desc.p
                    )
                )
end

function GrB_vxm(              # w'<Mask> = accum (w, u'*A)
    w::GrB_Vector,             # input/output vector for results
    mask::T,                   # optional mask for w, unused if NULL
    accum::U,                  # optional accum for z=accum(w,t)
    semiring::GrB_Semiring,    # defines '+' and '*' for u'*A
    u::GrB_Vector,             # first input:  vector u
    A::GrB_Matrix,             # second input: matrix A
    desc::V                    # descriptor for w, mask, and A
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_vxm"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, semiring.p, u.p, A.p, desc.p
                    )
                )
end

function GrB_mxv(               # w<Mask> = accum (w, A*u)
    w::GrB_Vector,              # input/output vector for results
    mask::T,                    # optional mask for w, unused if NULL
    accum::U,                   # optional accum for z=accum(w,t)
    semiring::GrB_Semiring,     # defines '+' and '*' for A*B
    A::GrB_Matrix,              # first input:  matrix A
    u::GrB_Vector,              # second input: vector u
    desc::V                     # descriptor for w, mask, and A
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_mxv"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, semiring.p, A.p, u.p, desc.p
                    )
                )
end
