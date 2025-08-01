#Broadcasting machinery
#######################

# YOU SHALL NOT PASS:
# For real though, some of this is far from pretty and is badly in need of a rewrite to use dispatch.

#All binary ops will default to emul
defaultadd(f) = emul
# Default to eadd. We're limiting this to + and OR for now to enable easy graph unions.
for op ∈ [
    :+,
    :|,
    :∨
]
    funcquote = quote
        defaultadd(::typeof($op)) = eadd
    end
    @eval($funcquote)
end

valunwrap(::Val{x}) where x = x
#This is directly from the Broadcasting interface docs
struct GBVectorStyle <: Broadcast.AbstractArrayStyle{1} end
struct GBMatrixStyle <: Broadcast.AbstractArrayStyle{2} end
Base.BroadcastStyle(::Type{<:AbstractGBVector}) = GBVectorStyle()
Base.BroadcastStyle(::Type{<:AbstractGBMatrix}) = GBMatrixStyle()
Base.BroadcastStyle(::Type{<:Transpose{T, <:AbstractGBMatrix} where T}) = GBMatrixStyle()
Base.BroadcastStyle(::Type{<:Adjoint{T, <:AbstractGBMatrix} where T}) = GBMatrixStyle()
Base.BroadcastStyle(::Type{<:Transpose{T, <:AbstractGBVector} where T}) = GBVectorStyle()
Base.BroadcastStyle(::Type{<:Adjoint{T, <:AbstractGBVector} where T}) = GBVectorStyle()

Base.BroadcastStyle(::Type{<:Base.SubArray{T, N, <:AbstractGBMatrix} where {T, N}}) = GBMatrixStyle()
Base.BroadcastStyle(::Type{<:Base.SubArray{T, 1, <:AbstractGBVector} where T}) = GBVectorStyle()
#
GBVectorStyle(::Val{0}) = GBVectorStyle()
GBVectorStyle(::Val{1}) = GBVectorStyle()
GBVectorStyle(::Val{2}) = GBMatrixStyle()
GBVectorStyle(::Val{N}) where N = Broadcast.DefaultArrayStyle{N}()
GBMatrixStyle(::Val{0}) = GBMatrixStyle()
GBMatrixStyle(::Val{1}) = GBMatrixStyle()
GBMatrixStyle(::Val{2}) = GBMatrixStyle()
GBMatrixStyle(::Val{N}) where N = Broadcast.DefaultArrayStyle{N}()
Broadcast.BroadcastStyle(::GBMatrixStyle, ::GBVectorStyle) = GBMatrixStyle()
Broadcast.BroadcastStyle(::GBMatrixStyle, ::Broadcast.DefaultMatrixStyle) = GBMatrixStyle()
Broadcast.BroadcastStyle(::GBMatrixStyle, ::Broadcast.DefaultVectorStyle) = GBMatrixStyle()

Broadcast.BroadcastStyle(::GBVectorStyle, ::Broadcast.DefaultMatrixStyle) = GBMatrixStyle()
Broadcast.BroadcastStyle(::GBVectorStyle, ::Broadcast.DefaultVectorStyle) = GBVectorStyle()


function Base.similar(
    bc::Broadcast.Broadcasted{GBMatrixStyle},
    ::Type{ElType}
) where {ElType}
    return GBMatrix{ElType}(axes(bc)) # Unfortunate default.
end

function Base.similar(
    bc::Broadcast.Broadcasted{GBVectorStyle},
    ::Type{ElType}
) where {ElType}
    return GBVector{ElType}(axes(bc)) # Okay default.
end

#Find the modifying version of a function.
modifying(::typeof(*)) = mul!
modifying(::typeof(eadd)) = eadd!
modifying(::typeof(emul)) = emul!

# TODO: Fix this horrifically ugly function.
@inline function Base.copy(bc::Broadcast.Broadcasted{GBMatrixStyle})
    f = bc.f
    l = length(bc.args)
    if l == 1
        x = first(bc.args)
        if typeof(x) <: Union{Brodcast.Broadcasted, Base.SubArray}
            x = copy(x)
        end
        return apply(f, x)
    else
        left = first(bc.args)
        right = last(bc.args)
        if left isa Base.RefValue{typeof(^)}
            f = ^
            left = bc.args[2]
            right = valunwrap(right[])
        end
        if left isa Union{Broadcast.Broadcasted, Base.SubArray{Any, Any, <:AbstractGBArray}}
            left = copy(left)
        end
        if left isa AbstractArray && !isconcretetype(promote_type(left, stored_eltype(right)))
            left = pack(left)
        end
        if right isa Union{Broadcast.Broadcasted, Base.SubArray{Any, Any, <:AbstractGBArray}}
            right = copy(right)
        end
        if right isa AbstractArray && !isconcretetype(promote_type(right, stored_eltype(left)))
            right = pack(right)
        end
        
        if left isa GBArrayOrTranspose && right isa GBArrayOrTranspose
            add = defaultadd(f)
            return add(left, right, f)
        else
            leftscalar = !(left isa AbstractArray) || left isa storedeltype(right)
            rightscalar = !(right isa AbstractArray) || right isa storedeltype(left)
            if leftscalar || rightscalar
                return apply(f, left, right)
            end
            return map(f, left, right)
        end
    end
end
mutatingop(::typeof(emul)) = emul!
mutatingop(::typeof(eadd)) = eadd!
mutatingop(::typeof(apply)) = apply!
@inline function Base.copyto!(C::GBArrayOrTranspose, bc::Broadcast.Broadcasted{GBMatrixStyle})
    l = length(bc.args)
    if l == 1
        x = first(bc.args)
        if x isa Broadcast.Broadcasted
            x = copy(x)
        end
        return apply!(bc.f, C, x)
    else
        left = first(bc.args)
        right = last(bc.args)
        # handle annoyances with the pow operator
        if left isa Base.RefValue{typeof(^)}
            f = ^
            left = bc.args[2]
            right = valunwrap(right[])
        end
        # TODO: This if statement should probably be *inside* one of the inner ones to avoid duplication.
        if left === C
            if !(right isa Broadcast.Broadcasted)
                # This should be something of the form A .<op>= <expr> or A .= A .<op> <expr> which are equivalent.
                # this will be done by a subassign
                C[:,:, accum=bc.f] = right
                return C
            else
                # The form A .<op>= expr
                # but not of the form A .= C ... B.
                accum = bc.f
                f = right.f
                if length(right.args) == 1
                    # Should be catching expressions of the form A .<op>= <op>.(B)
                    subarg = first(right.args)
                    if subarg isa Broadcast.Broadcasted
                        subarg = copy(subarg)
                    end
                    return apply!(f, C, subarg; accum)
                else
                    # Otherwise we know there's two operands on the LHS so we have A .<op>= C .<op> B
                    # Or a generalization with any compound *lazy* RHS.
                    (subargleft, subargright) = right.args
                    # subargleft and subargright are C and B respectively.
                    # If they're further nested broadcasts we can't fuse them, so just copy.
                    subargleft isa Broadcast.Broadcasted && (subargleft = copy(subargleft))
                    subargright isa Broadcast.Broadcasted && (subargright = copy(subargright))
                    if subargleft isa StridedArray
                        subargleft = pack(subargleft)
                    end
                    if subargright isa StridedArray
                        subargright = pack(subargright)
                    end
                    if subargleft isa GBArrayOrTranspose && subargright isa GBArrayOrTranspose
                        add = mutatingop(defaultadd(f))
                        return add(C, subargleft, subargright, f; accum)
                    else
                        return apply!(f, C, subargleft, subargright; accum)
                    end
                end
            end
        else
            # Some expression of the form A .= C .<op> B or a generalization
            # excluding A .= A .<op> <expr>, since that is captured above.
            if left isa Broadcast.Broadcasted
                left = copy(left)
            end
            if right isa Broadcast.Broadcasted
                right = copy(right)
            end
            if left isa StridedArray
                left = pack(left)
            end
            if right isa StridedArray
                right = pack(right)
            end
            if left isa GBArrayOrTranspose && right isa GBArrayOrTranspose
                add = mutatingop(defaultadd(f))
                return add(C, left, right, bc.f)
            else
                return apply!(C, bc.f, left, right)
            end
        end
    end
end

@inline function Base.copy(bc::Broadcast.Broadcasted{GBVectorStyle})
    f = bc.f
    l = length(bc.args)
    if l == 1
        x = first(bc.args)
        if x isa Broadcast.Broadcasted
            x = copy(x)
        end
        return apply(f, x)
    else
        left = first(bc.args)
        right = last(bc.args)
        if left isa Base.RefValue{typeof(^)}
            f = ^
            left = bc.args[2]
            right = valunwrap(right[])
        end
        if left isa Union{Broadcast.Broadcasted, Base.SubArray{Any, Any, <:AbstractGBArray}}
            left = copy(left)
        end
        if left isa AbstractArray && !isconcretetype(promote_type(left, stored_eltype(right)))
            left = pack(left)
        end
        if right isa Union{Broadcast.Broadcasted, Base.SubArray{Any, Any, <:AbstractGBArray}}
            right = copy(right)
        end
        if right isa AbstractArray && !isconcretetype(promote_type(right, stored_eltype(left)))
            right = pack(right)
        end
        if left isa GBArrayOrTranspose && right isa GBArrayOrTranspose
            add = defaultadd(f)
            return add(left, right, f)
        else
            return apply(f, left, right)
        end
    end
end

@inline function Base.copyto!(C::AbstractGBArray, bc::Broadcast.Broadcasted{GBVectorStyle})
    l = length(bc.args)
    if l == 1
        x = first(bc.args)
        if bc.f === Base.identity
            C[:] = x
            return C
        end
        if x isa Broadcast.Broadcasted
            x = copy(x)
        end
        return apply!(bc.f, C, x)
    else
        left = first(bc.args)
        right = last(bc.args)
        # handle annoyances with the pow operator
        if left isa Base.RefValue{typeof(^)}
            f = ^
            left = bc.args[2]
            right = valunwrap(right[])
        end
        # TODO: This if statement should probably be *inside* one of the inner ones to avoid duplication.
        if left === C
            if !(right isa Broadcast.Broadcasted)
                # This should be something of the form A .<op>= <expr> or A .= A .<op> <expr> which are equivalent.
                # this will be done by a subassign
                C[:, accum=bc.f] = right
                return C
            else
                # The form A .<op>= expr
                # but not of the form A .= C ... B.
                accum = bc.f
                f = right.f
                if length(right.args) == 1
                    # Should be catching expressions of the form A .<op>= <op>.(B)
                    subarg = first(right.args)
                    if subarg isa Broadcast.Broadcasted
                        subarg = copy(subarg)
                    end
                    return apply!(f, C, subarg; accum)
                else
                    # Otherwise we know there's two operands on the LHS so we have A .<op>= C .<op> B
                    # Or a generalization with any compound *lazy* RHS.
                    (subargleft, subargright) = right.args
                    # subargleft and subargright are C and B respectively.
                    # If they're further nested broadcasts we can't fuse them, so just copy.
                    subargleft isa Broadcast.Broadcasted && (subargleft = copy(subargleft))
                    subargright isa Broadcast.Broadcasted && (subargright = copy(subargright))
                    if subargleft isa StridedArray
                        subargleft = pack(subargleft)
                    end
                    if subargright isa StridedArray
                        subargright = pack(subargright)
                    end
                    if subargleft isa GBArrayOrTranspose && subargright isa GBArrayOrTranspose
                        add = mutatingop(defaultadd(f))
                        return add(C, subargleft, subargright, f; accum)
                    else
                        return apply!(f, C, subargleft, subargright; accum)
                    end
                end
            end
        else
            # Some expression of the form A .= C .<op> B or a generalization
            # excluding A .= A .<op> <expr>, since that is captured above.
            if left isa Broadcast.Broadcasted
                left = copy(left)
            end
            if right isa Broadcast.Broadcasted
                right = copy(right)
            end
            if left isa StridedArray
                left = pack(left)
            end
            if right isa StridedArray
                right = pack(right)
            end
            if left isa GBArrayOrTranspose && right isa GBArrayOrTranspose
                add = mutatingop(defaultadd(bc.f))
                return add(C, left, right, bc.f)
            else
                return apply!(C, bc.f, left, right)
            end
        end
    end
end

# function Base.broadcasted(::Union{<:GBMatrixStyle}, ::Type{X}, A::AbstractGBMatrix)
#     
# end
## Really ugly overloads to make A .= 3 work correctly
# TODO go through the broadcast code and figuring out how this should be done.
function Base.materialize!(
    A::AbstractGBMatrix, bc::Base.Broadcast.Broadcasted{S, Nothing, typeof(identity), T}
) where {S, T}
    return setindex!(A, bc.args[begin], :, :)
end
function Base.materialize!(
    A::AbstractGBVector, bc::Base.Broadcast.Broadcasted{S, Nothing, typeof(identity), T}
) where {S, T}
    return setindex!(A, bc.args[begin], :)
end 

Base.Broadcast.broadcasted(::Type{T}, A::AbstractGBArray) where T = LinearAlgebra.copy_oftype(A, T)

# This is overly verbose, perhaps a macro?
# return an operator that swaps the order of the operands.
# * -> *, first -> second, second -> first, - -> rminus, etc.
_swapop(op) = nothing
_swapop(::typeof(first)) = second
_swapop(::typeof(second)) = first

_swapop(::typeof(any)) = any

_swapop(::typeof(pair)) = pair

_swapop(::typeof(+)) = +
_swapop(::typeof(-)) = rminus
_swapop(::typeof(rminus)) = -

_swapop(::typeof(*)) = *
_swapop(::typeof(/)) = \
_swapop(::typeof(\)) = /

# ^ / POW doesn't have an equivalent builtin... Error for now.

_swapop(::typeof(iseq)) = iseq
_swapop(::typeof(isne)) = isne

_swapop(::typeof(min)) = min
_swapop(::typeof(max)) = max

_swapop(::typeof(isgt)) = isle
_swapop(::typeof(isle)) = isgt

_swapop(::typeof(isge)) = islt
_swapop(::typeof(islt)) = isge

_swapop(::typeof(∨)) = ∨
_swapop(::typeof(∧)) = ∧

_swapop(::typeof(lxor)) = lxor
_swapop(::typeof(xnor)) = xnor

_swapop(::typeof(==)) = ==
_swapop(::typeof(!=)) = !=

_swapop(::typeof(>)) = <=
_swapop(::typeof(<=)) = >
_swapop(::typeof(<)) = >=
_swapop(::typeof(>=)) = <

# I'm not going to bother with the trig/mod/sign/complex/etc. If you need them please open an issue.

_swapop(::typeof(|)) = |
_swapop(::typeof(&)) = &
_swapop(::typeof(⊻)) = ⊻
_swapop(::typeof(bxnor)) = bxnor
# bshift has no obvious equivalent in the builtins

_swapop(::typeof(firsti0)) = secondi0
_swapop(::typeof(secondi0)) = firsti0
_swapop(::typeof(firsti)) = secondi
_swapop(::typeof(secondi)) = firsti

_swapop(::typeof(firstj0)) = secondj0
_swapop(::typeof(secondj0)) = firstj0
_swapop(::typeof(firstj)) = secondj
_swapop(::typeof(secondj)) = firstj
