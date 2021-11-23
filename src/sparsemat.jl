module SparseArrayCompat
import SparseArrays
using ..SuiteSparseGraphBLAS
using ..SuiteSparseGraphBLAS: GBMatrix, mutatingop, ∨, ∧
using LinearAlgebra
using Base.Broadcast

export SparseMatrixGB
# Basic struct, Base, and SparseArrays definitions:
###################################################
"""
SparseMatrixCSC compatible wrapper over GBMatrix.
"""
mutable struct SparseMatrixGB{Tv} <: SparseArrays.AbstractSparseMatrix{Tv, Int64}
    gbmat::GBMatrix{Tv}
    fillvalue::Tv
    function SparseMatrixGB{Tv}(gbmat::GBMatrix{Tv}, fillval::Fv) where {Tv, Fv}
        gbset(gbmat, :format, :bycol)
        return new(gbmat, promote_type(Tv, Fv)(fillval))
    end
end

function SparseMatrixGB(
    m::Integer, n::Integer, colptr::Vector, rowval::Vector, nzval::Vector{T}, fill=zero(T)
) where {T}
    gbmat = GBMatrix{eltype(nzval)}(
        SuiteSparseGraphBLAS._importcscmat(m, n, colptr, rowval, nzval)
    )
    SparseMatrixGB{eltype(nzval)}(gbmat, fill)
end
SparseMatrixGB{T}(m::Integer, n::Integer, fill=zero(T)) where {T} =
    SparseMatrixGB{T}(GBMatrix{T}(m, n), fill)
SparseMatrixGB{T}(dims::Dims{2}, fill=zero(T)) where {T} =
    SparseMatrixGB(GBMatrix{T}(dims...), fill)
SparseMatrixGB{T}(size::Tuple{Base.OneTo, Base.OneTo}, fill=zero(T)) where {T} =
    SparseMatrixGB(GBMatrix{T}(size[1].stop, size[2].stop), fill)
SparseMatrixGB(
    I::AbstractVector, J::AbstractVector, X::AbstractVector{T}, fill=zero(T);
    m = maximum(I), n = maximum(J)
) where {T} =
    SparseMatrixGB(GBMatrix(I, J, X, nrows=m, ncols=n), fill)
SparseMatrixGB(
    I::AbstractVector, J::AbstractVector, x::T, fill=zero(T);
    m = maximum(I), n = maximum(J)
) where {T} =
    SparseMatrixGB(GBMatrix(I, J, x; nrows=m, ncols=n), fill)
SparseMatrixGB(A::GBMatrix{T}, fill=zero(T)) where {T} = SparseMatrixGB{T}(A, fill)
SparseMatrixGB(A::SparseArrays.SparseMatrixCSC{T}, fill=zero(T)) where{T} =
    SparseMatrixGB{T}(GBMatrix(A), fill)
Base.copy(A::SparseMatrixGB{Tv}) where {Tv} = SparseMatrixGB(copy(A.gbmat), copy(A.fillvalue))
Base.size(A::SparseMatrixGB) = size(A.gbmat)
SparseArrays.nnz(A::SparseMatrixGB) = SparseArrays.nnz(A.gbmat)
Base.eltype(::Type{SparseMatrixGB{Tv}}) where{Tv} = Tv

function Base.similar(A::SparseMatrixGB{Tv}, ::Type{TNew}, dims::Union{Dims{1}, Dims{2}}) where {Tv, TNew}
    return SparseMatrixGB{TNew}(similar(A.gbmat, TNew, dims), A.fillvalue)
end

Base.setindex!(A::SparseMatrixGB, x, i, j) = setindex!(A.gbmat, x, i, j)

function Base.getindex(A::SparseMatrixGB, i, j)
    x = A.gbmat[i,j]
    x === nothing ? (return A.fillvalue) : (return x)
end

SparseArrays.findnz(A::SparseMatrixGB) = SparseArrays.findnz(A.gbmat)
SparseArrays.nonzeros(A::SparseMatrixGB) = SparseArrays.nonzeros(A.gbmat)
SparseArrays.nonzeroinds(A::SparseMatrixGB) = SparseArrays.nonzeroinds(A.gbmat)

function Base.show(io::IO, ::MIME"text/plain", A::SparseMatrixGB)
    SuiteSparseGraphBLAS.gxbprint(io, A.gbmat, "fill value: $(A.fillvalue)")
end

# Math
######
Base.:+(A::SparseMatrixGB, B::SparseMatrixGB) = SparseMatrixGB(A.gbmat + B.gbmat, A.fillvalue + B.fillvalue)

# This will totally ignore fill values and use zero(T).
# I have no idea what to put as the new fill value, so use the default
Base.:*(A::SparseMatrixGB, B::SparseMatrixGB) = SparseMatrixGB(A.gbmat * B.gbmat)

# Mapping
function Base.map!(op, A::SparseMatrixGB; mask = nothing, accum = nothing, desc = nothing)
    map!(op, A.gbmat; mask, accum, desc)
    A.fillvalue = op(A.fillvalue)
end
function Base.map!(op, C::SparseMatrixGB, A::SparseMatrixGB; mask = nothing, accum = nothing, desc = nothing)
    map!(op, C, A; mask, accum, desc)
    C.fillvalue = op(A.fillvalue)
end

function Base.map!(op, A::SparseMatrixGB, x; mask = nothing, accum = nothing, desc = nothing)
    map!(op, A.gbmat, x; mask, accum, desc)
    A.fillvalue = op(A.fillvalue, x)
end
function Base.map!(op, C::SparseMatrixGB, A::SparseMatrixGB, x; mask = nothing, accum = nothing, desc = nothing)
    map!(op, C, A, x; mask, accum, desc)
    C.fillvalue = op(A.fillvalue, x)
end

Base.map(op, A::SparseMatrixGB; mask = nothing, accum = nothing, desc = nothing) =
    SparseMatrixGB(map(op, A.gbmat; mask, accum, desc), op(A.fillvalue))
Base.map(op, A::SparseMatrixGB, x; mask = nothing, accum = nothing, desc = nothing) =
    SparseMatrixGB(map(op, A.gbmat, x), op(A.fillvalue, x))

function SuiteSparseGraphBLAS.eadd!(
    C::SparseMatrixGB, A::SparseMatrixGB, B::SparseMatrixGB, op::Function;
    mask = nothing, accum = nothing, desc = nothing
)
    eunion!(C.gbmat, A.gbmat, A.fillvalue, B.gbmat, B.fillvalue; mask, accum, desc)
    C.fillvalue = op(A.fillvalue, B.fillvalue)
end
function SuiteSparseGraphBLAS.eadd(
    A::SparseMatrixGB, B::SparseMatrixGB, op::Function;
    mask = nothing, accum = nothing, desc = nothing
)
    return SparseMatrixGB(
        eunion(A.gbmat, A.fillvalue, B.gbmat, B.fillvalue, op; mask, accum, desc),
        op(A.fillvalue, B.fillvalue)
    )
end

function SuiteSparseGraphBLAS.emul!(
    C::SparseMatrixGB, A::SparseMatrixGB, B::SparseMatrixGB, op::Function;
    mask = nothing, accum = nothing, desc = nothing
)
    emul!(C.gbmat, A.gbmat, B.gbmat; mask, accum, desc)
    C.fillvalue = op(A.fillvalue, B.fillvalue)
end
function SuiteSparseGraphBLAS.emul(
    A::SparseMatrixGB, B::SparseMatrixGB, op::Function;
    mask = nothing, accum = nothing, desc = nothing
)
    return SparseMatrixGB(
        emul(A.gbmat, B.gbmat, op; mask, accum, desc),
        op(A.fillvalue, B.fillvalue)
    )
end

# Broadcasting
# There's probably a better way to do this, but < 100 loc duplication is fine.
# This should be kept in sync with the GBMatrix/GBVector broadcasting as much as possible.
valunwrap(::Val{x}) where x = x
#This is directly from the Broadcasting interface docs
struct SparseMatGBStyle <: Broadcast.AbstractArrayStyle{2} end
Base.BroadcastStyle(::Type{<:SparseMatrixGB}) = SparseMatGBStyle()
Base.BroadcastStyle(::Type{<:Transpose{T, <:SparseMatrixGB} where T}) = SparseMatGBStyle()

# We don't want the defaultadd for GBMatrix, since we want to default to SparseMatrixCSC behavior
defaultadd(::Function) = eadd
for op ∈ [
    :*,
    :∧,
]
    funcquote = quote
        defaultadd(::typeof($op)) = emul
    end
    @eval($funcquote)
end

SparseMatGBStyle(::Val{0}) = SparseMatGBStyle()
SparseMatGBStyle(::Val{1}) = SparseMatGBStyle()
SparseMatGBStyle(::Val{2}) = SparseMatGBStyle()
SparseMatGBStyle(::Val{N}) where N = Broadcast.DefaultArrayStyle{N}()

function Base.similar(
    bc::Broadcast.Broadcasted{SparseMatGBStyle},
    ::Type{ElType}
) where {ElType}
    return SparseMatrixGB{ElType}(axes(bc))
end

@inline function Base.copy(bc::Broadcast.Broadcasted{SparseMatGBStyle})
    f = bc.f
    l = length(bc.args)
    if l == 1
        x = first(bc.args)
        if x isa Broadcast.Broadcasted
            x = copy(x)
        end
        return map(f, x)
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
        if left isa SparseMatrixGB && right isa SparseMatrixGB
            add = defaultadd(f)
            return add(left, right, f)
        else
            return map(f, left, right)
        end
    end
end

@inline function Base.copyto!(C::SparseMatrixGB, bc::Broadcast.Broadcasted{SparseMatGBStyle})
    l = length(bc.args)
    if l == 1
        x = first(bc.args)
        if bc.f === Base.identity
            C[:,:, accum=second] = x
            return C
        end
        return map!(bc.f, C, x; accum=second)
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
                    return map!(f, C, subarg; accum)
                else
                    # Otherwise we know there's two operands on the LHS so we have A .<op>= C .<op> B
                    # Or a generalization with any compound *lazy* RHS.
                    (subargleft, subargright) = right.args
                    # subargleft and subargright are C and B respectively.
                    # If they're further nested broadcasts we can't fuse them, so just copy.
                    subargleft isa Broadcast.Broadcasted && (subargleft = copy(subargleft))
                    subargright isa Broadcast.Broadcasted && (subargright = copy(subargright))
                    if subargleft isa SparseMatrixGB && subargright isa SparseMatrixGB
                        add = mutatingop(defaultadd(f))
                        return add(C, subargleft, subargright, f; accum)
                    else
                        return map!(f, C, subargleft, subargright; accum)
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
            if left isa SparseMatrixGB && right isa SparseMatrixGB
                add = mutatingop(defaultadd(f))
                return add(C, left, right, f)
            else
                return map!(C, f, left, right; accum=second)
            end
        end
    end
end

LinearAlgebra.kron!(C::SparseMatrixGB, A::SparseMatrixGB, B::SparseMatrixGB) =
    LinearAlgebra.kron!(C.gbmat, A.gbmat, B.gbmat)
LinearAlgebra.kron(C::SparseMatrixGB, A::SparseMatrixGB, B::SparseMatrixGB) =
    LinearAlgebra.kron(C.gbmat, A.gbmat, B.gbmat)


end
