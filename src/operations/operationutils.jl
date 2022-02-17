function optype(atype, btype)
    #If atype is signed, optype must be signed and at least big enough.
    if atype <: Integer || btype <: Integer
        if atype <: Signed || btype <: Signed
            p = promote_type(atype, btype)
            if p <: Integer
                return signed(p)
            else
                return p
            end
        else
            return promote_type(atype, btype)
        end
    else
        return promote_type(atype, btype)
    end
end

getaccum(::Nothing, t) = C_NULL
getaccum(op::Function, t) = BinaryOp(op)(t)
getaccum(op::BinaryOp, t) = op(t)
getaccum(op::Function, tleft, tright) = BinaryOp(op)(tleft, tright)
getaccum(op::BinaryOp, tleft, tright) = op(tleft, tright)
getaccum(op::TypedBinaryOperator, tleft, tright=tleft) = op

optype(::GBArray{T}, ::GBArray{U}) where {T, U} = optype(T, U)

inferunarytype(::Type{T}, op::AbstractUnaryOp) where {T} = ztype(op(T))
inferunarytype(::Type{T}, op) where {T} = inferunarytype(T, UnaryOp(op))
inferunarytype(::Type{X}, op::TypedUnaryOperator{F, X, Z}) where {F, X, Z} = ztype(op)

inferbinarytype(::Type{T}, ::Type{U}, op::AbstractBinaryOp) where {T, U} = ztype(op(T, U))
inferbinarytype(::Type{T}, ::Type{U}, op) where {T, U} = inferbinarytype(T, U, BinaryOp(op))
inferbinarytype(::Type{T}, ::Type{U}, op::AbstractMonoid) where {T, U} = inferbinarytype(T, U, op.binaryop)
#semirings are technically binary so we'll just overload that
inferbinarytype(::Type{T}, ::Type{U}, op::Tuple) where {T, U} = inferbinarytype(T, U, Semiring(op))
inferbinarytype(::Type{T}, ::Type{U}, op::AbstractSemiring) where {T, U} = inferbinarytype(T, U, op.mulop)

inferbinarytype(::Type{X}, ::Type{Y}, op::TypedBinaryOperator{F, X, Y, Z}) where {F, X, Y, Z} = ztype(op)
inferbinarytype(::Type{X}, ::Type{X}, op::TypedMonoid{F, X, Z}) where {F, X, Z} = ztype(op)
inferbinarytype(::Type{X}, ::Type{Y}, op::TypedSemiring{F, X, Y, Z}) where {F, X, Y, Z} = ztype(op)

function _handlenothings(kwargs...)
    return (x === nothing ? C_NULL : x for x in kwargs)
end

"""
    xtype(op::GrBOp)::DataType

Determine type of the first argument to a typed operator.
"""
function xtype end

"""
    ytype(op::GrBOp)::DataType

Determine type of the second argument to a typed operator.
"""
function ytype end

"""
    ytype(op::GrBOp)::DataType

Determine type of the output of a typed operator.
"""
function ztype end
