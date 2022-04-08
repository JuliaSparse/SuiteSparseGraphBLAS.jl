# TODO:
# vxm shouldn't be done "magically"
# Instead it should be required that we have AdjTrans{<:GBVector} = AdjTrans{<:GBVector} * GBArray.

function LinearAlgebra.mul!(
    C::GBVecOrMat,
    A::GBArray,
    B::GBArray,
    op = (+, *);
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    mask, accum = _handlenothings(mask, accum)
    desc = _handledescriptor(desc; in1=A, in2=B)
    size(A, 2) == size(B, 1) || throw(DimensionMismatch("size(A, 2) != size(B, 1)"))
    size(A, 1) == size(C, 1) || throw(DimensionMismatch("size(A, 1) != size(C, 1)"))
    size(B, 2) == size(C, 2) || throw(DimensionMismatch("size(B, 2) != size(C, 2)"))
    op = Semiring(op)(eltype(A), eltype(B))
    accum = getaccum(accum, eltype(C))
    op isa TypedSemiring || throw(ArgumentError("$op is not a valid TypedSemiring"))
    @wraperror LibGraphBLAS.GrB_mxm(gbpointer(C), mask, accum, op, gbpointer(parent(A)), gbpointer(parent(B)), desc)
    return C
end

function LinearAlgebra.mul!(
    C::GBVecOrMat,
    A::VecOrMat,
    B::GBArray,
    op = (+, *);
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    AGB = GBMatrix{eltype(A)}(size(A, 1), size(A, 2))
    _packdensematrix!(AGB, A)
    _makeshallow!(AGB)
    return mul!(C, AGB, B, op; mask, accum, desc)
end

function LinearAlgebra.mul!(
    C::GBVecOrMat,
    A::GBArray,
    B::VecOrMat,
    op = (+, *);
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    BGB = GBMatrix{eltype(A)}(size(B, 1), size(B, 2))
    _packdensematrix!(BGB, B)
    _makeshallow!(BGB)
    return mul!(C, A, BGB, op; mask, accum, desc)
end

"""
    *(A::GBArray, B::GBArray, op=(+,*); kwargs...)::GBArray

Multiply two `GBArray`s `A` and `B` using a semiring, which defaults to the arithmetic semiring `+.*`.

Either operand may be transposed using `'` or `transpose(A)` provided the dimensions match.

The mutating form, `mul!(C, A, B, op; kwargs...)` is identical except it stores the result in `C::GBVecOrMat`.

The operator syntax `A * B` can be used when the default semiring is desired, and `*(max, +)(A, B)` can be used otherwise.

# Arguments
- `A, B::GBArray`: A GBVector or GBMatrix, possibly transposed.
- `op::Union{Tuple{Function, Function}, AbstractSemiring}`: the semiring used for matrix multiplication. May be passed as a tuple of functions, or an `AbstractSemiring` found in the `Semirings` submodule.
# Keywords
- `mask::Union{Nothing, GBArray} = nothing`: optional mask which determines the output pattern.
- `accum::Union{Nothing, Function, AbstractBinaryOp} = nothing`: optional binary accumulator
    operation such that `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Union{Nothing, Descriptor}`

# Returns
- `GBArray`: The output matrix whose `eltype` is determined by `A` and `B` or the semiring
    if a type specific semiring is provided.
"""
function Base.:*(
    A::GBArray,
    B::GBArray,
    op = (+, *);
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    t = inferbinarytype(eltype(A), eltype(B), op)
    fill = _promotefill(parent(A).fill, parent(B).fill)
    if A isa GBMatOrTranspose && B isa AbstractGBVector
        C = similar(A, t, size(A, 1); fill)
    elseif A isa GBVector && B isa GBMatOrTranspose
        C = similar(A, t, size(B, 2); fill)
    elseif A isa Transpose{<:Any, <:GBVector} && B isa GBVector
        C = similar(A, t, 1; fill)
    else
        C = similar(A, t, (size(A, 1), size(B, 2)); fill)
    end
    mul!(C, A, B, op; mask, accum, desc)
    return C
end

function Base.:*(
    A::VecOrMat,
    B::GBArray,
    op = (+, *);
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    AGB = GBMatrix{eltype(A)}(size(A, 1), size(A, 2))
    _packdensematrix!(AGB, A)
    _makeshallow!(AGB)
    return *(AGB, B, op; mask, accum, desc)
end

function Base.:*(
    A::GBArray,
    B::VecOrMat,
    op = (+, *);
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    BGB = GBMatrix{eltype(B)}(size(B, 1), size(B, 2))
    _packdensematrix!(BGB, B)
    _makeshallow!(BGB)
    return *(A, BGB, op; mask, accum, desc)
end

# clear up some ambiguities:
function Base.:*(
    A::AbstractGBVector{T},
    B::Transpose{T, <:AbstractGBVector{T}};
    mask = nothing,
    accum = nothing,
    desc = nothing
) where {T <: Real}
    return *(A, B, (+, *); mask, accum, desc)
end

function Base.:*(
    A::Transpose{T, <:AbstractGBVector{T}},
    B::AbstractGBVector{T};
    mask = nothing,
    accum = nothing,
    desc = nothing
) where {T <: Real}
    return *(A, B, (+, *); mask, accum, desc)
end

function Base.:*((⊕)::Function, (⊗)::Function)
    return function(A::GBArray, B::GBArray; mask=nothing, accum=nothing, desc=nothing)
        *(A, B, (⊕, ⊗); mask, accum, desc)
    end
end

function Base.:*(rig::AbstractSemiring)
    return function(A::GBArray, B::GBArray; mask=nothing, accum=nothing, desc=nothing)
        *(A, B, rig; mask, accum, desc)
    end
end
