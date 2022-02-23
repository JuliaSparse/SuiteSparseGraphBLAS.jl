function wait(A::GBArray)
    waitmode = LibGraphBLAS.GrB_MATERIALIZE
    @wraperror LibGraphBLAS.GrB_Matrix_wait(A, waitmode)
    return nothing
end

function wait(A::LibGraphBLAS.GrB_UnaryOp)
    waitmode = LibGraphBLAS.GrB_MATERIALIZE
    @wraperror LibGraphBLAS.GrB_UnaryOp_wait(A, waitmode)
    return nothing
end

function wait(A::LibGraphBLAS.GrB_BinaryOp)
    waitmode = LibGraphBLAS.GrB_MATERIALIZE
    @wraperror LibGraphBLAS.GrB_BinaryOp_wait(A, waitmode)
    return nothing
end

function wait(A::LibGraphBLAS.GxB_SelectOp)
    waitmode = LibGraphBLAS.GrB_MATERIALIZE
    @wraperror LibGraphBLAS.GrB_SelectOp_wait(A, waitmode)
    return nothing
end

function wait(A::LibGraphBLAS.GrB_IndexUnaryOp)
    waitmode = LibGraphBLAS.GrB_MATERIALIZE
    @wraperror LibGraphBLAS.GrB_IndexUnaryOp_wait(A, waitmode)
    return nothing
end

function wait(A::LibGraphBLAS.GrB_Monoid)
    waitmode = LibGraphBLAS.GrB_MATERIALIZE
    @wraperror LibGraphBLAS.GrB_Monoid_wait(A, waitmode)
    return nothing
end

function wait(A::LibGraphBLAS.GrB_Semiring)
    waitmode = LibGraphBLAS.GrB_MATERIALIZE
    @wraperror LibGraphBLAS.GrB_Semiring_wait(A, waitmode)
    return nothing
end

function wait(A::GBScalar)
    waitmode = LibGraphBLAS.GrB_MATERIALIZE
    @wraperror LibGraphBLAS.GrB_Scalar_wait(A, waitmode)
    return nothing
end