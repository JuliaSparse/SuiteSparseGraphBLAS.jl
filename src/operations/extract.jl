"""
    _outlength(A, I, J)
    _outlength(u, I)
Determine the size of the output for an operation like extract or range-based indexing.
"""
function _outlength(A, I, J)
    I isa Colon && (I = ALL)
    J isa Colon && (J = ALL)
    if I == ALL
        Ilen = size(A, 1)
    else
        Ilen = length(I)
    end
    if J == ALL
        Jlen = size(A, 2)
    else
        Jlen = length(J)
    end
    return Ilen, Jlen
end

function _outlength(u, I)
    I isa Colon && (I = ALL)
    if I == ALL
        wlen = size(u)
    else
        wlen = length(I)
    end
    return wlen
end

"""
    extract!(C::GBMatrix, A::GBMatrixOrTranspose, I, J; kwargs...)::GBMatrix
    extract!(C::GBVector, A::GBVector, I; kwargs...)::GBVector

Extract a submatrix or subvector from `A` into `C`.

# Arguments
- `C::Union{GBVector, GBMatrix}`: the submatrix or subvector extracted from `A`.
- `A::GBArray`
- `I` and `J`: A colon, scalar, vector, or range indexing A.

# Keywords
- `mask::Union{Nothing, GBArray} = nothing`: mask where
    `size(M) == (max(I), max(J))`.
- `accum::Union{Nothing} = nothing`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Union{Nothing, Descriptor} = nothing`

# Returns
- `GBMatrix` or `GBVector`: the modified array `C`, now containing the matrix `A[I, J]` or
    `A[I]` for a vector.

# Throws
- `GrB_DIMENSION_MISMATCH`: If `size(C) != (max(I), max(J))` or `size(C) != size(mask)`.
"""
extract!

function extract!(
    C::AbstractGBArray, A::GBMatrixOrTranspose, I, J;
    mask = nothing, accum = nothing, desc = nothing
)
    I, ni = idx(I)
    J, nj = idx(J)
    I isa Number && (I = UInt64[I])
    J isa Number && (J = UInt64[J])
    mask === nothing && (mask = C_NULL)
    desc = _handledescriptor(desc; in1 = A)
    I = decrement!(I)
    J = decrement!(J)
    @wraperror LibGraphBLAS.GrB_Matrix_extract(gbpointer(C), mask, getaccum(accum, eltype(C)), gbpointer(parent(A)), I, ni, J, nj, desc)
    I isa Vector && increment!(I)
    J isa Vector && increment!(J)
    return C
end
"""
    extract(A::GBMatrixOrTranspose, I, J; kwargs...)::GBMatrix
    extract(A::GBVector, I; kwargs...)::GBVector

Extract a submatrix or subvector from `A`

# Arguments
- `A::GBArray`: the array being indexed.
- `I` and `J`: A colon, scalar, vector, or range indexing A.

# Keywords
- `mask::Union{Nothing, GBArray} = nothing`: mask where
    `size(M) == (max(I), max(J))`.
- `accum::Union{Nothing} = nothing`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Descriptor = nothing`

# Returns
- `GBMatrix`: the submatrix `A[I, J]`.

# Throws
- `GrB_DIMENSION_MISMATCH`: If `(max(I), max(J)) != size(mask)`.
"""
extract

function extract(
    A::GBMatrixOrTranspose, I, J;
    mask = nothing, accum = nothing, desc = nothing
)
    Ilen, Jlen = _outlength(A, I, J)
    C = similar(A, Ilen, Jlen)
    return extract!(C, A, I, J; mask, accum, desc)
end

function extract(
    A::GBMatrixOrTranspose, ::Colon, J::Number;
    mask = nothing, accum = nothing, desc = nothing
)
    Ilen, _ = _outlength(A, :, J)
    C = similar(A, Ilen)
    return extract!(C, A, :, J; mask, accum, desc)
end

# TODO: FINISH THIS WITH GxB_Matrix_reshape!!!
# function extract(
#     A::GBMatrixOrTranspose, I::Number, ::Colon;
#     mask = nothing, accum = nothing, desc = nothing
# )
#     _, Jlen = _outlength(A, I, :)
#     C = similar(A, 1, Jlen)
#     return extract!(C, A, I, :; mask, accum, desc)
# end

function extract!(
    w::AbstractGBVector, u::AbstractGBVector, I;
    mask = nothing, accum = nothing, desc = nothing
)
    I, ni = idx(I)
    I = decrement!(I)
    desc = _handledescriptor(desc)
    mask === nothing && (mask = C_NULL)
    @wraperror LibGraphBLAS.GrB_Matrix_extract(gbpointer(w), mask, getaccum(accum, eltype(w)), gbpointer(u), I, ni, UInt64[0], 1, desc)
    I isa Vector && increment!(I)
    return w
end

function extract(
    u::GBVector, I;
    mask = nothing, accum = nothing, desc = nothing
)
    wlen = _outlength(u, I)
    w = similar(u, wlen)
    return extract!(w, u, I; mask, accum, desc)
end