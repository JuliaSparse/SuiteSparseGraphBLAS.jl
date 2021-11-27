# Constructors:
###############
"""
    GBMatrix{T}(nrows = libgb.GxB_INDEX_MAX, ncols = libgb.GxB_INDEX_MAX)

Create a GBMatrix of the specified size, defaulting to the maximum on each dimension, 2^60.
"""
function GBMatrix{T}(nrows = libgb.GxB_INDEX_MAX, ncols = libgb.GxB_INDEX_MAX) where {T}
    GBMatrix{T}(libgb.GrB_Matrix_new(toGBType(T),nrows, ncols))
end

GBMatrix{T}(dims::Dims{2}) where {T} = GBMatrix{T}(dims...)
GBMatrix{T}(size::Tuple{Base.OneTo, Base.OneTo}) where {T} =
    GBMatrix{T}(size[1].stop, size[2].stop)

"""
    GBMatrix(I, J, X; dup = +, nrows = maximum(I), ncols = maximum(J))

Create an nrows x ncols GBMatrix M such that M[I[k], J[k]] = X[k]. The dup function defaults
to `|` for booleans and `+` for nonbooleans.
"""
function GBMatrix(
    I::AbstractVector, J::AbstractVector, X::AbstractVector{T};
    dup = +, nrows = maximum(I), ncols = maximum(J)
) where {T}
    A = GBMatrix{T}(nrows, ncols)
    build(A, I, J, X; dup)
    return A
end

#iso constructors
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


function GBMatrix(dims::Dims{2}, x::T) where {T}
    A = GBMatrix{T}(dims)
    A[:, :] = x
    return A
end

GBMatrix(nrows, ncols, x::T) where {T} = GBMatrix((nrows, ncols), x)

function GBMatrix(v::GBVector)
    A = GBMatrix{eltype(v)}(size(v, 1), size(v, 2))
    nz = findnz(v)
    for i ∈ 1:length(nz[1])
        A[nz[1][i], 1] = nz[2][i]
    end
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
    return A
end

function wait(A::GBArray)
    waitmode = libgb.GrB_MATERIALIZE
    libgb.GrB_Matrix_wait(A, waitmode)
    return nothing
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
clear!(A::GBArray) = libgb.GrB_Matrix_clear(parent(A))

function Base.size(A::GBMatrix)
    return (Int64(libgb.GrB_Matrix_nrows(A)), Int64(libgb.GrB_Matrix_ncols(A)))
end

SparseArrays.nnz(A::GBArray) = Int64(libgb.GrB_Matrix_nvals(parent(A)))
Base.eltype(::Type{GBMatrix{T}}) where{T} = T

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
# This does not conform to the normal definition with a lazy wrapper.
function LinearAlgebra.Diagonal(v::GBVector, k::Integer=0; desc = nothing)
    s = size(v, 1)
    C = GBMatrix{eltype(v)}(s, s)
    desc = _handledescriptor(desc)
    libgb.GxB_Matrix_diag(C, Ptr{libgb.GrB_Vector}(v.p), k, desc)
    return C
end

function LinearAlgebra.diagm(v::GBVector, k::Integer=0; desc = nothing)
    return Diagonal(v, k; desc)
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
        function build(A::GBMatrix{$T}, I::AbstractVector, J::AbstractVector, X::Vector{$T};
                dup = +
            )
            dup = getoperator(BinaryOp(dup), $T)
            if !(I isa Vector)
                I = Vector(I)
            end
            if !(J isa Vector)
                J = Vector(J)
            end
            nnz(A) == 0 || throw(libgb.OutputNotEmptyError("Cannot build matrix with existing elements"))
            length(X) == length(I) == length(J) ||
                DimensionMismatch("I, J and X must have the same length")
            libgb.$func(
                A,
                Vector{libgb.GrB_Index}(I) .- 1,
                Vector{libgb.GrB_Index}(J) .- 1,
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
            return libgb.$func(A, x, libgb.GrB_Index(i) - 1, libgb.GrB_Index(j) - 1)
        end
    end
    # Getindex functions
    func = Symbol(prefix, :_Matrix_extractElement_, suffix(T))
    @eval begin
        function Base.getindex(A::GBMatrix{$T}, i::Int, j::Int)
            x = Ref{$T}()
            result = libgb.$func(x, A, i - 1, j - 1)
            if result == libgb.GrB_SUCCESS
                return x[]
            elseif result == libgb.GrB_NO_VALUE
                return nothing
            else
                throw(ErrorException("Invalid  extractElement return value"))
            end
        end
        # Fix ambiguity
        function Base.getindex(A::Transpose{$T, GBMatrix{$T}}, i::Int, j::Int)
            return getindex(parent(A), j, i)
        end
    end
    # findnz functions
    func = Symbol(prefix, :_Matrix_extractTuples_, suffix(T))
    @eval begin
        function SparseArrays.findnz(A::GBMatrix{$T})
            nvals = Ref{libgb.GrB_Index}(nnz(A))
            I = Vector{libgb.GrB_Index}(undef, nvals[])
            J = Vector{libgb.GrB_Index}(undef, nvals[])
            X = Vector{$T}(undef, nvals[])
            libgb.$func(I, J, X, nvals, A)
            nvals[] == length(I) == length(J) == length(X) || throw(DimensionMismatch("length(I) != length(X)"))
            return I .+ 1, J .+ 1, X
        end
        function SparseArrays.nonzeros(A::GBMatrix{$T})
            nvals = Ref{libgb.GrB_Index}(nnz(A))
            X = Vector{$T}(undef, nvals[])
            libgb.$func(C_NULL, C_NULL, X, nvals, A)
            nvals[] == length(X) || throw(DimensionMismatch(""))
            return X
        end
        function SparseArrays.nonzeroinds(A::GBMatrix{$T})
            nvals = Ref{libgb.GrB_Index}(nnz(A))
            I = Vector{libgb.GrB_Index}(undef, nvals[])
            J = Vector{libgb.GrB_Index}(undef, nvals[])
            wait(A)
            libgb.$func(I, J, C_NULL, nvals, A)
            nvals[] == length(I) == length(J) || throw(DimensionMismatch(""))
            return I .+ 1, J .+ 1
        end
    end
end


function Base.show(io::IO, ::MIME"text/plain", A::GBMatrix)
    gxbprint(io, A)
end

# Indexing functions
####################

function Base.getindex(
    A::GBMatOrTranspose, i, ::Colon;
    mask = nothing, accum = nothing, desc = nothing
)
    return extract(A, i, ALL; mask, accum, desc)
end
function Base.getindex(
    A::GBMatOrTranspose, ::Colon, ::Colon;
    mask = nothing, accum = nothing, desc = nothing
)
    return extract(A, ALL, ALL; mask, accum, desc)
end

function Base.getindex(
    A::GBMatOrTranspose, i::Union{Vector, UnitRange, StepRange, Number}, j::Union{Vector, UnitRange, StepRange, Number};
    mask = nothing, accum = nothing, desc = nothing
)
    return extract(A, i, j; mask, accum, desc)
end

function Base.getindex(A::GBMatOrTranspose, v::AbstractVector)
    throw("Not implemented")
end
"""
    subassign!(C::GBMatrix, A::GBMatrix, I, J; kwargs...)::GBMatrix

Assign a submatrix of `A` to `C`. Equivalent to [`assign!`](@ref) except that
`size(mask) == size(A)`, whereas `size(mask) == size(C)` in `assign!`.

# Arguments
- `C::GBMatrix`: the matrix being subassigned to where `C[I,J] = A`.
- `A::GBMatrix`: the matrix being assigned to a submatrix of `C`.
- `I` and `J`: A colon, scalar, vector, or range indexing C.

# Keywords
- `mask::Union{Nothing, GBMatrix} = nothing`: mask where
    `size(M) == size(A)`.
- `accum::Union{Nothing, Function, AbstractBinaryOp} = nothing`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Union{Nothing, Descriptor} = nothing`

# Returns
- `GBMatrix`: The input matrix A.

# Throws
- `GrB_DIMENSION_MISMATCH`: If `size(A) != (max(I), max(J))` or `size(A) != size(mask)`.
"""
function subassign!(
    C::GBMatrix, A, I, J;
    mask = nothing, accum = nothing, desc = nothing
)
    I, ni = idx(I)
    J, nj = idx(J)
    if A isa GBArray
    elseif A isa AbstractVector
        A = GBVector(A)
    elseif A isa AbstractMatrix
        A = GBMatrix(A)
    end
    mask === nothing && (mask = C_NULL)
    if A isa GBArray
        desc = _handledescriptor(desc; in1 = A)
        libgb.GxB_Matrix_subassign(C, mask, getaccum(accum, eltype(C)), parent(A), I, ni, J, nj, desc)
    else
        desc = _handledescriptor(desc)
        libgb.scalarmatsubassign[eltype(A)](C, mask, getaccum(accum, eltype(C)), A, I, ni, J, nj, desc)
    end
    return A
end

"""
    assign!(C::GBMatrix, A::GBMatrix, I, J; kwargs...)::GBMatrix

Assign a submatrix of `A` to `C`. Equivalent to [`subassign!`](@ref) except that
`size(mask) == size(C)`, whereas `size(mask) == size(A) in `subassign!`.

# Arguments
- `C::GBMatrix`: the matrix being subassigned to where `C[I,J] = A`.
- `A::GBMatrix`: the matrix being assigned to a submatrix of `C`.
- `I` and `J`: A colon, scalar, vector, or range indexing C.

# Keywords
- `mask::Union{Nothing, GBMatrix} = nothing`: mask where
    `size(M) == size(C)`.
- `accum::Union{Nothing, Function, AbstractBinaryOp} = nothing`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Union{Nothing, Descriptor} = nothing`

# Returns
- `GBMatrix`: The input matrix A.

# Throws
- `GrB_DIMENSION_MISMATCH`: If `size(A) != (max(I), max(J))` or `size(C) != size(mask)`.
"""
function assign!(
    C::GBMatrix, A, I, J;
    mask = nothing, accum = nothing, desc = nothing
)
    I, ni = idx(I)
    J, nj = idx(J)
    if A isa GBArray
    elseif A isa AbstractVector
        A = GBVector(A)
    elseif A isa AbstractMatrix
        A = GBMatrix(A)
    end
    mask === nothing && (mask = C_NULL)
    if A isa GBArray
        desc = _handledescriptor(desc; in1 = A)
        libgb.GrB_Matrix_assign(C, mask, getaccum(accum, eltype(C)), parent(A), I, ni, J, nj, desc)
    else
        desc = _handledescriptor(desc)
        libgb.scalarmatassign[eltype(A)](C, mask, getaccum(accum, eltype(C)), A, I, ni, J, nj, desc)
    end
    return A
end

# setindex! uses subassign rather than assign.
function Base.setindex!(
    C::GBMatrix, A, ::Colon, J;
    mask = nothing, accum = nothing, desc = nothing
)
    subassign!(C, A, ALL, J; mask, accum, desc)
end
function Base.setindex!(
    C::GBMatrix, A, I, ::Colon;
    mask = nothing, accum = nothing, desc = nothing
)
    subassign!(C, A, I, ALL; mask, accum, desc)
end
function Base.setindex!(
    C::GBMatrix, A, ::Colon, ::Colon;
    mask = nothing, accum = nothing, desc = nothing
)
    subassign!(C, A, ALL, ALL; mask, accum, desc)
end

function Base.setindex!(
    C::GBMatrix,
    A,
    I::Union{Vector, UnitRange, StepRange, Number},
    J::Union{Vector, UnitRange, StepRange, Number};
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    subassign!(C, A, I, J; mask, accum, desc)
end

function Base.setindex!(
    ::GBMatrix, A, ::AbstractVector;
    mask = nothing, accum = nothing, desc = nothing
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
