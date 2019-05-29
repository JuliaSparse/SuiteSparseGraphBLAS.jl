function GrB_eWiseMult(C::T, mask::T, accum::GrB_BinaryOp, op::U, A::T, B::T,
    desc::GrB_Descriptor) where {T <: Union{GrB_Vector, GrB_Matrix}, U <: Union{GrB_BinaryOp, GrB_Monoid, GrB_Semiring}}

    T_name = get_struct_name(A)
    U_name = get_struct_name(op)

    fn_name = "GrB_eWiseMult_" * T_name * "_" * U_name

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, fn_name),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        C.p, mask.p, accum.p, op.p, A.p, B.p, desc.p
                    )
                )
end

function GrB_eWiseMult_Vector_Semiring(         # w<Mask> = accum (w, u.*v)
        w::GrB_Vector,                          # input/output vector for results
        mask::GrB_Vector,                       # optional mask for w, unused if NULL
        accum::GrB_BinaryOp,                    # optional accum for z=accum(w,t)
        semiring::GrB_Semiring,                 # defines '.*' for t=u.*v
        u::GrB_Vector,                          # first input:  vector u
        v::GrB_Vector,                          # second input: vector v
        desc::GrB_Descriptor                    # descriptor for w and mask
)

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_eWiseMult_Vector_Semiring"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, semiring.p, u.p, v.p, desc.p
                    )
                )
end

function GrB_eWiseMult_Vector_Monoid(           # w<Mask> = accum (w, u.*v)
        w::GrB_Vector,                          # input/output vector for results
        mask::GrB_Vector,                       # optional mask for w, unused if NULL
        accum::GrB_BinaryOp,                    # optional accum for z=accum(w,t)
        monoid::GrB_Monoid,                     # defines '.*' for t=u.*v
        u::GrB_Vector,                          # first input:  vector u
        v::GrB_Vector,                          # second input: vector v
        desc::GrB_Descriptor                    # descriptor for w and mask
)

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_eWiseMult_Vector_Monoid"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, monoic.p, u.p, v.p, desc.p
                    )
                )
end

function GrB_eWiseMult_Vector_BinaryOp(         # w<Mask> = accum (w, u.*v)
        w::GrB_Vector,                          # input/output vector for results
        mask::GrB_Vector,                       # optional mask for w, unused if NULL
        accum::GrB_BinaryOp,                    # optional accum for z=accum(w,t)
        mult::GrB_BinaryOp,                     # defines '.*' for t=u.*v
        u::GrB_Vector,                          # first input:  vector u
        v::GrB_Vector,                          # second input: vector v
        desc::GrB_Descriptor                    # descriptor for w and mask
)

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_eWiseMult_Vector_BinaryOp"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, mult.p, u.p, v.p, desc.p
                    )
                )
end

function GrB_eWiseMult_Matrix_Semiring(         # C<Mask> = accum (C, A.*B)
    C::GrB_Matrix,                              # input/output matrix for results
    Mask::GrB_Matrix,                           # optional mask for C, unused if NULL
    accum::GrB_BinaryOp,                        # optional accum for Z=accum(C,T)
    semiring::GrB_Semiring,                     # defines '.*' for T=A.*B
    A::GrB_Matrix,                              # first input:  matrix A
    B::GrB_Matrix,                              # second input: matrix B
    desc::GrB_Descriptor                        # descriptor for C, Mask, A, and B
)

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, fn_name),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, semiring.p, A.p, B.p, desc.p
                    )
                )
end

function GrB_eWiseMult_Matrix_Monoid(           # C<Mask> = accum (C, A.*B)
    C::GrB_Matrix,                              # input/output matrix for results
    Mask::GrB_Matrix,                           # optional mask for C, unused if NULL
    accum::GrB_BinaryOp,                        # optional accum for Z=accum(C,T)
    monoid::GrB_Monoid,                         # defines '.*' for T=A.*B
    A::GrB_Matrix,                              # first input:  matrix A
    B::GrB_Matrix,                              # second input: matrix B
    desc::GrB_Descriptor                        # descriptor for C, Mask, A, and B
)

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, fn_name),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, monoid.p, A.p, B.p, desc.p
                    )
                )
end

function GrB_eWiseMult_Matrix_BinaryOp(         # C<Mask> = accum (C, A.*B)
    C::GrB_Matrix,                              # input/output matrix for results
    Mask::GrB_Matrix,                           # optional mask for C, unused if NULL
    accum::GrB_BinaryOp,                        # optional accum for Z=accum(C,T)
    mult::GrB_BinaryOp,                         # defines '.*' for T=A.*B
    A::GrB_Matrix,                              # first input:  matrix A
    B::GrB_Matrix,                              # second input: matrix B
    desc::GrB_Descriptor                        # descriptor for C, Mask, A, and B
)

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, fn_name),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        C.p, Mask.p, accum.p, mult.p, A.p, B.p, desc.p
                    )
                )
end
