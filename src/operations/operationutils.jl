inferunarytype(::Type{T}, f::F) where {T, F} = Base._return_type(f, Tuple{T})
inferunarytype(::Type{X}, op::TypedUnaryOperator{F, X}) where {F, X} = ztype(op)

inferunarytype(::GBArrayOrTranspose{T}, op) where T = inferunarytype(T, op)

inferbinarytype(::Type{T}, ::Type{U}, f) where {T, U} = Base._return_type(f, Tuple{T, U})
# manual overload for `any` which will give Union{} normally:
inferbinarytype(::Type{T}, ::Type{U}, ::typeof(any)) where {T, U} = promote_type(T, U)
# Overload for `first`, which will give Vector{T} normally:
inferbinarytype(::Type{T}, ::Type{U}, f::typeof(first)) where {T, U} = T

inferbinarytype(::AbstractGBArray{T}, ::AbstractGBArray{U}, f) where {T, U} = inferbinarytype(T, U, f)
inferbinarytype(::AbstractGBArray{T}, ::Type{U}, f) where {T, U} = inferbinarytype(T, U, f)
inferbinarytype(::Type{T}, B::AbstractGBArray{U}, f) where {T, U} = inferbinarytype(T, U, f)

inferbinarytype(::Type{T}, ::Type{U}, op::AbstractMonoid) where {T, U} = inferbinarytype(T, U, op.fn)
#semirings are technically binary so we'll just overload that
inferbinarytype(::Type{T}, ::Type{U}, op::Tuple) where {T, U} = inferbinarytype(T, U, semiring(op, T, U))
inferbinarytype(::Type{T}, ::Type{U}, op::TypedSemiring) where {T, U} = inferbinarytype(T, U, op.mulop)

inferbinarytype(::Type{X}, ::Type{Y}, op::TypedBinaryOperator{F, X, Y, Z}) where {F, X, Y, Z} = ztype(op)
inferbinarytype(::Type{X}, ::Type{X}, op::TypedMonoid{F, X, Z}) where {F, X, Z} = ztype(op)
inferbinarytype(::Type{X}, ::Type{Y}, op::TypedSemiring{F, X, Y, Z}) where {F, X, Y, Z} = ztype(op)
inferbinarytype(::Type{X}, ::Type{Y}, op::TypedBinaryOperator{F, X2, Y2, Z}) where {F, X, X2, Y, Y2, Z} = ztype(op)

"""
    Complement{T}

The complement of a GraphBLAS mask. 
This wrapper will set the mask argument of a GraphBLAS operation to be the negation of the
original mask.

It may be nested an arbitrary number of times.
"""
struct Complement{T}
    parent::T
end

"""
    Structural{T}

This wrapper will set a GraphBLAS mask to use the presence of values in the mask rather
than their values to determine the mask.
"""
struct Structural{T}
    parent::T
end

Complement(A::T) where {
    T<:Union{GBArrayOrTranspose, 
    Structural{<:GBArrayOrTranspose}, 
    Complement{<:GBArrayOrTranspose}}
} = Complement{T}(A)

Base.:~(A::T) where {
    T<:Union{GBArrayOrTranspose, 
    Structural{<:GBArrayOrTranspose}, 
    Complement}
} = Complement(A)
Base.parent(C::Complement) = C.parent

Structural(A::T) where {T<:GBArrayOrTranspose}= Structural{T}(A)
Base.parent(C::Structural) = C.parent

_handlemask!(desc, ::Nothing) = C_NULL
_handlemask!(desc, mask::AbstractGBArray) = mask
function _handlemask!(desc, mask)
    while !(mask isa AbstractGBArray)
        if mask isa Transpose
            mask = copy(mask)
        elseif mask isa Complement
            mask = parent(mask)
            desc.complement_mask = ~desc.complement_mask
        elseif mask isa Structural
            mask = parent(mask)
            desc.structural_mask = true
        elseif mask isa Ptr
            return C_NULL
        else
            throw(ArgumentError("Mask type not recognized."))
        end
    end
    return mask
end

_handleaccum(::Nothing, t) = C_NULL
_handleaccum(::Ptr{Nothing}, t) = C_NULL
_handleaccum(op::Function, t) = binaryop(op, t, t)
_handleaccum(op::Function, tleft, tright) = binaryop(op, tleft, tright)
_handleaccum(op::TypedBinaryOperator, x...) = op

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
    ztype(op::GrBOp)::DataType

Determine type of the output of a typed operator.
"""
function ztype end

_promotefill(::AbstractGBArray{<:Any, Nothing}, ::AbstractGBArray{<:Any, Nothing}, op) = nothing
_promotefill(::AbstractGBArray{<:Any, Nothing}, y, op) = nothing
_promotefill(x, ::AbstractGBArray{<:Any, Nothing}, op) = nothing
_promotefill(::AbstractGBArray{<:Any, Missing}, ::AbstractGBArray{<:Any, Missing}, op) = missing
_promotefill(::AbstractGBArray{<:Any, Missing}, y, op) = nothing
_promotefill(x, ::AbstractGBArray{<:Any, Missing}, op) = nothing
_promotefill(::AbstractGBArray{<:Any, Nothing}, ::AbstractGBArray{<:Any, Missing}, op) = nothing
_promotefill(::AbstractGBArray{<:Any, Missing}, ::AbstractGBArray{<:Any, Nothing}, op) = nothing

_promotefill(x, op) = x

function _promotefill(x::AbstractGBArray{<:Any, T}, y::AbstractGBArray{<:Any, U}, op) where {T, U}
    getfill(x) ≈ getfill(y) && (return inferbinarytype(T, U, op)(getfill(x)))
    return defaultfill(inferbinarytype(T, U, op)) # fallback to defaultfill.
end