# Constructors:
###############

# Empty constructors:
"""
    GBVector{T}(n; fill = nothing)
"""
function GBVector{T}(n; fill::F = nothing) where {T, F}
    m = Ref{LibGraphBLAS.GrB_Matrix}()
    @wraperror LibGraphBLAS.GrB_Matrix_new(m, gbtype(T), n, 1)
    v = GBVector{T, F}(finalizer(m) do ref
        @wraperror LibGraphBLAS.GrB_Matrix_free(ref)
    end, fill)
    gbset(v, FORMAT, BYCOL)
    return v
end

GBVector{T}(dims::Dims{1}; fill = nothing) where {T} = GBVector{T}(dims...; fill)
GBVector{T}(nrows::Base.OneTo; fill = nothing) where {T} =
    GBVector{T}(nrows.stop; fill)
GBVector{T}(nrows::Tuple{Base.OneTo,}; fill = nothing) where {T} = GBVector{T}(first(nrows); fill)

# Coordinate constructors: 
"""
    GBVector(I::AbstractVector, X::AbstractVector{T}; fill = nothing)

Create a GBVector from a vector of indices `I` and a vector of values `X`, also known as the coordinate form of the vector.
"""
function GBVector(I::AbstractVector{U}, X::AbstractVector{T}; combine = +, nrows = maximum(I), fill = nothing) where {U<:Integer, T}
    I isa Vector || (I = collect(I))
    X isa Vector || (X = collect(X))
    v = GBVector{T}(nrows; fill)
    build(v, I, X; combine)
    return v
end

# iso valued constructors:
"""
    GBVector(I, x; nrows = maximum(I) fill = nothing)

Create an `n` length GBVector `v` such that `M[I[k]] = x`.
The resulting vector is "iso-valued" such that it only stores `x` once rather than once for
each index.
"""
function GBVector(I::AbstractVector{U}, x::T;
    nrows = maximum(I), fill = nothing) where {U<:Integer, T}
    A = GBVector{T}(nrows; fill)
    build(A, I, x)
    return A
end

"""
    GBVector(n, x; fill = nothing)

Create an `n` length dense GBVector `v` such that M[:] = x.
The resulting vector is "iso-valued" such that it only stores `x` once rather than once for
each index.
"""
function GBVector(n::Integer, x::T; fill = nothing) where {T}
    v = GBVector{T}(n; fill)
    v[:] = x
    return v
end

GBVector{T, F}(::Number) where {T, F} = throw(ArgumentError("The F parameter is implicit and determined by the `fill` keyword argument to constructors. Users must not specify this manually."))

function GBVector(v::AbstractVector{T}; fill::F = nothing) where {T, F}
    needcopy = true
    if v isa AbstractVector && !(v isa Vector)
        v = collect(v)
        needcopy = false
    end
    A = GBVector{T}(size(v, 1); fill)
    return pack!(A, needcopy ? copy(v) : v)
end

function GBVector(v::SparseVector{T}; fill::F = nothing) where {T, F}
    A = GBVector{T}(size(v, 1); fill)
    return pack!(A, copy(v))
end

# Some Base and basic SparseArrays/LinearAlgebra functions:
###########################################################
Base.unsafe_convert(::Type{LibGraphBLAS.GrB_Matrix}, v::GBVector) = v.p[]

function Base.copy(A::GBVector{T, F}) where {T, F}
    C = Ref{LibGraphBLAS.GrB_Matrix}()
    LibGraphBLAS.GrB_Matrix_dup(C, gbpointer(A))
    return GBVector{T, F}(C, A.fill)
end


# because of the fill kwarg we have to redo a lot of the Base.similar dispatch stack.
function Base.similar(
    v::GBVectorOrTranspose{T}, ::Type{TNew} = T,
    dims::Tuple{Int64, Vararg{Int64, N}} = size(v); fill = parent(v).fill
) where {T, TNew, N}
    if dims isa Dims{1}
        return GBVector{TNew}(dims...; fill)
    else
        return GBMatrix{TNew}(dims...; fill)
    end
end

function Base.similar(v::GBVectorOrTranspose{T}, dims::Tuple; fill = v.fill) where {T}
    return similar(v, T, dims; fill)
end

function Base.similar(
    v::GBVectorOrTranspose{T}, ::Type{TNew},
    dims::Integer; fill = parent(v).fill
) where {T, TNew}
    return similar(v, TNew, (dims,); fill)
end

function Base.similar(
    v::GBVectorOrTranspose{T},
    dims::Integer; fill = parent(v).fill
) where {T}
    return similar(v, (dims,); fill)
end

function Base.similar(
    v::GBVectorOrTranspose{T}, ::Type{TNew},
    dim1::Integer, dim2::Integer; fill = parent(v).fill
) where {T, TNew}
    return similar(v, TNew, (dim1, dim2); fill)
end

function Base.similar(
    v::GBVectorOrTranspose{T}, dim1::Integer, dim2::Integer; fill = parent(v).fill
) where {T}
    return similar(v, (dim1, dim2); fill)
end

#We need these until I can get a SparseArrays.nonzeros implementation
# TODO: REMOVE
function Base.show(io::IO, ::MIME"text/plain", v::GBVector)
    gxbprint(io, v)
end

function Base.show(io::IO, v::GBVector)
    gxbprint(io, v)
end

function Base.show(io::IOContext, v::GBVector)
    gxbprint(io, v)
end

# Indexing functions:
#####################

function Base.getindex(
    u::GBVector, I;
    mask = nothing, accum = nothing, desc = nothing
)
    return extract(u, I; mask, accum, desc)
end

function Base.getindex(u::GBVector, ::Colon; mask = nothing, accum = nothing, desc = nothing)
    return extract(u, :)
end

function Base.getindex(
    u::GBVector, i::Union{Vector, UnitRange, StepRange};
    mask = nothing, accum = nothing, desc = nothing
)
    return extract(u, i; mask, accum, desc)
end
