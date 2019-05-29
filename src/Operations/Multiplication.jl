function GrB_mxm(              # C<Mask> = accum (C, A*B)
    C::GrB_Matrix,             # input/output matrix for results
    Mask::GrB_Matrix,          # optional mask for C, unused if NULL
    accum::GrB_BinaryOp,       # optional accum for Z=accum(C,T)
    semiring::GrB_Semiring,    # defines '+' and '*' for A*B
    A::GrB_Matrix,             # first input:  matrix A
    B::GrB_Matrix,             # second input: matrix B
    desc::GrB_Descriptor       # descriptor for C, Mask, A, and B
)

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
    mask::GrB_Vector,          # optional mask for w, unused if NULL
    accum::GrB_BinaryOp,       # optional accum for z=accum(w,t)
    semiring::GrB_Semiring,    # defines '+' and '*' for u'*A
    u::GrB_Vector,             # first input:  vector u
    A::GrB_Matrix,             # second input: matrix A
    desc::GrB_Descriptor       # descriptor for w, mask, and A
)

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
    mask::GrB_Vector,           # optional mask for w, unused if NULL
    accum::GrB_BinaryOp,        # optional accum for z=accum(w,t)
    semiring::GrB_Semiring,     # defines '+' and '*' for A*B
    A::GrB_Matrix,              # first input:  matrix A
    u::GrB_Vector,              # second input: vector u
    desc::GrB_Descriptor        # descriptor for w, mask, and A
)

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_mxv"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, semiring.p, A.p, u.p, desc.p
                    )
                )
end
