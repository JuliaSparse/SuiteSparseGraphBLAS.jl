import GraphBLASInterface:
        GrB_Vector_extract, GrB_Matrix_extract, GrB_Col_extract

function GrB_Vector_extract(            # w<mask> = accum (w, u(I))
        w::GrB_Vector,                  # input/output vector for results
        mask::T,                        # optional mask for w, unused if NULL
        accum::U,                       # optional accum for z=accum(w,t)
        u::GrB_Vector,                  # first input:  vector u
        I::Y,                           # row indices
        ni::X,                          # number of row indices
        desc::V                         # descriptor for w and mask
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, Y <: valid_indices_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Vector_extract"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Y}, Cuintmax_t, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, u.p, pointer(I), ni, desc.p
                    )
                )
end

function GrB_Matrix_extract(            # C<Mask> = accum (C, A(I,J))
        C::GrB_Matrix,                  # input/output matrix for results
        Mask::T,                        # optional mask for C, unused if NULL
        accum::U,                       # optional accum for Z=accum(C,T)
        A::GrB_Matrix,                  # first input:  matrix A
        I::Y,                           # row indices
        ni::X,                          # number of row indices
        J::Z,                           # column indices
        nj::X,                          # number of column indices
        desc::V                         # descriptor for C, Mask, and A
) where {T <: valid_matrix_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, Y <: valid_indices_types, Z <: valid_indices_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Matrix_extract"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Y}, Cuintmax_t, Ptr{Y}, Cuintmax_t, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, A.p, pointer(I), ni, pointer(J), nj, desc.p
                    )
                )
end

function GrB_Col_extract(               # w<mask> = accum (w, A(I,j))
        w::GrB_Vector,                  # input/output matrix for results
        mask::T,                        # optional mask for w, unused if NULL
        accum::U,                       # optional accum for z=accum(w,t)
        A::GrB_Matrix,                  # first input:  matrix A
        I::Y,                           # row indices
        ni::X,                          # number of row indices
        j::X,                           # column index
        desc::V                         # descriptor for w, mask, and A
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, Y <: valid_indices_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Col_extract"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Y}, Cuintmax_t, Cuintmax_t, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, A.p, pointer(I), ni, j, desc.p
                    )
                )
end
