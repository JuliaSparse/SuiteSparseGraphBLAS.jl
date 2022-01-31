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

optype(::GBArray{T}, ::GBArray{U}) where {T, U} = optype(T, U)

# TODO: REMOVE
function inferoutputtype(::GBArray{T}, ::GBArray{U}, op) where {T, U}
    t = optype(T, U)
    if op isa Tuple
        op = Semiring(op...)
    else
        op = BinaryOp(op)
    end
    return ztype(op, t)
end

function inferoutputtype(::GBArray{T}, ::GBArray{U}, op::AbstractBinaryOp) where {T, U}
    return Base._return_type(juliaop(op), (T, U))
end



function inferoutputtype(::GBArray{T}, ::GBArray{U}, op::AbstractSemiring) where {T, U}
    bintype = Base._return_type(mulop(op), (T, U))
    return Base._return_type(addop(op), (bintype, bintype))
end
function inferoutputtype(::GBArray{T}, op::AbstractOp) where {T}
    return Base._return_type(juliaop(op), (T,))
end

# function inferoutputtype(::GBArray{T}, ::AbstractTypedOp{Z}) where {T, Z}
#     return Z
# end
# function inferoutputtype(::GBArray{T}, ::GBArray{U}, ::AbstractTypedOp{Z}) where {T, U, Z}
#     return Z
# end

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
