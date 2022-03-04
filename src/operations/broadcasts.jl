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
Base.BroadcastStyle(::Type{<:GBVector}) = GBVectorStyle()
Base.BroadcastStyle(::Type{<:GBMatrix}) = GBMatrixStyle()
Base.BroadcastStyle(::Type{<:Transpose{T, <:GBMatrix} where T}) = GBMatrixStyle()
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

function Base.similar(
    bc::Broadcast.Broadcasted{GBMatrixStyle},
    ::Type{ElType}
) where {ElType}
    return GBMatrix{ElType}(axes(bc))
end

function Base.similar(
    bc::Broadcast.Broadcasted{GBVectorStyle},
    ::Type{ElType}
) where {ElType}
    return GBVector{ElType}(axes(bc))
end

#Find the modifying version of a function.
modifying(::typeof(mul)) = mul!
modifying(::typeof(eadd)) = eadd!
modifying(::typeof(emul)) = emul!

@inline function Base.copy(bc::Broadcast.Broadcasted{GBMatrixStyle})
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
        if left isa Broadcast.Broadcasted
            left = copy(left)
        end
        if right isa Broadcast.Broadcasted
            right = copy(right)
        end
        if left isa GBArray && right isa GBArray
            add = defaultadd(f)
            return add(left, right, f)
        else
            return apply(f, left, right)
        end
    end
end
mutatingop(::typeof(emul)) = emul!
mutatingop(::typeof(eadd)) = eadd!
mutatingop(::typeof(apply)) = apply!
@inline function Base.copyto!(C::GBArray, bc::Broadcast.Broadcasted{GBMatrixStyle})
    l = length(bc.args)
    if l == 1
        x = first(bc.args)
        if bc.f === Base.identity
            C[:,:, accum=second] = x
            return C
        end
        if x isa Broadcast.Broadcasted
            x = copy(x)
        end
        return apply!(bc.f, C, x; accum=second)
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
                    if subargleft isa GBArray && subargright isa GBArray
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
            if left isa GBArray && right isa GBArray
                add = mutatingop(defaultadd(f))
                return add(C, left, right, f)
            else
                return apply!(C, f, left, right; accum=second)
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
        if left isa Broadcast.Broadcasted
            left = copy(left)
        end
        if right isa Broadcast.Broadcasted
            right = copy(right)
        end
        if left isa GBArray && right isa GBArray
            add = defaultadd(f)
            return add(left, right, f)
        else
            return apply(f, left, right)
        end
    end
end
