function LinearAlgebra.mul!(
    C::GBVecOrMat,
    A::GBArrayOrTranspose,
    B::GBArrayOrTranspose,
    op = (+, *);
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    _canbeoutput(C) || throw(ShallowException())
    desc = _handledescriptor(desc; out=C, in1=A, in2=B)
    desc, mask = _handlemask!(desc, mask)
    size(A, 2) == size(B, 1) || throw(DimensionMismatch("size(A, 2) != size(B, 1)"))
    size(A, 1) == size(C, 1) || throw(DimensionMismatch("size(A, 1) != size(C, 1)"))
    size(B, 2) == size(C, 2) || throw(DimensionMismatch("size(B, 2) != size(C, 2)"))
    op = semiring(op, storedeltype(A), storedeltype(B))
    accum = _handleaccum(accum, storedeltype(C))
    op isa TypedSemiring || throw(ArgumentError("$op is not a valid TypedSemiring"))
    @wraperror LibGraphBLAS.GrB_mxm(C, mask, accum, op, parent(A), parent(B), desc)
    return C
end

function LinearAlgebra.mul!(
    C::GBVecOrMat,
    A::VecMatOrTrans,
    B::GBArrayOrTranspose,
    op = (+, *);
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    _canbeoutput(C) || throw(ShallowException())
    return @_densepack A mul!(C, A, B, op; mask, accum, desc)
end

function LinearAlgebra.mul!(
    C::GBVecOrMat,
    A::GBArrayOrTranspose,
    B::VecMatOrTrans,
    op = (+, *);
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    _canbeoutput(C) || throw(ShallowException())
    return @_densepack B mul!(C, A, B, op; mask, accum, desc)
end

function LinearAlgebra.mul!(
    C::GBVecOrMat,
    A::VecMatOrTrans,
    B::VecMatOrTrans,
    op = (+, *);
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    _canbeoutput(C) || throw(ShallowException())
    return @_densepack A B mul!(C, A, B, op; mask, accum, desc)
end

"""
    *(A::GBArrayOrTranspose, B::GBArrayOrTranspose, op=(+,*); kwargs...)::GBArrayOrTranspose

Multiply two `GBArray`s `A` and `B` using a semiring, which defaults to the arithmetic semiring `+.*`.

Either operand may be transposed using `'` or `transpose(A)` provided the dimensions match.

The mutating form, `mul!(C, A, B, op; kwargs...)` is identical except it stores the result in `C::GBVecOrMat`.

The operator syntax `A * B` can be used when the default semiring is desired, and `*(max, +)(A, B)` can be used otherwise.

# Arguments
- `A, B::GBArrayOrTranspose`: A GBVector or GBMatrix, possibly transposed.
- `op::Union{Tuple{Function, Function}, AbstractSemiring}`: the semiring used for matrix multiplication. May be passed as a tuple of functions, or an `AbstractSemiring` found in the `Semirings` submodule.
# Keywords
- `mask::Union{Nothing, GBArray} = nothing`: optional mask which determines the output pattern.
- `accum::Union{Nothing, Function} = nothing`: optional binary accumulator
    operation such that `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Union{Nothing, Descriptor}`

# Returns
- `GBArray`: The output matrix whose `eltype` is determined by `A` and `B` or the semiring
    if a type specific semiring is provided.
"""
function Base.:*(
    A::GBArrayOrTranspose,
    B::GBArrayOrTranspose,
    op = (+, *);
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    T = inferbinarytype(parent(A), parent(B), op)
    fill = _promotefill(parent(A), parent(B), op)
    if A isa GBMatrixOrTranspose && B isa AbstractGBVector
        C = similar(A, T, size(A, 1); fill)
    elseif A isa Transpose{<:Any, <:AbstractGBVector} && B isa AbstractGBVector
        C = similar(A, T, 1; fill)
    else
        M = gbpromote_strip(A, B)
        C = M{T}((size(A, 1), size(B, 2)); fill)
    end
    mul!(C, A, B, op; mask, accum, desc)
    return C
end

function Base.:*(
    A::VecMatOrTrans,
    B::GBArrayOrTranspose,
    op = (+, *);
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    return @_densepack A (*(A, B, op; mask, accum, desc))
end

function Base.:*(
    A::GBArrayOrTranspose,
    B::VecMatOrTrans,
    op = (+, *);
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    return @_densepack B (*(A, B, op; mask, accum, desc))
end

# clear up some ambiguities:
function Base.:*(
    A::Transpose{<:T, <:GBVector},
    B::GBVector{T}
) where {T <: Real}
    return *(A, B, (+, *))
end

function Base.:*(
    A::Transpose{<:T, <:DenseVecOrMat},
    B::GBArrayOrTranspose,
    op = (+, *);
    mask = nothing,
    accum = nothing,
    desc = nothing
) where T<:Real
    return @_densepack A (*(A, B, op; mask, accum, desc))
end

function Base.:*(
    A::GBArrayOrTranspose,
    B::Transpose{<:T, <:DenseVecOrMat},
    op = (+, *);
    mask = nothing,
    accum = nothing,
    desc = nothing
) where T<:Real
    return @_densepack B (*(A, B, op; mask, accum, desc))
end

function Base.:*((⊕)::Union{<:Function, Monoid}, (⊗)::Function)
    return function(A::GBArrayOrTranspose, B::GBArrayOrTranspose; mask=nothing, accum=nothing, desc=nothing)
        *(A, B, (⊕, ⊗); mask, accum, desc)
    end
end

function Base.:*((⊕)::Monoid, (⊗)::Function)
    return function(A::GBArrayOrTranspose, B::GBArrayOrTranspose; mask=nothing, accum=nothing, desc=nothing)
        *(A, B, (⊕, ⊗); mask, accum, desc)
    end
end

function Base.:*(rig::TypedSemiring)
    return function(A::GBArrayOrTranspose, B::GBArrayOrTranspose; mask=nothing, accum=nothing, desc=nothing)
        *(A, B, rig; mask, accum, desc)
    end
end

# Diagonal
function LinearAlgebra.mul!(C::GBVecOrMat, D::Diagonal, A::G, op = (+, *); mask = nothing, accum = nothing, desc = nothing) where 
    {G <: Union{Transpose{T, <:SuiteSparseGraphBLAS.AbstractGBArray{T1, F, O}} where {T, T1, F, O}, 
        SuiteSparseGraphBLAS.AbstractGBArray{T, F, O, 2} where {T, F, O}}}
    return mul!(C, G(D), A, op; mask, accum, desc)
end
function LinearAlgebra.mul!(C::GBVecOrMat, A::G, D::Diagonal, op = (+, *); mask = nothing, accum = nothing, desc = nothing) where 
    {G <: Union{Transpose{T, <:SuiteSparseGraphBLAS.AbstractGBArray{T1, F, O}} where {T, T1, F, O}, 
        SuiteSparseGraphBLAS.AbstractGBArray{T, F, O, 2} where {T, F, O}}}
    return mul!(C, A, G(D), op; mask, accum, desc)
end
function Base.:*(D::Diagonal, A::G, op = (+, *); mask = nothing, accum = nothing, desc = nothing) where 
    {G <: Union{Transpose{T, <:SuiteSparseGraphBLAS.AbstractGBArray{T1, F, O}} where {T, T1, F, O}, 
        SuiteSparseGraphBLAS.AbstractGBArray{T, F, O, 2} where {T, F, O}}}
    return *(G(D), A, op; mask, accum, desc)
end
function Base.:*(A::G, D::Diagonal, op = (+, *); mask = nothing, accum = nothing, desc = nothing) where 
    {G <: Union{Transpose{T, <:SuiteSparseGraphBLAS.AbstractGBArray{T1, F, O}} where {T, T1, F, O}, 
        SuiteSparseGraphBLAS.AbstractGBArray{T, F, O, 2} where {T, F, O}}}
    return *(A, G(D), op; mask, accum, desc)
end
