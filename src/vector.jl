# Constructors:
###############
"""
    GBVector{T}(n = libgb.GxB_INDEX_MAX)
"""
function GBVector{T}(n = libgb.GxB_INDEX_MAX) where {T}
    return GBVector{T}(libgb.GrB_Vector_new(toGBType(T),n))
end

GBVector{T}(dims::Dims{1}) where {T} = GBVector{T}(dims...)

"""
    GBVector(I::Vector, X::Vector{T})

Create a GBVector from a vector of indices `I` and a vector of values `X`.
"""
function GBVector(I::Vector, X::Vector{T}; dup = BinaryOps.PLUS) where {T}
    x = GBVector{T}(maximum(I))
    build(x, I, X, dup = dup)
    return x
end

# Some Base and basic SparseArrays/LinearAlgebra functions:
###########################################################
Base.unsafe_convert(::Type{libgb.GrB_Vector}, v::GBVector) = v.p

function Base.copy(v::GBVector{T}) where {T}
    return GBVector{T}(libgb.GrB_Vector_dup(v))
end


clear!(v::GBVector) = libgb.GrB_Vector_clear(v)

function Base.size(v::GBVector)
    return (Int64(libgb.GrB_Vector_size(v)),)
end

SparseArrays.nnz(v::GBVector) = Int64(libgb.GrB_Vector_nvals(v))
Base.eltype(::Type{GBVector{T}}) where{T} = T

function Base.similar(v::GBVector{T}, ::Type{TNew}) where {T, TNew}
    return GBVector{TNew}(size(v, 1))
end
function Base.similar(
    ::GBVector{T}, ::Type{TNew},
    dims::Dims{1}
) where {T, TNew}
    return GBVector{TNew}(dims...)
end

function Base.deleteat!(v::GBVector, i)
    libgb.GrB_Vector_removeElement(v, libgb.GrB_Index(i))
    return v
end

function Base.resize!(v::GBVector, n)
    libgb.GrB_Vector_resize(v, n)
    return v
end

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
    func = Symbol(prefix, :_Vector_build_, suffix(T))
    @eval begin
        function build(v::GBVector{$T}, I::Vector, X::Vector{$T}; dup = BinaryOps.PLUS)
            nnz(v) == 0 || error("Cannot build vector with existing elements")
            length(X) == length(I) || DimensionMismatch("I and X must have the same length")
            libgb.$func(v, Vector{libgb.GrB_Index}(I), X, length(X), dup[$T])
        end
    end
    # Setindex functions
    func = Symbol(prefix, :_Vector_setElement_, suffix(T))
    @eval begin
        function Base.setindex!(v::GBVector{$T}, x::$T, i::Integer)
            return libgb.$func(v, x, libgb.GrB_Index(i))
        end
    end
    # Getindex functions
    func = Symbol(prefix, :_Vector_extractElement_, suffix(T))
    @eval begin
        function Base.getindex(v::GBVector{$T}, i::Integer)
            return libgb.$func(v, libgb.GrB_Index(i))
        end
    end
    # findnz functions
    func = Symbol(prefix, :_Vector_extractTuples_, suffix(T))
    @eval begin
        function SparseArrays.findnz(v::GBVector{$T})
            return libgb.$func(v)
        end
    end
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
    mask = C_NULL, accum = C_NULL, desc = Descriptors.NULL
)
    I, ni = idx(I)
    libgb.GrB_Vector_extract(w, mask, getoperator(accum, eltype(w)), u, I, ni, desc)
    return w
end

"""
    extract(u::GBVector, I; kwargs...)::GBVector

Extract a subvector from `u` and return it. Equivalent to the matrix definition.
"""
function extract(
    u::GBVector, I;
    mask = C_NULL, accum = C_NULL, desc = Descriptors.NULL
)
    wlen = _outlength(u, I)
    w = similar(u, wlen)
    return extract!(w, u, I; mask, accum, desc)
end

function Base.getindex(
    u::GBVector, ::Colon;
    mask = C_NULL, accum = C_NULL, desc = Descriptors.NULL
)
    return extract(u, ALL; mask, accum, desc)
end

function Base.getindex(
    u::GBVector, i::Union{Vector, UnitRange, StepRange};
    mask = C_NULL, accum = C_NULL, desc = Descriptors.NULL
)
    return extract(u, i; mask, accum, desc)
end

"""
    subassign(w::GBVector, u::GBVector, I; kwargs...)::GBVector

Assign a subvector of `w` to `u`. Return `u`. Equivalent to the matrix definition.
"""
function subassign!(
    w::GBVector, u, I;
    mask = C_NULL, accum = C_NULL, desc = Descriptors.NULL
)
    I, ni = idx(I)
    u isa Vector && (u = GBVector(u))
    if u isa GBVector
        libgb.GxB_Vector_subassign(w, mask, getoperator(accum, eltype(w)), u, I, ni, desc)
    else
        libgb.scalarvecsubassign[eltype(u)](w, mask, getoperator(accum, eltype(w)), u, I, ni, desc)
    end
    return nothing
end

"""
    assign(w::GBVector, u::GBVector, I; kwargs...)::GBVector

Assign a subvector of `w` to `u`. Return `u`. Equivalent to the matrix definition.
"""
function assign!(
    w::GBVector, u, I;
    mask = C_NULL, accum = C_NULL, desc = Descriptors.NULL
)
    I, ni = idx(I)
    u isa Vector && (u = GBVector(u))
    if u isa GBVector
        libgb.GrB_Vector_assign(w, mask, getoperator(accum, eltype(w)), u, I, ni, desc)
    else
        libgb.scalarvecassign[eltype(u)](w, mask, getoperator(accum, eltype(w)), u, I, ni, desc)
    end
    return nothing
end

function Base.setindex!(
    u::GBVector, x, ::Colon;
    mask = C_NULL, accum = C_NULL, desc = Descriptors.NULL
)
    subassign!(u, x, ALL; mask, accum, desc)
    return nothing
end
function Base.setindex!(
    u::GBVector, x, I::Union{Vector, UnitRange, StepRange};
    mask = C_NULL, accum = C_NULL, desc = Descriptors.NULL
)
    subassign!(u, x, I; mask, accum, desc)
    return nothing
end
