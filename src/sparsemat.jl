module SparseArrayCompat
import SparseArrays
using ..SuiteSparseGraphBLAS
using ..SuiteSparseGraphBLAS: GBMatrix
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
SparseArrays.nnz(A::SparseMatrixGB) = nnz(A.gbmat)
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
function Base.map!(op, A::SparseMatrixGB)
    map!(op, A.gbmat)
    A.fillvalue = op(A.fillvalue)
end
function Base.map!(op, C::SparseMatrixGB, A::SparseMatrixGB)
    map!(op, C, A)
    C.fillvalue = op(A.fillvalue)
end

function Base.map!(op, A::SparseMatrixGB, x)
    map!(op, A.gbmat, x)
    A.fillvalue = op(A.fillvalue, x)
end
function Base.map!(op, C::SparseMatrixGB, A::SparseMatrixGB, x)
    map!(op, C, A, x)
    C.fillvalue = op(A.fillvalue, x)
end

Base.map(op, A::SparseMatrixGB) = SparseMatrixGB(map(op, A.gbmat), op(A.fillvalue))
Base.map(op, A::SparseMatrixGB, x) = SparseMatrixGB(map(op, A.gbmat, x), op(A.fillvalue, x))

function SuiteSparseGraphBLAS.eadd!(C::SparseMatrixGB, A::SparseMatrixGB, B::SparseMatrixGB, op::Function)
    eadd!(C.gbmat, A.gbmat, B.gbmat)
    C.fillvalue = op(A.fillvalue, B.fillvalue)
end
function SuiteSparseGraphBLAS.eadd(A::SparseMatrixGB, B::SparseMatrixGB, op::Function)
    return SparseMatrixGB(eadd(A.gbmat, B.gbmat, op), op(A.fillvalue, B.fillvalue))
end

function SuiteSparseGraphBLAS.emul!(C::SparseMatrixGB, A::SparseMatrixGB, B::SparseMatrixGB, op::Function)
    emul!(C.gbmat, A.gbmat, B.gbmat)
    C.fillvalue = op(A.fillvalue, B.fillvalue)
end
function SuiteSparseGraphBLAS.emul(A::SparseMatrixGB, B::SparseMatrixGB, op::Function)
    return SparseMatrixGB(emul(A.gbmat, B.gbmat, op), op(A.fillvalue, B.fillvalue))
end

# Broadcasting
# There's probably a better way to do this, but < 100 loc duplication is fine.
# This should be kept in sync with the GBMatrix/GBVector broadcasting as much as possible.
valunwrap(::Val{x}) where x = x
#This is directly from the Broadcasting interface docs
struct SparseMatGBStyle <: Broadcast.AbstractArrayStyle{2} end
Base.BroadcastStyle(::Type{<:SparseMatrixGB}) = SparseMatGBStyle()
Base.BroadcastStyle(::Type{<:Transpose{T, <:SparseMatrixGB} where T}) = SparseMatGBStyle()

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
            add = SuiteSparseGraphBLAS.defaultadd(f)
            return add(left, right, f)
        else
            return map(f, left, right)
        end
    end
end

function Base.broadcasted(::typeof(-), A::SparseMatrixGB, B::SparseMatrixGB)
    map!(-, B)
    C = eadd(A, B, +)
    map!(-, B)
    return C
end

end
