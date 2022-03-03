# Constructors:
###############
"""
    GBMatrix{T}(nrows = LibGraphBLAS.GxB_INDEX_MAX, ncols = LibGraphBLAS.GxB_INDEX_MAX)

Create a GBMatrix of the specified size, defaulting to the maximum on each dimension, 2^60.
"""
function GBMatrix{T}(nrows::Integer = LibGraphBLAS.GxB_INDEX_MAX, ncols::Integer = LibGraphBLAS.GxB_INDEX_MAX) where {T}
    m = Ref{LibGraphBLAS.GrB_Matrix}()
    @wraperror LibGraphBLAS.GrB_Matrix_new(m, gbtype(T), nrows, ncols)
    return GBMatrix{T}(m[])
end

GBMatrix{T}(dims::Dims{2}) where {T} = GBMatrix{T}(dims...)
GBMatrix{T}(dims::Tuple{<:Integer}) where {T} = GBMatrix{T}(dims...)
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
    nnz(A) == 0 || throw(OutputNotEmptyError("Cannot build matrix with existing elements"))
    length(I) == length(J) || DimensionMismatch("I, J and X must have the same length")
    x = GBScalar(x)

    @wraperror LibGraphBLAS.GxB_Matrix_build_Scalar(
        A,
        Vector{LibGraphBLAS.GrB_Index}(decrement!(I)),
        Vector{LibGraphBLAS.GrB_Index}(decrement!(J)),
        x,
        length(I)
    )
    increment!(I)
    increment!(J)
    return A
end


# Some Base and basic SparseArrays/LinearAlgebra functions:
###########################################################

Base.unsafe_convert(::Type{LibGraphBLAS.GrB_Matrix}, A::GBMatrix) = A.p

function Base.copy(A::GBMatrix{T}) where {T}
    C = Ref{LibGraphBLAS.GrB_Matrix}()
    LibGraphBLAS.GrB_Matrix_dup(C, A)
    return GBMatrix{T}(C[])
end

"""
    clear!(v::GBVector)
    clear!(A::GBMatrix)

Clear all the entries from the GBArray.
Does not modify the type or dimensions.
"""
clear!(A::GBArray) = @wraperror LibGraphBLAS.GrB_Matrix_clear(parent(A)); return nothing

function Base.size(A::GBMatrix)
    nrows = Ref{LibGraphBLAS.GrB_Index}()
    ncols = Ref{LibGraphBLAS.GrB_Index}()
    @wraperror LibGraphBLAS.GrB_Matrix_nrows(nrows, A)
    @wraperror LibGraphBLAS.GrB_Matrix_ncols(ncols, A)
    return (Int64(nrows[]), Int64(ncols[]))
end

function SparseArrays.nnz(A::GBArray)
    nvals = Ref{LibGraphBLAS.GrB_Index}()
    @wraperror LibGraphBLAS.GrB_Matrix_nvals(nvals, parent(A))
    return Int64(nvals[])
end

Base.eltype(::Type{GBMatrix{T}}) where{T} = T

function Base.similar(
    ::GBMatrix{T}, ::Type{TNew},
    dims::Union{Dims{1}, Dims{2}}
) where {T, TNew}
    return GBMatrix{TNew}(dims...)
end

function Base.deleteat!(A::GBMatrix, i, j)
    @wraperror LibGraphBLAS.GrB_Matrix_removeElement(A, decrement!(i), decrement!(j))
    return A
end

function Base.resize!(A::GBMatrix, nrows_new, ncols_new)
    @wraperror LibGraphBLAS.GrB_Matrix_resize(A, nrows_new, ncols_new)
    return A
end
# This does not conform to the normal definition with a lazy wrapper.
function LinearAlgebra.Diagonal(v::GBVector, k::Integer=0; desc = nothing)
    s = size(v, 1)
    C = GBMatrix{eltype(v)}(s, s)
    desc = _handledescriptor(desc)
    # Switch ptr to a Vector to trick GraphBLAS.
    # This is allowed since GrB_Vector is a GrB_Matrix internally.
    @wraperror LibGraphBLAS.GxB_Matrix_diag(C, Ptr{LibGraphBLAS.GrB_Vector}(v.p), k, desc)
    return C
end

# TODO: FIXME
# function LinearAlgebra.diagm(v::GBVector, k::Integer=0; desc = nothing)
#     return Diagonal(v, k; desc)
# end

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
            dup = BinaryOp(dup)($T)
            if !(I isa Vector)
                I = Vector(I)
            end
            if !(J isa Vector)
                J = Vector(J)
            end
            nnz(A) == 0 || throw(OutputNotEmptyError("Cannot build matrix with existing elements"))
            length(X) == length(I) == length(J) ||
                DimensionMismatch("I, J and X must have the same length")
            decrement!(I)
            decrement!(J)
            @wraperror LibGraphBLAS.$func(
                A,
                Vector{LibGraphBLAS.GrB_Index}(I),
                Vector{LibGraphBLAS.GrB_Index}(J),
                X,
                length(X),
                dup
            )
            increment!(I)
            increment!(J)
        end
    end
    # Setindex functions
    func = Symbol(prefix, :_Matrix_setElement_, suffix(T))
    @eval begin
        function Base.setindex!(A::GBMatrix{$T}, x, i::Integer, j::Integer)
            x = convert($T, x)
            @wraperror LibGraphBLAS.$func(A, x, LibGraphBLAS.GrB_Index(decrement!(i)), LibGraphBLAS.GrB_Index(decrement!(j)))
            return x
        end
    end
    # Getindex functions
    func = Symbol(prefix, :_Matrix_extractElement_, suffix(T))
    @eval begin
        function Base.getindex(A::GBMatrix{$T}, i::Int, j::Int)
            x = Ref{$T}()
            result = LibGraphBLAS.$func(x, A, decrement!(i), decrement!(j))
            if result == LibGraphBLAS.GrB_SUCCESS
                return x[]
            elseif result == LibGraphBLAS.GrB_NO_VALUE
                return nothing
            else
                @wraperror result
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
            nvals = Ref{LibGraphBLAS.GrB_Index}(nnz(A))
            I = Vector{LibGraphBLAS.GrB_Index}(undef, nvals[])
            J = Vector{LibGraphBLAS.GrB_Index}(undef, nvals[])
            X = Vector{$T}(undef, nvals[])
            @wraperror LibGraphBLAS.$func(I, J, X, nvals, A)
            nvals[] == length(I) == length(J) == length(X) || throw(DimensionMismatch("length(I) != length(X)"))
            return increment!(I), increment!(J), X
        end
        function SparseArrays.nonzeros(A::GBMatrix{$T})
            nvals = Ref{LibGraphBLAS.GrB_Index}(nnz(A))
            X = Vector{$T}(undef, nvals[])
            @wraperror LibGraphBLAS.$func(C_NULL, C_NULL, X, nvals, A)
            nvals[] == length(X) || throw(DimensionMismatch(""))
            return X
        end
        function SparseArrays.nonzeroinds(A::GBMatrix{$T})
            nvals = Ref{LibGraphBLAS.GrB_Index}(nnz(A))
            I = Vector{LibGraphBLAS.GrB_Index}(undef, nvals[])
            J = Vector{LibGraphBLAS.GrB_Index}(undef, nvals[])
            wait(A)
            @wraperror LibGraphBLAS.$func(I, J, C_NULL, nvals, A)
            nvals[] == length(I) == length(J) || throw(DimensionMismatch(""))
            return increment!(I), increment!(J)
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

for T ∈ valid_vec
    func = Symbol(:GxB_Matrix_subassign_, suffix(T))
    @eval begin
        function _subassign(C::GBMatrix{$T}, x, I, ni, J, nj, mask, accum, desc)
            @wraperror LibGraphBLAS.$func(C, mask, accum, x, I, ni, J, nj, desc)
            return x
        end
    end
    if T ∈ gxb_vec
        prefix = :GxB
    else
        prefix = :GrB
    end
    func = Symbol(prefix, :_Matrix_assign_, suffix(T))
    @eval begin
        function _assign(C::GBMatrix{$T}, x, I, ni, J, nj, mask, accum, desc)
            @wraperror LibGraphBLAS.$func(C, mask, accum, x, I, ni, J, nj, desc)
            return x
        end
    end
end
function subassign!(
    C::GBMatrix, A, I, J;
    mask = nothing, accum = nothing, desc = nothing
)
    A1 = A
    I, ni = idx(I)
    J, nj = idx(J)
    if A isa GBArray
    elseif A isa AbstractVector
        A = GBVector(A)
    elseif A isa AbstractMatrix
        A = GBMatrix(A)
    end
    mask === nothing && (mask = C_NULL)
    I = decrement!(I)
    J = decrement!(J)
    if A isa GBArray
        desc = _handledescriptor(desc; in1 = A)
        @wraperror LibGraphBLAS.GxB_Matrix_subassign(C, mask, getaccum(accum, eltype(C)), parent(A), I, ni, J, nj, desc)
    else
        desc = _handledescriptor(desc)
        _subassign(C, A, I, ni, J, nj, mask, getaccum(accum, eltype(C)), desc)
    end
    increment!(I)
    increment!(J)
    return A1
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
    I = decrement!(I)
    J = decrement!(J)
    mask === nothing && (mask = C_NULL)
    if A isa GBArray
        desc = _handledescriptor(desc; in1 = A)
        @wraperror LibGraphBLAS.GrB_Matrix_assign(C, mask, getaccum(accum, eltype(C)), parent(A), I, ni, J, nj, desc)
    else
        desc = _handledescriptor(desc)
        _assign(C, A, I, ni, J, nj, mask, getaccum(accum, eltype(C)), desc)
    end
    increment!(I)
    increment!(J)
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
