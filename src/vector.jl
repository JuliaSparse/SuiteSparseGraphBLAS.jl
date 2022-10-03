# Constructors:
###############
"""
    GBVector{T}(n; fill = nothing)
"""
# function GBVector{T}(n; fill::F = nothing) where {T, F}
#     m = Ref{LibGraphBLAS.GrB_Matrix}()
#     @wraperror LibGraphBLAS.GrB_Matrix_new(m, gbtype(T), n, 1)
#     return GBVector{T}(m; fill)
# end
# 
# function GBVector{T}(
#     p::Base.RefValue{LibGraphBLAS.GrB_Matrix}; 
#     fill::F = nothing
# ) where {T, F}
# 
#     v = GBVector{T, F}(finalizer(p) do ref
#         @wraperror LibGraphBLAS.GrB_Matrix_free(ref)
#     end, fill)
#     gbset(v, FORMAT, BYCOL)
#     return v
# end
# 
# GBVector{T}(dims::Dims{1}; fill = nothing) where {T} = GBVector{T}(dims...; fill)
# GBVector{T}(nrows::Base.OneTo; fill = nothing) where {T} =
#     GBVector{T}(nrows.stop; fill)
# GBVector{T}(nrows::Tuple{Base.OneTo,}; fill = nothing) where {T} = GBVector{T}(first(nrows); fill)
# 
# """
#     GBVector(I::AbstractVector, X::AbstractVector{T}; fill = nothing)
# 
# Create a GBVector from a vector of indices `I` and a vector of values `X`.
# """
# function GBVector(I::AbstractVector{U}, X::AbstractVector{T}; combine = +, nrows = maximum(I), fill = nothing) where {U<:Integer, T}
#     I isa Vector || (I = collect(I))
#     X isa Vector || (X = collect(X))
#     v = GBVector{T}(nrows; fill)
#     build!(v, I, X; combine)
#     return v
# end
# 
# function GBVector{T}(
#     I::AbstractVector, X::AbstractVector{Told}; 
#     combine = +, nrows = maximum(I), fill = nothing
# ) where {T, U, Told}
#     return GBVector(I, T.(X); combine, nrows, fill)
# end
# #iso valued constructors.
# """
#     GBVector(I, x; nrows = maximum(I) fill = nothing)
# 
# Create an GBVector `v` from coordinates `I` such that `M[I] = x` .
# The resulting vector is "iso-valued" such that it only stores `x` once rather than once for
# each index.
# """
# function GBVector(I::AbstractVector{U}, x::T;
#     nrows = maximum(I), fill = nothing) where {U<:Integer, T}
#     A = GBVector{T}(nrows; fill)
#     build!(A, I, x)
#     return A
# end
# 
# """
#     GBVector(n, x; fill = nothing)
# 
# Create an `n` length dense GBVector `v` such that M[:] = x.
# The resulting vector is "iso-valued" such that it only stores `x` once rather than once for
# each index.
# """
# function GBVector(n::Integer, x::T; fill = nothing) where {T}
#     v = GBVector{T}(n; fill)
#     v .= x
#     return v
# end
# 
# GBVector{T, F}(::Number) where {T, F} = throw(ArgumentError("The F parameter is implicit and determined by the `fill` keyword argument to constructors. Users must not specify this manually."))

# Some Base and basic SparseArrays/LinearAlgebra functions:
###########################################################
Base.unsafe_convert(::Type{LibGraphBLAS.GrB_Matrix}, v::GBVector) = v.p[]

function Base.copy(A::GBVector{T, F}) where {T, F}
    C = Ref{LibGraphBLAS.GrB_Matrix}()
    LibGraphBLAS.GrB_Matrix_dup(C, A)
    return GBVector{T, F}(C, A.fill)
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
