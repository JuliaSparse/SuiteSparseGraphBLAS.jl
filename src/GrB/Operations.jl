#=
    The standard GrB Operations with the additional subassign extension.

    All functions follow the same pattern:

    1. `C` which is a `GrB_Matrix` or `GrB_Scalar` which has already been initialized.
        The exact modification of C is is determined by the descriptor.

    2. `Mask` which is either a C_NULL or a `GrB_Matrix` which is used 
        to mask the writes into `C`. This mask may be based on either the structure or values,
        which is controlled by the descriptor.

    3. `accum` which is either a C_NULL or a `GrB_BinaryOp` which is used to accumulate
        the results into `C`.

    4. The operator which is applied in the skeleton function. Operator specifics are documented for
        each function.
    
    5. Inputs: These are `GrB_Matrix`, `GrB_Scalar`, or for indexing operations `I` and `J` which may be
        any of the following:
        1. A Vector of Int64 or UInt64, or a CIndex wrapper around those elements. CIndices will be passed
            directly as they are assumed 0 based, Int64, and UInt64 are decremented and then incremented on output.

        2. A range or StepRange which is converted into a 2 or 3 vector of UInt64. Negative steps are allowed.

        3. A colon which is converted into a GrB_ALLType to denote all elements in that dimension.
        
        These arguments *are not* optional.
    6. A keyword argument `desc` which may be C_NULL or a `GrB_Descriptor` which controls the behavior of the operation.
=#

function nothrow_mxm!(
    C::Matrix,
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    semiring, 
    A::Matrix, 
    B::Matrix; 
    desc = C_NULL
)
    return LibGraphBLAS.GrB_mxm(C, Mask, accum, semiring, A, B, desc)
end
function mxm!(
    C::Matrix,
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    semiring, 
    A::Matrix, 
    B::Matrix; 
    desc = C_NULL
)
    _deshallow!(C)
    info = LibGraphBLAS.GrB_mxm(C, Mask, accum, semiring, A, B, desc)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@dimensionmismatch info "Dimension mismatch, got C($(size(C))) = A($(size(A))) * B($(size(B)))"
        GrB.@domainmismatch info semiring A B
        GrB.@uninitializedobject info C semiring A B
        GrB.@fallbackerror info
    end
    return C
end

function nothrow_emul!(
    C::Matrix, 
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    op, 
    A::Matrix, 
    B::Matrix; 
    desc = C_NULL
)
    return LibGraphBLAS.GrB_Matrix_eWiseMult_BinaryOp(C, Mask, accum, op, A, B, desc)
end
function emul!(
    C::Matrix, 
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    op, 
    A::Matrix, 
    B::Matrix; 
    desc = C_NULL
)
    _deshallow!(C)
    info = nothrow_emul!(C, Mask, accum, op, A, B; desc)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@dimensionmismatch info "Dimension mismatch, got C($(size(C))) = A($(size(A))) .$(op) B($(size(B)))"
        GrB.@domainmismatch info op A B
        GrB.@uninitializedobject info C op A B
        GrB.@fallbackerror info
    end
    return C
end

function nothrow_eadd!(
    C::Matrix, 
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    op, 
    A::Matrix, 
    B::Matrix; 
    desc = C_NULL
)
    return LibGraphBLAS.GrB_Matrix_eWiseAdd(C, Mask, accum, op, A, B, desc)
end
function eadd!(
    C::Matrix, 
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    op, 
    A::Matrix, 
    B::Matrix; 
    desc = C_NULL
)
    _unshallow!(C)
    info = LibGraphBLAS.GrB_Matrix_eWiseAdd(C, Mask, accum, op, A, B, desc)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@dimensionmismatch info "Dimension mismatch, got C($(size(C))) = A($(size(A))) .$(op) B($(size(B)))"
        GrB.@domainmismatch info op A B
        GrB.@uninitializedobject info C op A B
        GrB.@fallbackerror info
    end
    return C
end

function nothrow_eunion!(
    C::Matrix, 
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    op, 
    A::Matrix, 
    α::Scalar, 
    B::Matrix, 
    β::Scalar; 
    desc = C_NULL
)
    return LibGraphBLAS.GrB_Matrix_eWiseUnion(C, Mask, accum, op, A, α, B, β, desc)
end
function eunion!(
    C::Matrix, 
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    op, 
    A::Matrix, 
    α::Scalar, 
    B::Matrix, 
    β::Scalar; 
    desc = C_NULL
)
    _deshallow!(C)
    info = LibGraphBLAS.GrB_Matrix_eWiseUnion(C, Mask, accum, op, A, α, B, β, desc)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@dimensionmismatch info "Dimension mismatch, got C($(size(C))) = A($(size(A))) .$(op) B($(size(B)))"
        GrB.@domainmismatch info op A B α β
        GrB.@uninitializedobject info C op A B α β
        GrB.@fallbackerror info
    end
    return C
end

function nothrow_extract!(
    C::Matrix, 
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    A::Matrix, 
    I, J; 
    desc = C_NULL
)
    I, J, i, j = fix_indexlist!(I, J)
    info = LibGraphBLAS.GrB_Matrix_extract(C, Mask, accum, A, I, i, J, j, desc)
    unfix_indexlist!(I, J)
    return info
end
function extract!(
    C::Matrix, 
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    A::Matrix, 
    I, J; 
    desc = C_NULL
)
    _deshallow!(C)
    info = nothrow_extract!(C, Mask, accum, A, I, J, desc)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@dimensionmismatch info "Dimension mismatch, got C($(size(C))) = A($(size(A)))[I, J]"
        GrB.@domainmismatch info C A
        GrB.@uninitializedobject info C A
        GrB.@fallbackerror info
    end
    return C
end



function nothrow_subassign!(
    C::Matrix,
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    A::Matrix, I, J; 
    desc = C_NULL
)
    I, J, i, j = fix_indexlist!(I, J)
    return LibGraphBLAS.GxB_Matrix_subassign(C, Mask, accum, A, I, i, J, j, desc)
    unfix_indexlist!(I, J)
end
function nothrow_subassign!(
    C::Matrix, 
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    x::Scalar, I, J; 
    desc = C_NULL
)
    I, J, i, j = fix_indexlist!(I, J)
    return LibGraphBLAS.GxB_Matrix_subassign_Scalar(C, Mask, accum, x, I, i, J, j, desc)
    unfix_indexlist!(I, J)
end
function subassign!(
    C::Matrix,
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    A, I, J; 
    desc = C_NULL
)
    _deshallow!(C)
    info = nothrow_subassign!(C, Mask, accum, A, I, J; desc)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@dimensionmismatch info "Dimension mismatch, got C($(size(C)))[I, J] = A($(size(A)))"
        GrB.@domainmismatch info C A
        GrB.@uninitializedobject info C A
        GrB.@fallbackerror info
    end
end

function nothrow_assign!(
    C::Matrix,
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    A::Matrix, I, J; 
    desc = C_NULL
)
    I, J, i, j = fix_indexlist!(I, J)
    return LibGraphBLAS.GrB_Matrix_assign(C, Mask, accum, A, I, i, J, j, desc)
    unfix_indexlist!(I, J)
end
function nothrow_assign!(
    C::Matrix, 
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    x::Scalar, I, J; 
    desc = C_NULL
)
    I, J, i, j = fix_indexlist!(I, J)
    return LibGraphBLAS.GxB_Matrix_subassign_Scalar(C, Mask, accum, x, I, i, J, j, desc)
    unfix_indexlist!(I, J)
end
function assign!(
    C::Matrix,
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    A, I, J; 
    desc = C_NULL
)
    _deshallow!(C)
    info = nothrow_assign!(C, Mask, accum, A, I, J; desc)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@dimensionmismatch info "Dimension mismatch, got C($(size(C)))[I, J] = A($(size(A)))"
        GrB.@domainmismatch info C A
        GrB.@uninitializedobject info C A
        GrB.@fallbackerror info
    end
    return A
end

function nothrow_apply!(
    C::Matrix, 
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    op::UnaryOp, 
    A::Matrix; 
    desc = C_NULL
)
    return LibGraphBLAS.GrB_Matrix_apply(C, Mask, accum, op, A, desc)
end
function nothrow_apply!(
    C::Matrix, 
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    op::BinaryOp, 
    A::Matrix, 
    x::Scalar; 
    desc = C_NULL
)
    return LibGraphBLAS.GrB_Matrix_apply_BinaryOp2nd_Scalar(C, Mask, accum, op, A, x, desc)
end
function nothrow_apply!(
    C::Matrix, 
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    op::BinaryOp, 
    x::Scalar, 
    A::Matrix; 
    desc = C_NULL
)
    return LibGraphBLAS.GrB_Matrix_apply_BinaryOp1st_Scalar(C, Mask, accum, op, x, A, desc)
end
function nothrow_apply!(
    C::Matrix, 
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    op::IndexUnaryOp, 
    A::Matrix, 
    thunk::Scalar; 
    desc = C_NULL
)
    return LibGraphBLAS.GrB_Matrix_apply_IndexOp_Scalar(C, Mask, accum, op, A, thunk, desc)
end
function apply!(
    C::Matrix, 
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    op::UnaryOp, 
    A::Matrix; 
    desc = C_NULL
)
    _deshallow!(C)
    info = nothrow_apply!(C, Mask, accum, op, A, desc)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@domainmismatch info op C A
        GrB.@dimensionmismatch info "Dimension mismatch, got C($(size(C))) = op(A($(size(A))))"
        GrB.@uninitializedobject info C op A
        GrB.@fallbackerror info
    end
end
function apply!(
    C::Matrix, 
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    op, 
    A, 
    B; 
    desc = C_NULL
)
    _deshallow!(C)
    info = nothrow_apply!(C, Mask, accum, op, A, B, desc)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@domainmismatch info op C A B
        GrB.@dimensionmismatch info "Dimension mismatch, got C($(size(C))) = op(A($(size(A))), B($(size(B))))"
        GrB.@uninitializedobject info C op A B
        GrB.@fallbackerror info
    end
    return C
end


function nothrow_select!(
    C::Matrix, 
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    op, 
    A::Matrix, 
    thunk::Scalar; 
    desc = C_NULL
)
    return LibGraphBLAS.GrB_Matrix_select_Scalar(C, Mask, accum, op, A, thunk, desc)
end

function select!(
    C::Matrix, 
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    op, 
    A::Matrix, 
    thunk::Scalar; 
    desc = C_NULL
)
    _deshallow!(C)
    info = nothrow_select!(C, Mask, accum, op, A, thunk; desc)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@domainmismatch info op C A thunk
        GrB.@dimensionmismatch info "Dimension mismatch, got C($(size(C))) = select(op, A($(size(A))), thunk)"
        GrB.@uninitializedobject info C op A thunk
        GrB.@fallbackerror info
    end
    return C
end

function nothrow_reduce!(
    C::Matrix, 
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    op, 
    A::Matrix; 
    desc = C_NULL
)
    return LibGraphBLAS.GrB_Matrix_reduce_Monoid(C, Mask, accum, op, A, desc)
end
function nothrow_reduce!(
    C::Scalar, 
    accum, 
    op, 
    A::Matrix; 
    desc = C_NULL
)
    return LibGraphBLAS.GrB_Matrix_reduce_Scalar(C, accum, op, A, desc)
end
function reduce!(
    C,
    Mask::Union{Ptr{Nothing}, Matrix},
    accum::Union{Ptr{Nothing}, BinaryOp},
    op,
    A::Matrix;
    desc = C_NULL
)
    _deshallow!(C)
    info = nothrow_reduce!(C, Mask, accum, op, A, desc)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@domainmismatch info op C A
        GrB.@dimensionmismatch info "Dimension mismatch, got C($(size(C))) = reduce(op, A($(size(A))))"
        GrB.@uninitializedobject info C op A
        GrB.@fallbackerror info
    end
    return C
end

function nothrow_transpose!(
    C::Matrix, 
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    A::Matrix; 
    desc = C_NULL
)
    return LibGraphBLAS.GrB_transpose(C, Mask, accum, A, desc)
end
function transpose!(
    C::Matrix, 
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    A::Matrix; 
    desc = C_NULL
)
    _deshallow!(C)
    info = nothrow_transpose!(C, Mask, accum, A, desc)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@domainmismatch info C A
        GrB.@dimensionmismatch info "Dimension mismatch, got C($(size(C))) = transpose(A($(size(A))))"
        GrB.@uninitializedobject info C A
        GrB.@fallbackerror info
    end
    return C
end

function nothrow_kronecker!(
    C::Matrix, 
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    op, 
    A::Matrix, 
    B::Matrix; 
    desc = C_NULL
)
    return LibGraphBLAS.GrB_kronecker_BinaryOp(C, Mask, accum, op, A, B, desc)
end
function kronecker!(
    C::Matrix, 
    Mask::Union{Ptr{Nothing}, Matrix}, 
    accum::Union{Ptr{Nothing}, BinaryOp}, 
    op, 
    A::Matrix, 
    B::Matrix; 
    desc = C_NULL
)
    _deshallow!(C)
    info = nothrow_kronecker!(C, Mask, accum, op, A, B, desc)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@domainmismatch info op C A B
        GrB.@dimensionmismatch info "Dimension mismatch, got C($(size(C))) = kronecker(op, A($(size(A))), B($(size(B))))"
        GrB.@uninitializedobject info C op A B
        GrB.@fallbackerror info
    end
    return C
end
