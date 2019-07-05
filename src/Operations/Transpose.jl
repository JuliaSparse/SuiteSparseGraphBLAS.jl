import GraphBLASInterface.GrB_transpose

function GrB_transpose(                 # C<Mask> = accum (C, A')
        C::GrB_Matrix,                  # input/output matrix for results
        Mask::T,                        # optional mask for C, unused if NULL
        accum::U,                       # optional accum for Z=accum(C,T)
        A::GrB_Matrix,                  # first input:  matrix A
        desc::V                         # descriptor for C, Mask, and A
) where {T <: valid_matrix_mask_types, U <: valid_accum_types, V <: valid_desc_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_transpose"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, A.p, desc.p
                    )
                )
end
