# Constructors:
###############
"""
    GBVector{T}(n = libgb.GxB_INDEX_MAX)
"""
function GBVector{T}(n = libgb.GxB_INDEX_MAX) where {T}
    return GBVector{T}(libgb.GrB_Matrix_new(toGBType(T),n, 1))
end

GBVector{T}(dims::Dims{1}) where {T} = GBVector{T}(dims...)
GBVector{T}(nrows::Base.OneTo) where {T} =
    GBVector{T}(nrows.stop)
GBVector{T}(nrows::Tuple{Base.OneTo,}) where {T} = GBVector{T}(first(nrows))
"""
    GBVector(I::Vector, X::Vector{T})

Create a GBVector from a vector of indices `I` and a vector of values `X`.
"""
function GBVector(I::AbstractVector{U}, X::AbstractVector{T}; dup = BinaryOps.PLUS, nrows = maximum(I)) where {U<:Integer, T}
    x = GBVector{T}(nrows)
    build(x, I, X, dup = dup)
    return x
end

#iso valued constructors.
"""
    GBVector(I, x; nrows = maximum(I))

Create an `n` length GBVector `v` such that `M[I[k]] = x`.
The resulting vector is "iso-valued" such that it only stores `x` once rather than once for
each index.
"""
function GBVector(I::AbstractVector{U}, x::T;
    nrows = maximum(I)) where {U<:Integer, T}
    A = GBVector{T}(nrows)
    build(A, I, x)
    return A
end

"""
    GBVector(n, x)

Create an `n` length dense GBVector `v` such that M[I[k]] = x.
The resulting vector is "iso-valued" such that it only stores `x` once rather than once for
each index.
"""
function GBVector(n::Integer, x::T) where {T}
    v = GBVector{T}(n)
    v[:] = x
    return v
end

# Some Base and basic SparseArrays/LinearAlgebra functions:
###########################################################
Base.unsafe_convert(::Type{libgb.GrB_Matrix}, v::GBVector) = v.p

function Base.copy(v::GBVector{T}) where {T}
    return GBVector{T}(libgb.GrB_Matrix_dup(v))
end


clear!(v::GBVector) = libgb.GrB_Matrix_clear(v)

function Base.size(v::GBVector)
    return (Int64(libgb.GrB_Matrix_nrows(v)),)
end

SparseArrays.nnz(v::GBVector) = Int64(libgb.GrB_Matrix_nvals(v))
Base.eltype(::Type{GBVector{T}}) where{T} = T

function Base.similar(
    ::GBVector{T}, ::Type{TNew},
    dims::Dims{1}
) where {T, TNew}
    return GBVector{TNew}(dims...)
end

function Base.similar(
    ::GBVector{T}, ::Type{TNew},
    dims::Dims{2}
) where {T, TNew}
    return GBMatrix{TNew}(dims...)
end

function Base.deleteat!(v::GBVector, i)
    libgb.GrB_Matrix_removeElement(v, i, 1)
    return v
end

function Base.resize!(v::GBVector, n)
    libgb.GrB_Matrix_resize(v, n, 1)
    return v
end

# TODO: NEEDS REWRITE TO GrB_MATRIX INTERNALS
function LinearAlgebra.diag(A::GBMatrix{T}, k::Integer = 0; desc = C_NULL) where {T}
    return GBVector{T}(libgb.GxB_Vector_diag(A, k, desc))
end

#We need these until I can get a SparseArrays.nonzeros implementation
function Base.show(io::IO, ::MIME"text/plain", v::GBVector)
    gxbprint(io, v)
end

function Base.show(io::IO, v::GBVector)
    gxbprint(io, v)
end

function Base.show(io::IOContext, v::GBVector)
    gxbprint(io, v)
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
        function build(v::GBVector{$T}, I::Vector, X::Vector{$T}; dup = BinaryOps.PLUS)
            nnz(v) == 0 || throw(libgb.OutputNotEmptyError("Cannot build vector with existing elements"))
            length(X) == length(I) || DimensionMismatch("I and X must have the same length")
            libgb.$func(Ptr{libgb.GrB_Vector}(v.p), Vector{libgb.GrB_Index}(I) .- 1, zeros(libgb.GrB_Index, length(I)), X, length(X), dup[$T])
        end
    end
    # Setindex functions
    func = Symbol(prefix, :_Matrix_setElement_, suffix(T))
    @eval begin
        function Base.setindex!(v::GBVector{$T}, x, i::Integer)
            x = convert($T, x)
            return libgb.$func(v, x, libgb.GrB_Index(i) - 1, 0)
        end
    end
    # Getindex functions
    func = Symbol(prefix, :_Matrix_extractElement_, suffix(T))
    @eval begin
        function Base.getindex(v::GBVector{$T}, i::Integer)
            x = Ref{$T}()
            result = libgb.$func(x, v, libgb.GrB_Index(i) - 1, 0)
            if result == libgb.GrB_SUCCESS
                return x[]
            elseif result == libgb.GrB_NO_VALUE
                return nothing
            else
                throw(ErrorException("Invalid extractElement return value."))
            end
        end
    end
    # findnz functions
    func = Symbol(prefix, :_Matrix_extractTuples_, suffix(T))
    @eval begin
        function SparseArrays.findnz(v::GBVector{$T})
            nvals = Ref{libgb.GrB_Index}(nnz(v))
            I = Vector{libgb.GrB_Index}(undef, nvals[])
            X = Vector{$T}(undef, nvals[])
            libgb.$func(I, C_NULL, X, nvals, v)
            nvals[] == length(I) == length(X) || throw(DimensionMismatch("length(I) != length(X)"))
            return I .+ 1, X
        end
        function SparseArrays.nonzeros(v::GBVector{$T})
            nvals = Ref{libgb.GrB_Index}(nnz(v))
            X = Vector{$T}(undef, nvals[])
            libgb.$func(C_NULL, C_NULL, X, nvals, v)
            nvals[] == length(X) || throw(DimensionMismatch(""))
            return X
        end
        function SparseArrays.nonzeroinds(v::GBVector{$T})
            nvals = Ref{libgb.GrB_Index}(nnz(v))
            I = Vector{libgb.GrB_Index}(undef, nvals[])
            libgb.$func(I, C_NULL, C_NULL, nvals, v)
            nvals[] == length(I) || throw(DimensionMismatch(""))
            return I .+ 1
        end
    end
end

function build(v::GBVector{T}, I::Vector, x::T) where {T}
    nnz(v) == 0 || throw(libgb.OutputNotEmptyError("Cannot build vector with existing elements"))
    x = GBScalar(x)
    return libgb.GxB_Matrix_build_Scalar(
            v,
            Vector{libgb.GrB_Index}(I),
            zeros(libgb.GrB_Index, length(I)),
            x,
            length(I)
        )
end

# Indexing functions:
#####################
function _outlength(u, I)
    if I == ALL
        wlen = size(u)
    else
        wlen = length(I)
    end
    return wlen
end

"""
    extract!(w::GBVector, u::GBVector, I; kwargs...)::GBVector

Extract a subvector from `u` into the output vector `w`. Equivalent to the matrix definition.
"""
function extract!(
    w::GBVector, u::GBVector, I;
    mask = C_NULL, accum = nothing, desc = DEFAULTDESC
)
    I, ni = idx(I)
    libgb.GrB_Matrix_extract(w, mask, getaccum(accum, eltype(w)), u, I, ni, UInt64[1], 1, desc)
    return w
end

function extract!(
    w::GBVector, u::GBVector, ::Colon;
    mask = C_NULL, accum = nothing, desc = DEFAULTDESC
)
    return extract!(w, u, ALL; mask, accum, desc)
end

"""
    extract(u::GBVector, I; kwargs...)::GBVector

Extract a subvector from `u` and return it. Equivalent to the matrix definition.
"""
function extract(
    u::GBVector, I;
    mask = C_NULL, accum = nothing, desc = DEFAULTDESC
)
    wlen = _outlength(u, I)
    w = similar(u, wlen)
    return extract!(w, u, I; mask, accum, desc)
end

function extract(u::GBVector, ::Colon; mask = C_NULL, accum = nothing, desc=DEFAULTDESC)
    extract(u, ALL; mask, accum, desc)
end

function Base.getindex(
    u::GBVector, I;
    mask = C_NULL, accum = nothing, desc = DEFAULTDESC
)
    return extract(u, I; mask, accum, desc)
end

function Base.getindex(u::GBVector, ::Colon; mask = C_NULL, accum = nothing, desc = DEFAULTDESC)
    return extract(u, :)
end

function Base.getindex(
    u::GBVector, i::Union{Vector, UnitRange, StepRange};
    mask = C_NULL, accum = nothing, desc = DEFAULTDESC
)
    return extract(u, i; mask, accum, desc)
end
"""
    subassign(w::GBVector, u::GBVector, I; kwargs...)::GBVector

Assign a subvector of `w` to `u`. Return `u`. Equivalent to the matrix definition.
"""
function subassign!(
    w::GBVector, u, I;
    mask = C_NULL, accum = nothing, desc = DEFAULTDESC
)
    I, ni = idx(I)
    u isa Vector && (u = GBVector(u))
    if u isa GBVector
        libgb.GxB_Matrix_subassign(w, mask, getaccum(accum, eltype(w)), u, I, ni, UInt64[1], 1, desc)
    else
        libgb.scalarmatsubassign[eltype(u)](w, mask, getaccum(accum, eltype(w)), u, I, ni, UInt64[1], 1, desc)
    end
    return nothing
end

"""
    assign(w::GBVector, u::GBVector, I; kwargs...)::GBVector

Assign a subvector of `w` to `u`. Return `u`. Equivalent to the matrix definition.
"""
function assign!(
    w::GBVector, u, I;
    mask = C_NULL, accum = nothing, desc = DEFAULTDESC
)
    I, ni = idx(I)
    u isa Vector && (u = GBVector(u))
    if u isa GBVector
        libgb.GrB_Matrix_assign(w, mask, getaccum(accum, eltype(w)), u, I, ni, UInt64[1], 1, desc)
    else
        libgb.scalarmatassign[eltype(u)](w, mask, getaccum(accum, eltype(w)), u, I, ni, UInt64[1], 1, desc)
    end
    return nothing
end

function Base.setindex!(
    u::GBVector, x, ::Colon;
    mask = C_NULL, accum = nothing, desc = DEFAULTDESC
)
    subassign!(u, x, ALL; mask, accum, desc)
    return nothing
end
function Base.setindex!(
    u::GBVector, x, I::Union{Vector, UnitRange, StepRange};
    mask = C_NULL, accum = nothing, desc = DEFAULTDESC
)
    subassign!(u, x, I; mask, accum, desc)
    return nothing
end
