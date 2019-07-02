import GraphBLASInterface:
        GrB_Vector_assign, GrB_Matrix_assign, GrB_Col_assign, GrB_Row_assign

function GrB_Vector_assign(         # w<mask>(I) = accum (w(I),u)
        w::GrB_Vector,              # input/output matrix for results
        mask::T,                    # optional mask for w, unused if NULL
        accum::U,                   # optional accum for z=accum(w(I),t)
        u::GrB_Vector,              # first input:  vector u
        I::Y,                       # row indices
        ni::X,                      # number of row indices
        desc::V                     # descriptor for w and mask
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, Y <: valid_indices_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Vector_assign"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cintmax_t}, Cuintmax_t, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, u.p, pointer(I), ni, desc.p
                    )
                )
end

function GrB_Matrix_assign(         # C<Mask>(I,J) = accum (C(I,J),A)
        C::GrB_Matrix,              # input/output matrix for results
        Mask::T,                    # optional mask for C, unused if NULL
        accum::U,                   # optional accum for Z=accum(C(I,J),T)
        A::GrB_Matrix,              # first input:  matrix A
        I::Y,                       # row indices
        ni::X,                      # number of row indices
        J::Z,                       # column indices
        nj::X,                      # number of column indices
        desc::V                     # descriptor for C, Mask, and A
) where {T <: valid_matrix_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, Y <: valid_indices_types, Z <: valid_indices_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Matrix_assign"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Y}, Cuintmax_t, Ptr{Y}, Cuintmax_t, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, A.p, pointer(I), ni, pointer(J), nj, desc.p
                    )
                )
end

function GrB_Col_assign(            # C<mask>(I,j) = accum (C(I,j),u)
        C::GrB_Matrix,              # input/output matrix for results
        mask::T,                    # optional mask for C(:,j), unused if NULL
        accum::U,                   # optional accum for z=accum(C(I,j),t)
        u::GrB_Vector,              # input vector
        I::Y,                       # row indices
        ni::X,                      # number of row indices
        j::X,                       # column index
        desc::V                     # descriptor for C(:,j) and mask
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, Y <: valid_indices_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Col_assign"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cuintmax_t}, Cuintmax_t, Cuintmax_t, Ptr{Cvoid}),
                        C.p, mask.p, accum.p, u.p, pointer(I), ni, j, desc.p
                    )
                )
end

function GrB_Row_assign(            # C<mask'>(i,J) = accum (C(i,J),u')
        C::GrB_Matrix,              # input/output matrix for results
        mask::T,                    # optional mask for C(i,:), unused if NULL
        accum::U,                   # optional accum for z=accum(C(i,J),t)
        u::GrB_Vector,              # input vector
        i::X,                       # row index
        J::Y,                       # column indices
        nj::X,                      # number of column indices
        desc::V                     # descriptor for C(i,:) and mask
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, Y <: valid_indices_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Row_assign"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Cuintmax_t, Ptr{Cuintmax_t}, Cuintmax_t, Ptr{Cvoid}),
                        C.p, mask.p, accum.p, u.p, i, pointer(J), nj, desc.p
                    )
                )
end

function GrB_Vector_assign(         # w<mask>(I) = accum (w(I),x)
        w::GrB_Vector,              # input/output vector for results
        mask::T,                    # optional mask for w, unused if NULL
        accum::U,                   # optional accum for Z=accum(w(I),x)
        x,                          # scalar to assign to w(I)
        I::S,                       # row indices
        ni::X,                      # number of row indices
        desc::V                     # descriptor for w and mask
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, S <: valid_indices_types}

    fn_name = "GrB_Vector_assign_" * suffix(Z)

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, fn_name),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Cintmax_t, Ptr{Cuintmax_t}, Cuintmax_t, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, x, pointer(I), ni, desc.p
                    )
                )
end

function GrB_Vector_assign(         # w<mask>(I) = accum (w(I),x)
        w::GrB_Vector,              # input/output vector for results
        mask::T,                    # optional mask for w, unused if NULL
        accum::U,                   # optional accum for Z=accum(w(I),x)
        x::UInt64,                  # scalar to assign to w(I)
        I::S,                       # row indices
        ni::X,                      # number of row indices
        desc::V                     # descriptor for w and mask
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, S <: valid_indices_types}

    fn_name = "GrB_Vector_assign_UINT64"

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, fn_name),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Cuintmax_t, Ptr{Cuintmax_t}, Cuintmax_t, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, x, pointer(I), ni, desc.p
                    )
                )
end

function GrB_Vector_assign(         # w<mask>(I) = accum (w(I),x)
        w::GrB_Vector,              # input/output vector for results
        mask::T,                    # optional mask for w, unused if NULL
        accum::U,                   # optional accum for Z=accum(w(I),x)
        x::Float64,                 # scalar to assign to w(I)
        I::S,                       # row indices
        ni::X,                      # number of row indices
        desc::V                     # descriptor for w and mask
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, S <: valid_indices_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Vector_assign_FP64"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Cdouble, Ptr{Cuintmax_t}, Cuintmax_t, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, x, pointer(I), ni, desc.p
                    )
                )
end

function GrB_Vector_assign(         # w<mask>(I) = accum (w(I),x)
        w::GrB_Vector,              # input/output vector for results
        mask::T,                    # optional mask for w, unused if NULL
        accum::U,                   # optional accum for Z=accum(w(I),x)
        x::Float32,                 # scalar to assign to w(I)
        I::S,                       # row indices
        ni::X,                      # number of row indices
        desc::V                     # descriptor for w and mask
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, S <: valid_indices_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Vector_assign_FP32"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Cfloat, Ptr{Cuintmax_t}, Cuintmax_t, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, x, pointer(I), ni, desc.p
                    )
                )
end

function GrB_Matrix_assign(         # C<Mask>(I,J) = accum (C(I,J),x)
        C::GrB_Matrix,              # input/output matrix for results
        Mask::T,                    # optional mask for C, unused if NULL
        accum::U,                   # optional accum for Z=accum(C(I,J),x)
        x,                          # scalar to assign to C(I,J)
        I::S,                       # row indices
        ni::X,                      # number of row indices
        J::R,                       # column indices
        nj::X,                      # number of column indices
        desc::V                     # descriptor for C and Mask
) where {T <: valid_matrix_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, R <: valid_indices_types, S <: valid_indices_types}

    fn_name = "GrB_Matrix_assign_" * suffix(Z)

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, fn_name),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Cintmax_t, Ptr{S}, Cuintmax_t, Ptr{S}, Cuintmax_t, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, x, pointer(I), ni, pointer(J), nj, desc.p
                    )
                )
end

function GrB_Matrix_assign(         # C<Mask>(I,J) = accum (C(I,J),x)
        C::GrB_Matrix,              # input/output matrix for results
        Mask::T,                    # optional mask for C, unused if NULL
        accum::U,                   # optional accum for Z=accum(C(I,J),x)
        x::UInt64,                  # scalar to assign to C(I,J)
        I::S,                       # row indices
        ni::X,                      # number of row indices
        J::R,                       # column indices
        nj::X,                      # number of column indices
        desc::V                     # descriptor for C and Mask
) where {T <: valid_matrix_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, R <: valid_indices_types, S <: valid_indices_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Matrix_assign_UINT64"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Cuintmax_t, Ptr{S}, Cuintmax_t, Ptr{S}, Cuintmax_t, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, x, pointer(I), ni, pointer(J), nj, desc.p
                    )
                )
end

function GrB_Matrix_assign(         # C<Mask>(I,J) = accum (C(I,J),x)
        C::GrB_Matrix,              # input/output matrix for results
        Mask::T,                    # optional mask for C, unused if NULL
        accum::U,                   # optional accum for Z=accum(C(I,J),x)
        x::Float64,                 # scalar to assign to C(I,J)
        I::S,                       # row indices
        ni::X,                      # number of row indices
        J::R,                       # column indices
        nj::X,                      # number of column indices
        desc::V                     # descriptor for C and Mask
) where {T <: valid_matrix_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, R <: valid_indices_types, S <: valid_indices_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Matrix_assign_FP64"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Cdouble, Ptr{S}, Cuintmax_t, Ptr{S}, Cuintmax_t, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, x, pointer(I), ni, pointer(J), nj, desc.p
                    )
                )
end

function GrB_Matrix_assign(         # C<Mask>(I,J) = accum (C(I,J),x)
        C::GrB_Matrix,              # input/output matrix for results
        Mask::T,                    # optional mask for C, unused if NULL
        accum::U,                   # optional accum for Z=accum(C(I,J),x)
        x::Float32,                 # scalar to assign to C(I,J)
        I::S,                       # row indices
        ni::X,                      # number of row indices
        J::R,                       # column indices
        nj::X,                      # number of column indices
        desc::V                     # descriptor for C and Mask
) where {T <: valid_matrix_mask_types, U <: valid_accum_types, V <: valid_desc_types, X <: GrB_Index, R <: valid_indices_types, S <: valid_indices_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Matrix_assign_FP32"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Cfloat, Ptr{S}, Cuintmax_t, Ptr{S}, Cuintmax_t, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, x, pointer(I), ni, pointer(J), nj, desc.p
                    )
                )
end
