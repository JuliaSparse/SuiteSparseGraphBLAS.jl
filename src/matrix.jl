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
    I::Vector, J::Vector, X::Vector{T};
    dup = BinaryOps.PLUS, nrows = maximum(I), ncols = maximum(J)
) where {T}
    A = GBMatrix{T}(nrows, ncols)
    build(A, I, J, X; dup)
    return A
end

"""
    GBMatrix(A::SparseMatrixCSC)

Create a GBMatrix from SparseArrays sparse matrix `A`.
"""
#function GBMatrix(A::SparseMatrixCSC) # TEMPORARY: NEEDS IMPORT/EXPORT
#    i, j, k = findnz(A)
#    return GBMatrix(i, j, k)
#end


# Some Base and basic SparseArrays/LinearAlgebra functions:
###########################################################

Base.unsafe_convert(::Type{libgb.GrB_Matrix}, A::GBMatrix) = A.p

function Base.copy(A::GBMatrix{T}) where {T}
    return GBMatrix{T}(libgb.GrB_Matrix_dup(A))
end

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
            nnz(A) == 0 || error("Cannot build matrix with existing elements")
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
        function Base.setindex!(A::GBMatrix{$T}, x::$T, i, j)
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

# Indexing functions
####################
"""
    _outlength(A, I, J)

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

function extract!(
    C::GBMatrix, A::GBMatrix, I, J;
    mask = C_NULL, accum = C_NULL, desc = Descriptors.NULL
)
    I, ni = idx(I)
    J, nj = idx(J)
    libgb.GrB_Matrix_extract(C, mask, accum, A, I, ni, J, nj, desc)
    return C
end

function extract(
    A::GBMatrix, I, J;
    mask = C_NULL, accum = C_NULL, desc = Descriptors.NULL
)
    Ilen, Jlen = wlength(A, I, J)
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
    A, i::Union{Vector, UnitRange, StepRange}, j::Union{Vector, UnitRange, StepRange};
    mask = C_NULL, accum = C_NULL, desc = Descriptors.NULL
)
    return extract(A, i, j; mask, accum, desc)
end

function subassign!(
    C::GBMatrix, A, I, J;
    mask = C_NULL, accum = C_NULL, desc = Descriptors.NULL
)
    I, ni = idx(I)
    J, nj = idx(J)
    A isa Vector && (A = GBVector(A))
    if A isa GBVector
        if !(I isa Vector) && (J isa Vector)
            libgb.GxB_Row_subassign(C, mask, accum, A, I, J, nj, desc)
        elseif !(J isa Vector) && (I isa Vector)
            libgb.GxB_Col_subassign(C, mask, accum, A, I, ni, J, desc)
        else
            throw(MethodError(subassign!, [C, A, I, J]))
        end
    elseif A isa GBMatrix
        libgb.GxB_Matrix_subassign(C, mask, accum, A, I, ni, J, nj, desc)
    else
        libgb.scalarmatsubassign[eltype(A)](C, mask, accum, A, I, ni, J, nj, desc)
    end
end

function assign!(
    C::GBMatrix, A, I, J;
    mask = C_NULL, accum = C_NULL, desc = Descriptors.NULL
)
    I, ni = idx(I)
    J, nj = idx(J)
    A isa Vector && (A = GBVector(A))
    if A isa GBVector
        if !(I isa Vector) && (J isa Vector)
            libgb.GrB_Row_assign(C, mask, accum, A, I, J, nj, desc)
        elseif !(J isa Vector) && (I isa Vector)
            libgb.GrB_Col_assign(C, mask, accum, A, I, ni, J, desc)
        else
            throw(MethodError(subassign!, [C, A, I, J]))
        end
    elseif A isa GBMatrix
        libgb.GrB_Matrix_assign(C, mask, accum, A, I, ni, J, nj, desc)
    else
        libgb.scalarmatassign[eltype(A)](C, mask, accum, A, I, ni, J, nj, desc)
    end
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
    I::Union{Vector, UnitRange, StepRange},
    J::Union{Vector, UnitRange, StepRange};
    mask = C_NULL,
    accum = C_NULL,
    desc = Descriptors.NULL
)
    subassign!(C, A, I, J; mask, accum, desc)
end
