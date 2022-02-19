function wait(A::GBArray)
    waitmode = libgb.GrB_MATERIALIZE
    libgb.GrB_Matrix_wait(A, waitmode)
    return nothing
end

function wait(A::libgb.GrB_UnaryOp)
    waitmode = libgb.GrB_MATERIALIZE
    libgb.GrB_UnaryOp_wait(A, waitmode)
    return nothing
end

function wait(A::libgb.GrB_BinaryOp)
    waitmode = libgb.GrB_MATERIALIZE
    libgb.GrB_BinaryOp_wait(A, waitmode)
    return nothing
end

function wait(A::libgb.GxB_SelectOp)
    waitmode = libgb.GrB_MATERIALIZE
    libgb.GrB_SelectOp_wait(A, waitmode)
    return nothing
end

function wait(A::libgb.GrB_IndexUnaryOp)
    waitmode = libgb.GrB_MATERIALIZE
    libgb.GrB_IndexUnaryOp_wait(A, waitmode)
    return nothing
end

function wait(A::libgb.GrB_Monoid)
    waitmode = libgb.GrB_MATERIALIZE
    libgb.GrB_Monoid_wait(A, waitmode)
    return nothing
end

function wait(A::libgb.GrB_Semiring)
    waitmode = libgb.GrB_MATERIALIZE
    libgb.GrB_Semiring_wait(A, waitmode)
    return nothing
end

function wait(A::GBScalar)
    waitmode = libgb.GrB_MATERIALIZE
    libgb.GrB_Scalar_wait(A, waitmode)
    return nothing
end