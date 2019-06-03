function GrB_Matrix_reduce_Monoid(          # w<mask> = accum (w,reduce(A))
    w::GrB_Vector,                          # input/output vector for results
    mask::T,                                # optional mask for w, unused if NULL
    accum::U,                               # optional accum for z=accum(w,t)
    monoid::GrB_Monoid,                     # reduce operator for t=reduce(A)
    A::GrB_Matrix,                          # first input:  matrix A
    desc::V                                 # descriptor for w, mask, and A
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Matrix_reduce_Monoid"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, monoid.p, A.p, desc.p
                    )
                )
end

function GrB_Matrix_reduce_BinaryOp(        # w<mask> = accum (w,reduce(A))
    w::GrB_Vector,                          # input/output vector for results
    mask::T,                                # optional mask for w, unused if NULL
    accum::U,                               # optional accum for z=accum(w,t)
    op::GrB_BinaryOp,                       # reduce operator for t=reduce(A)
    A::GrB_Matrix,                          # first input:  matrix A
    desc::V                                 # descriptor for w, mask, and A
) where {T <: valid_vector_mask_types, U <: valid_accum_types, V <: valid_desc_types}

    return GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Matrix_reduce_BinaryOp"),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        w.p, mask.p, accum.p, op.p, A.p, desc.p
                    )
                )
end

function GrB_Vector_reduce(                 # c = accum (c, reduce_to_scalar (u))
    accum::U,                               # optional accum for c=accum(c,t)
    monoid::GrB_Monoid,                     # monoid to do the reduction
    u::GrB_Vector{T},                       # vector to reduce
    desc::V                                 # descriptor (currently unused)
) where {T <: valid_types, U <: valid_accum_types, V <: valid_desc_types}

    scalar = Ref(T(0))
    fn_name = "GrB_Vector_reduce_" * suffix(T)

    res =   GrB_Info(
                ccall(
                        dlsym(graphblas_lib, fn_name),
                        Cint,
                        (Ptr{T}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        scalar, accum.p, monoid.p, u.p, desc.p
                    )
                )

    res != GrB_SUCCESS && return res
    return scalar[]
end

function GrB_Matrix_reduce(                 # c = accum (c, reduce_to_scalar (A))
    accum::U,                               # optional accum for c=accum(c,t)
    monoid::GrB_Monoid,                     # monoid to do the reduction
    A::GrB_Matrix{T},                       # matrix to reduce
    desc::V                                 # descriptor (currently unused)
) where {T <: valid_types, U <: valid_accum_types, V <: valid_desc_types}

    scalar = Ref(T(0))
    fn_name = "GrB_Matrix_reduce_" * suffix(T)

    res =   GrB_Info(
                ccall(
                        dlsym(graphblas_lib, fn_name),
                        Cint,
                        (Ptr{T}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                        scalar, A.p, monoid.p, u.p, desc.p
                    )
                )

    res != GrB_SUCCESS && return res
    return scalar[]
end
