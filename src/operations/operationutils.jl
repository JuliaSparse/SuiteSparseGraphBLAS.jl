inferunarytype(::Type{T}, f::F) where {T, F<:Base.Callable} = Base._return_type(f, Tuple{T})
inferunarytype(::Type{X}, op::TypedUnaryOperator) where X = ztype(op)

inferbinarytype(::Type{T}, ::Type{U}, f::F) where {T, U, F<:Base.Callable} = Base._return_type(f, Tuple{T, U})
# Overload for `first`, which will give Vector{T} normally:
inferbinarytype(::Type{T}, ::Type{U}, f::typeof(first)) where {T, U} = T
inferbinarytype(::Type{T}, ::Type{U}, op::AbstractMonoid) where {T, U} = inferbinarytype(T, U, op.binaryop.fn)
#semirings are technically binary so we'll just overload that
inferbinarytype(::Type{T}, ::Type{U}, op::Tuple) where {T, U} = inferbinarytype(T, U, semiring(op, T, U))
inferbinarytype(::Type{T}, ::Type{U}, op::TypedSemiring) where {T, U} = inferbinarytype(T, U, op.mulop)

inferbinarytype(::Type{X}, ::Type{Y}, op::TypedBinaryOperator{F, X, Y, Z}) where {F, X, Y, Z} = ztype(op)
inferbinarytype(::Type{X}, ::Type{X}, op::TypedMonoid{F, X, Z}) where {F, X, Z} = ztype(op)
inferbinarytype(::Type{X}, ::Type{Y}, op::TypedSemiring{F, X, Y, Z}) where {F, X, Y, Z} = ztype(op)
inferbinarytype(::Type{X}, ::Type{Y}, op::TypedBinaryOperator{F, X2, Y2, Z}) where {F, X, X2, Y, Y2, Z} = ztype(op)

struct Complement{T}
    parent::T
end

Complement(A::T) where {T<:GBArrayOrTranspose}= Complement{T}(A)
Base.:~(A::T) where {T<:GBArrayOrTranspose} = Complement(A)
Base.parent(C::Complement) = C.parent

struct Structural{T}
    parent::T
end

Structural(A::T) where {T<:GBArrayOrTranspose}= Structural{T}(A)
Base.parent(C::Structural) = C.parent

_handlemask!(desc, mask::Nothing) = C_NULL
_handlemask!(desc, mask::AbstractGBArray) = mask
function _handlemask!(desc, mask)
    while !(mask isa AbstractGBArray)
        if mask isa Transpose
            mask = copy(mask)
        elseif mask isa Complement
            mask = parent(mask)
            desc.complement_mask = true
        elseif mask isa Structural
            mask = parent(mask)
            desc.structural_mask = true
        end
    end
    return mask
end


_handleaccum(::Nothing, t) = C_NULL
_handleaccum(::Ptr{Nothing}, t) = C_NULL
_handleaccum(op::Function, t) = binaryop(op, t, t)
_handleaccum(op::Function, tleft, tright) = binaryop(op, tleft, tright)
_handleaccum(op::TypedBinaryOperator, x...) = op

function _kwargtoc(desc, x)
    x.second === nothing && return C_NULL
    if x.first === :mask
        return _handlemask!(desc, x.second)
    end
    return x.second
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

_promotefill(::Nothing, ::Nothing) = nothing
_promotefill(::Nothing, x) = nothing
_promotefill(x, ::Nothing) = nothing
_promotefill(::Missing, ::Missing) = missing
_promotefill(::Missing, x) = missing
_promotefill(x, ::Missing) = missing
# I'd prefer that this be nothing on x != y. But for type inference reasons this seems better.
# It's not a serious issue for several reasons.
# The first is that GrB methods don't know anything about fill, they don't care.
# The second is that it's free to setfill(A, nothing). Methods that are sensitive to this can enforce that.
# And third a future GBGraph type can manage this for the user.
_promotefill(x::X, y::Y) where {X, Y} = x == y ? (return promote_type(X, Y)(x)) : (return zero(promote_type(X, Y)))