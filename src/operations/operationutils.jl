inferunarytype(::Type{T}, f) where {T} = Broadcast.combine_eltypes(f, (T,))
inferunarytype(::GBArrayOrTranspose{T}, op) where T = inferunarytype(T, op)
inferunarytype(A, f) = inferunarytype(storedeltype(A), f)

inferbinarytype(::Type{T}, ::Type{U}, f) where {T, U} = Broadcast.combine_eltypes(f, (T, U))
# manual overload for `any` which will give Union{} normally:
inferbinarytype(::Type{T}, ::Type{U}, ::typeof(any)) where {T, U} = promote_type(T, U)
# Overload for `first`, which will give Vector{T} normally:
inferbinarytype(::Type{T}, ::Type{U}, f::typeof(first)) where {T, U} = T

inferbinarytype(::GBArrayOrTranspose{T}, ::GBArrayOrTranspose{U}, f) where {T, U} = inferbinarytype(T, U, f)
inferbinarytype(::GBArrayOrTranspose{T}, ::Type{U}, f) where {T, U} = inferbinarytype(T, U, f)
inferbinarytype(::Type{T}, B::GBArrayOrTranspose{U}, f) where {T, U} = inferbinarytype(T, U, f)
inferbinarytype(A, B, f) = inferbinarytype(storedeltype(A), storedeltype(B), f)

inferbinarytype(::Type{T}, ::Type{U}, op::AbstractMonoid) where {T, U} = inferbinarytype(T, U, op.fn)
#semirings are technically binary so we'll just overload that
inferbinarytype(::Type{T}, ::Type{U}, op::Tuple) where {T, U} = inferbinarytype(T, U, op[1])

inferunarytype(::Type{X}, op::TypedUnaryOperator) where X = ztype(op)
inferbinarytype(::Type{X}, ::Type{Y}, op::TypedBinaryOperator) where {X, Y} = ztype(op)
inferbinarytype(::Type{X}, ::Type{X}, op::TypedMonoid) where {X} = ztype(op)
inferbinarytype(::Type{X}, ::Type{Y}, op::TypedSemiring) where {X, Y} = ztype(op)

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

_handlemask!(desc, ::Nothing) = desc, C_NULL
_handlemask!(desc, mask::AbstractGBArray) = desc, mask
function _handlemask!(desc, mask)
    while !(mask isa AbstractGBArray)
        if mask isa Transpose
            mask = copy(mask)
        elseif mask isa Complement
            mask = parent(mask)
            !(desc isa Descriptor) && (desc = Descriptor())                
            desc.complement_mask = ~desc.complement_mask
        elseif mask isa Structural
            mask = parent(mask)
            !(desc isa Descriptor) && (desc = Descriptor())           
            desc.structural_mask = true
        elseif mask isa Ptr
            return desc, C_NULL
        else
            throw(ArgumentError("Mask type not recognized."))
        end
    end
    return desc, mask
end

_handleaccum(::Nothing, t...) = C_NULL
_handleaccum(::Ptr{Nothing}, t...) = C_NULL
_handleaccum(op::Function, out, intermediate) = binaryop(op, out, intermediate, out)
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

iscommutative(f) = false
iscommutative(::typeof(*)) = true
iscommutative(::typeof(+)) = true
iscommutative(::typeof(BinaryOps.pair)) = true
iscommutative(::typeof(any)) = true
iscommutative(::typeof(min)) = true
iscommutative(::typeof(max)) = true
iscommutative(::typeof(==)) = true
iscommutative(::typeof(≠)) = true
iscommutative(::typeof(BinaryOps.iseq)) = true
iscommutative(::typeof(BinaryOps.isne)) = true
iscommutative(::typeof(BinaryOps.lxor)) = true
iscommutative(::typeof(BinaryOps.bxnor)) = true
iscommutative(::typeof(∨)) = true
iscommutative(::typeof(∧)) = true
iscommutative(::typeof(⊻)) = true
iscommutative(::typeof(|)) = true
iscommutative(::typeof(&)) = true



"""
    f_flipxy(f)::Union{Function, Nothing}

Return a function which computes the same value as `f` with the arguments flipped.

For commutative functions, where `iscommutative(f) == true` this returns `f`. 
However for some functions, for instance `-`, this is incorrect. For these functions
it defaults to `(y, x) -> f(x, y)`.


"""
f_flipxy(f) = iscommutative ? f : (y, x) -> f(x, y)
# To be sure we use built-ins where possible:
f_flipxy(::typeof(-)) = BinaryOps.rminus
f_flipxy(::typeof(BinaryOps.rminus)) = (-)
f_flipxy(::typeof(first)) = BinaryOps.second
f_flipxy(::typeof(BinaryOps.second)) = first
f_flipxy(::typeof(/)) = \
f_flipxy(::typeof(\)) = /
f_flipxy(::typeof(BinaryOps.firsti0)) = BinaryOps.secondi0
f_flipxy(::typeof(BinaryOps.secondi0)) = BinaryOps.firsti0
f_flipxy(::typeof(BinaryOps.firsti)) = BinaryOps.secondi
f_flipxy(::typeof(BinaryOps.secondi)) = BinaryOps.firsti
f_flipxy(::typeof(BinaryOps.firstj0)) = BinaryOps.secondj0
f_flipxy(::typeof(BinaryOps.secondj0)) = BinaryOps.firstj0
f_flipxy(::typeof(BinaryOps.firstj)) = BinaryOps.secondj
f_flipxy(::typeof(BinaryOps.secondj)) = BinaryOps.firstj
f_flipxy(::typeof(>)) = <
f_flipxy(::typeof(<)) = >
f_flipxy(::typeof(≤)) = ≥
f_flipxy(::typeof(≥)) = ≤


"""
    f_flipxy(f)::Union{Function, Nothing}
#=
# Unary fill propagation
_unary_propagatefill(::AbstractGBArray{T, NoValue}) where T = novalue
_unary_propagatefill(A::AbstractGBArray, op) = op(getfill(A))

_unary_propagatefill!(C::AbstractGBArray{T, T}, ::Nothing, A::AbstractGBArray{U, U}, op) where {T, U} = 
    setfill!(C, op(getfill(A)))
_unary_propagatefill!(C::AbstractGBArray{T}, _, ::AbstractGBArray{U}, _) where {T, U} = 
    nothing
_unary_propagatefill!(C::AbstractGBArray{T, T}, accum, A::AbstractGBArray{U, U}, op) where {T, U} = 
    setfill!(accum(getfill(C), op(getfill(A))))


# Additive binary fill propagation:
_additive_propagatefill(::AbstractGBArray{T, NoValue}, ::AbstractGBArray{U, NoValue}, op) where {T, U} = novalue
_additive_propagatefill(::AbstractGBArray{T, NoValue}, B::AbstractGBArray, op) where {T} = getfill(B)
_additive_propagatefill(A::AbstractGBArray, ::AbstractGBArray{U, NoValue}, op) where {U} = getfill(A)
_additive_propagatefill(A::AbstractGBArray, B::AbstractGBArray, op) = op(getfill(A), getfill(B))
_additive_propagatefill(A, B::AbstractGBArray, op) = op(A, getfill(B))
_additive_propagatefill(A::AbstractGBArray, B, op) = op(getfill(A), B)
_additive_propagatefill(A, ::NoValue, op) = A
_additive_propagatefill(::NoValue, B, op) = B
_additive_propagatefill(A, B, op) = op(A, B)

# Multiplicative binary fill propagation:
# Unlike additive propagation we can't just use the other operand when we encounter a novalue.
# Instead of bailing out we will propagate the novalue.
# This is sort of poisonous, but it's the only way to get reasonable behavior in general.
# TODO: investigate whether we can do better? We know what to do for certain operators (for instance (ℝ, +) unit is 0).
# TODO: Document these behaviors, and recommend that users use mutating versions when this behavior is not desired.
_multiplicative_propagatefill(::AbstractGBArray{T, NoValue}, ::AbstractGBArray{U, NoValue}, op) where {T, U} = novalue
_multiplicative_propagatefill(::AbstractGBArray{T, NoValue}, ::AbstractGBArray, op) where {T} = novalue
_multiplicative_propagatefill(::AbstractGBArray, ::AbstractGBArray{U, NoValue}, op) where {U} = novalue
_multiplicative_propagatefill(A::AbstractGBArray, B::AbstractGBArray, op) = op(getfill(A), getfill(B))
_multiplicative_propagatefill(A, B::AbstractGBArray, op) = op(A, getfill(B))
_multiplicative_propagatefill(A::AbstractGBArray, B, op) = op(getfill(A), B)
_multiplicative_propagatefill(A, ::NoValue, op) = novalue
_multiplicative_propagatefill(::NoValue, B, op) = novalue
_multiplicative_propagatefill(A, B, op) = op(A, B)

# As above, we will use novalue as a poison, but we have additional info here.
# If the fills match the semiring fills we can propagate safely.
_semiring_propagatefill(::AbstractGBArray{T, NoValue}, ::AbstractGBArray{U, NoValue}, op) where {T, U} = novalue
_semiring_propagatefill(::AbstractGBArray{T, NoValue}, ::AbstractGBArray, op) where {T} = novalue
_semiring_propagatefill(::AbstractGBArray, ::AbstractGBArray{U, NoValue}, op) where {U} = novalue

# propagate these fills:
function _semiring_propagatefill(A::AbstractGBArray{T}, B::AbstractGBArray{U}, op) where {T, U}
    fA, fB = getfill.((A, B))
    rig = semiring(op, T, U)
    mon = monoid(rig) # this should be typed.
    id = mon.identity
    if fA == id && fB == id
        return identity
    else
        return novalue
    end
end
=#
"""

