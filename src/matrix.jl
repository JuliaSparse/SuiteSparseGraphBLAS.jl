# Constructors:
###############
"""
    GBMatrix{T}(nrows = libgb.GxB_INDEX_MAX, ncols = libgb.GxB_INDEX_MAX)

Create a GBMatrix with the max size.
"""
function GBMatrix{T}(nrows = libgb.GxB_INDEX_MAX, ncols = libgb.GxB_INDEX_MAX) where {T}
    GBMatrix{T}(libgb.GrB_Matrix_new(toGBType(T),nrows, ncols))
end

GBMatrix{T}(dims::Dims{2}) where {T} = GBMatrix{T}(dims...)

"""
    GBMatrix(I, J, X; dup = BinaryOps.PLUS, nrows = maximum(I), ncols = maximum(J))

Create an nrows x ncols GBMatrix M such that M[I[k], J[k]] = X[k]. The dup function defaults
to `|` for booleans and `+` for nonbooleans.
"""
function GBMatrix(
    I::AbstractVector, J::AbstractVector, X::AbstractVector{T};
    dup = BinaryOps.PLUS, nrows = maximum(I), ncols = maximum(J)
) where {T}
    A = GBMatrix{T}(nrows, ncols)
    build(A, I, J, X; dup)
    return A
end

"""
    GBMatrix(I, J, x; nrows = maximum(I), ncols = maximum(J))

Create an nrows x ncols GBMatrix M such that M[I[k], J[k]] = x.
The resulting matrix is "iso-valued" such that it only stores `x` once rather than once for
each index.
"""
function GBMatrix(I::AbstractVector, J::AbstractVector, x::T;
    nrows = maximum(I), ncols = maximum(J)) where {T}
    A = GBMatrix{T}(nrows, ncols)
    build(A, I, J, x)
    return A
end

function build(A::GBMatrix{T}, I::AbstractVector, J::AbstractVector, x::T) where {T}
nnz(A) == 0 || throw(libgb.OutputNotEmptyError("Cannot build matrix with existing elements"))
length(I) == length(J) || DimensionMismatch("I, J and X must have the same length")
x = GBScalar(x)

libgb.GxB_Matrix_build_Scalar(
    A,
    Vector{libgb.GrB_Index}(I),
    Vector{libgb.GrB_Index}(J),
    x,
    length(I)
)
end
# Some Base and basic SparseArrays/LinearAlgebra functions:
###########################################################

Base.unsafe_convert(::Type{libgb.GrB_Matrix}, A::GBMatrix) = A.p

function Base.copy(A::GBMatrix{T}) where {T}
    return GBMatrix{T}(libgb.GrB_Matrix_dup(A))
end

"""
    clear!(v::GBVector)
    clear!(A::GBMatrix)

Clear all the entries from the GBArray.
Does not modify the type or dimensions.
"""
clear!(A::GBMatrix) = libgb.GrB_Matrix_clear(A)

function Base.size(A::GBMatrix)
    return (Int64(libgb.GrB_Matrix_nrows(A)), Int64(libgb.GrB_Matrix_ncols(A)))
end

SparseArrays.nnz(v::GBMatrix) = Int64(libgb.GrB_Matrix_nvals(v))
Base.eltype(::Type{GBMatrix{T}}) where{T} = T

function Base.similar(A::GBMatrix{T}, ::Type{TNew}) where {T, TNew}
    return GBMatrix{TNew}(size(A, 1), size(A, 2))
end
function Base.similar(
    ::GBMatrix{T}, ::Type{TNew},
    dims::Union{Dims{1}, Dims{2}}
) where {T, TNew}
    return GBMatrix{TNew}(dims...)
end

function Base.deleteat!(A::GBMatrix, i, j)
    libgb.GrB_Matrix_removeElement(A, i, j)
    return A
end

function Base.resize!(A::GBMatrix, nrows_new, ncols_new)
    libgb.GrB_Matrix_resize(A, nrows_new, ncols_new)
    return A
end

function LinearAlgebra.Diagonal(v::GBVector, k::Integer; desc = Descriptors.NULL)
    return libgb.GxB_Matrix_diag(v, k, desc)
end

# Type dependent functions build, setindex, getindex, and findnz:
for T ∈ valid_vec
    if T ∈ gxb_vec
        prefix = :GxB
    else
        prefix = :GrB
    end
    # Build functions
    func = Symbol(prefix, :_Matrix_build_, suffix(T))
    @eval begin
        function build(A::GBMatrix{$T}, I::Vector, J::Vector, X::Vector{$T};
                dup = BinaryOps.PLUS
            )
            dup = getoperator(dup, $T)
            nnz(A) == 0 || throw(libgb.OutputNotEmptyError("Cannot build matrix with existing elements"))
            length(X) == length(I) == length(J) ||
                DimensionMismatch("I, J and X must have the same length")
            libgb.$func(
                A,
                Vector{libgb.GrB_Index}(I),
                Vector{libgb.GrB_Index}(J),
                X,
                length(X),
                dup
            )
        end
    end
    # Setindex functions
    func = Symbol(prefix, :_Matrix_setElement_, suffix(T))
    @eval begin
        function Base.setindex!(A::GBMatrix{$T}, x, i::Integer, j::Integer)
            x = convert($T, x)
            return libgb.$func(A, x, libgb.GrB_Index(i), libgb.GrB_Index(j))
        end
    end
    # Getindex functions
    func = Symbol(prefix, :_Matrix_extractElement_, suffix(T))
    @eval begin
        function Base.getindex(A::GBMatrix{$T}, i::Integer, j::Integer)
            return libgb.$func(A, libgb.GrB_Index(i), libgb.GrB_Index(j))
        end
    end
    # findnz functions
    func = Symbol(prefix, :_Matrix_extractTuples_, suffix(T))
    @eval begin
        function SparseArrays.findnz(A::GBMatrix{$T})
            return libgb.$func(A)
        end
    end
end


function Base.show(io::IO, ::MIME"text/plain", A::GBMatrix)
    gxbprint(io, A)
end

SparseArrays.nonzeros(A::GBArray) = findnz(A)[end]


# Indexing functions
####################
"""
    _outlength(A, I, J)
    _outlength(u, I)
Determine the size of the output for an operation like extract or range-based indexing.
"""
function _outlength(A, I, J)
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
"""
    extract!(C::GBMatrix, A::GBMatrix, I, J; kwargs...)::GBMatrix

Extract a submatrix from `A` into `C`.

# Arguments
- `C::GBMatrix`: the submatrix extracted from `A`. It is a dimension mismatch if
    `size(C) != (max(I), max(J))`.
- `A::GBMatrix`: the array being indexed.
- `I` and `J`: A colon, scalar, vector, or range indexing A.

# Keywords
- `mask::Union{Ptr{Nothing}, GBMatrix} = C_NULL`: mask where
    `size(M) == (max(I), max(J))`.
- `accum::Union{Ptr{Nothing}, AbstractBinaryOp} = C_NULL`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Descriptor = Descriptors.NULL`

# Returns
- `GBMatrix`: the modified matrix `C`, now containing the submatrix `A[I, J]`.

# Throws
- `GrB_DIMENSION_MISMATCH`: If `size(C) != (max(I), max(J))` or `size(C) != size(mask)`.
"""
function extract!(
    C::GBMatrix, A::GBMatrix, I, J;
    mask = C_NULL, accum = C_NULL, desc = Descriptors.NULL
)
    I, ni = idx(I)
    J, nj = idx(J)
    I isa Number && (I = UInt64[I])
    J isa Number && (J = UInt64[J])
    libgb.GrB_Matrix_extract(C, mask, getoperator(accum, eltype(C)), A, I, ni, J, nj, desc)
    return C
end

"""
    extract(A::GBMatrix, I, J; kwargs...)::GBMatrix

Extract a submatrix from `A`.

# Arguments
- `A::GBMatrix`: the array being indexed.
- `I` and `J`: A colon, scalar, vector, or range indexing A.

# Keywords
- `mask::Union{Ptr{Nothing}, GBMatrix} = C_NULL`: mask where
    `size(M) == (max(I), max(J))`.
- `accum::Union{Ptr{Nothing}, AbstractBinaryOp} = C_NULL`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied. `C` is, however, empty.
- `desc::Descriptor = Descriptors.NULL`

# Returns
- `GBMatrix`: the submatrix `A[I, J]`.

# Throws
- `GrB_DIMENSION_MISMATCH`: If `(max(I), max(J)) != size(mask)`.
"""
function extract(
    A::GBMatrix, I, J;
    mask = C_NULL, accum = C_NULL, desc = Descriptors.NULL
)
    Ilen, Jlen = _outlength(A, I, J)
    C = similar(A, Ilen, Jlen)
    return extract!(C, A, I, J; mask, accum, desc)
end

function Base.getindex(
    A::GBMatrix, ::Colon, j;
    mask = C_NULL, accum = C_NULL, desc = Descriptors.NULL
)
    return extract(A, ALL, j; mask, accum, desc)
end
function Base.getindex(
    A::GBMatrix, i, ::Colon;
    mask = C_NULL, accum = C_NULL, desc = Descriptors.NULL
)
    return extract(A, i, ALL; mask, accum, desc)
end
function Base.getindex(
    A::GBMatrix, ::Colon, ::Colon;
    mask = C_NULL, accum = C_NULL, desc = Descriptors.NULL
)
    return extract(A, ALL, ALL; mask, accum, desc)
end

function Base.getindex(
    A::GBMatrix, i::Union{Vector, UnitRange, StepRange, Number}, j::Union{Vector, UnitRange, StepRange, Number};
    mask = C_NULL, accum = C_NULL, desc = Descriptors.NULL
)
    return extract(A, i, j; mask, accum, desc)
end

function Base.getindex(A::GBMatrix, v::AbstractVector)
    throw("Not implemented")
end
"""
    subassign!(C::GBMatrix, A::GBMatrix, I, J; kwargs...)::GBMatrix

Assign a submatrix of `C` to `A`. Equivalent to [`assign!`](@ref) except that
`size(mask) == size(A)`, whereas `size(mask) == size(C)` in `assign!`.

# Arguments
- `C::GBMatrix`: the matrix being subassigned to where `C[I,J] = A`.
- `A::GBMatrix`: the matrix being assigned to a submatrix of `C`.
- `I` and `J`: A colon, scalar, vector, or range indexing C.

# Keywords
- `mask::Union{Ptr{Nothing}, GBMatrix} = C_NULL`: mask where
    `size(M) == size(A)`.
- `accum::Union{Ptr{Nothing}, AbstractBinaryOp} = C_NULL`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Descriptor = Descriptors.NULL`

# Returns
- `GBMatrix`: The input matrix A.

# Throws
- `GrB_DIMENSION_MISMATCH`: If `size(A) != (max(I), max(J))` or `size(A) != size(mask)`.
"""
function subassign!(
    C::GBMatrix, A, I, J;
    mask = C_NULL, accum = C_NULL, desc = Descriptors.NULL
)
    I, ni = idx(I)
    J, nj = idx(J)
    if A isa GBArray
    elseif A isa AbstractVector
        A = GBVector(A)
    elseif A isa AbstractMatrix
        A = GBMatrix(A)
    end
    if A isa GBVector
        if (I isa Number) && (J isa Vector || J == ALL)
            libgb.GxB_Row_subassign(C, mask, getoperator(accum, eltype(C)), A, I, J, nj, desc)
        elseif (J isa Number) && (I isa Vector || I == ALL)
            libgb.GxB_Col_subassign(C, mask, getoperator(accum, eltype(C)), A, I, ni, J, desc)
        else
            throw(MethodError(subassign!, [C, A, I, J]))
        end
    elseif A isa GBMatrix
        libgb.GxB_Matrix_subassign(C, mask, getoperator(accum, eltype(C)), A, I, ni, J, nj, desc)
    else
        libgb.scalarmatsubassign[eltype(A)](C, mask, getoperator(accum, eltype(C)), A, I, ni, J, nj, desc)
    end
    return A # Not sure this is correct, but it's what Base seems to do.
end

"""
    assign!(C::GBMatrix, A::GBMatrix, I, J; kwargs...)::GBMatrix

Assign a submatrix of `C` to `A`. Equivalent to [`subassign!`](@ref) except that
`size(mask) == size(C)`, whereas `size(mask) == size(A) in `subassign!`.

# Arguments
- `C::GBMatrix`: the matrix being subassigned to where `C[I,J] = A`.
- `A::GBMatrix`: the matrix being assigned to a submatrix of `C`.
- `I` and `J`: A colon, scalar, vector, or range indexing C.

# Keywords
- `mask::Union{Ptr{Nothing}, GBMatrix} = C_NULL`: mask where
    `size(M) == size(C)`.
- `accum::Union{Ptr{Nothing}, AbstractBinaryOp} = C_NULL`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Descriptor = Descriptors.NULL`

# Returns
- `GBMatrix`: The input matrix A.

# Throws
- `GrB_DIMENSION_MISMATCH`: If `size(A) != (max(I), max(J))` or `size(C) != size(mask)`.
"""
function assign!(
    C::GBMatrix, A, I, J;
    mask = C_NULL, accum = C_NULL, desc = Descriptors.NULL
)
    I, ni = idx(I)
    J, nj = idx(J)
    if A isa GBArray
    elseif A isa AbstractVector
        A = GBVector(A)
    elseif A isa AbstractMatrix
        A = GBMatrix(A)
    end
    if A isa GBVector
        if (I isa Number) && (J isa Vector || J == ALL)
            libgb.GrB_Row_assign(C, mask, getoperator(accum, eltype(C)), A, I, J, nj, desc)
        elseif (J isa Number) && (I isa Vector || I == ALL)
            libgb.GrB_Col_assign(C, mask, getoperator(accum, eltype(C)), A, I, ni, J, desc)
        else
            throw(MethodError(subassign!, [C, A, I, J]))
        end
    elseif A isa GBMatrix
        libgb.GrB_Matrix_assign(C, mask, getoperator(accum, eltype(C)), A, I, ni, J, nj, desc)
    else
        libgb.scalarmatassign[eltype(A)](C, mask, getoperator(accum, eltype(C)), A, I, ni, J, nj, desc)
    end
    return A # Not sure this is correct, but it's what Base seems to do.
end

# setindex! uses subassign rather than assign. This behavior may change in the future.
function Base.setindex!(
    C::GBMatrix, A, ::Colon, J;
    mask = C_NULL, accum = C_NULL, desc = Descriptors.NULL
)
    subassign!(C, A, ALL, J; mask, accum, desc)
end
function Base.setindex!(
    C::GBMatrix, A, I, ::Colon;
    mask = C_NULL, accum = C_NULL, desc = Descriptors.NULL
)
    subassign!(C, A, I, ALL; mask, accum, desc)
end
function Base.setindex!(
    C::GBMatrix, A, ::Colon, ::Colon;
    mask = C_NULL, accum = C_NULL, desc = Descriptors.NULL
)
    subassign!(C, A, ALL, ALL; mask, accum, desc)
end

function Base.setindex!(
    C::GBMatrix,
    A,
    I::Union{Vector, UnitRange, StepRange, Number},
    J::Union{Vector, UnitRange, StepRange, Number};
    mask = C_NULL,
    accum = C_NULL,
    desc = Descriptors.NULL
)
    subassign!(C, A, I, J; mask, accum, desc)
end

function Base.setindex(
    C::GBMatrix, A, I::AbstractVector;
    mask = C_NULL, accum = C_NULL, desc = Descriptors.NULL
)
    throw("Not implemented")
end

#Printing fixes:
function Base.isstored(A::GBArray, i::Integer, j::Integer)
    @boundscheck checkbounds(A, i, j)
    if A[i, j] === nothing
        return false
    else
        return true
    end
end

#Help wanted: This isn't really centered for a lot of eltypes.
function Base.replace_in_print_matrix(A::GBArray, i::Integer, j::Integer, s::AbstractString)
    Base.isstored(A, i, j) ? s : Base.replace_with_centered_mark(s)
end
