# Constructors:
###############
"""
    GBMatrix{T}(nrows, ncols; fill = nothing)

Create a GBMatrix of the specified size, defaulting to the maximum on each dimension, 2^60.
"""
function GBMatrix{T}(nrows::Integer, ncols::Integer; fill::F = nothing) where {T, F}
    m = Ref{LibGraphBLAS.GrB_Matrix}()
    @wraperror LibGraphBLAS.GrB_Matrix_new(m, gbtype(T), nrows, ncols)
    return GBMatrix{T, F}(finalizer(m) do ref
        @wraperror LibGraphBLAS.GrB_Matrix_free(ref)
    end, fill)
end

GBMatrix{T}(dims::Dims{2}; fill = nothing) where {T} = GBMatrix{T}(dims...; fill)
GBMatrix{T}(dims::Tuple{<:Integer}; fill = nothing) where {T} = GBMatrix{T}(dims...; fill)
GBMatrix{T}(size::Tuple{Base.OneTo, Base.OneTo}; fill = nothing) where {T} =
    GBMatrix{T}(size[1].stop, size[2].stop; fill)

"""
    GBMatrix(I, J, X; combine = +, nrows = maximum(I), ncols = maximum(J))

Create an nrows x ncols GBMatrix M such that M[I[k], J[k]] = X[k]. The combine function defaults
to `|` for booleans and `+` for nonbooleans.
"""
function GBMatrix(
    I::AbstractVector, J::AbstractVector, X::AbstractVector{T};
    combine = +, nrows = maximum(I), ncols = maximum(J), fill = nothing
) where {T}
    I isa Vector || (I = collect(I))
    J isa Vector || (J = collect(J))
    X isa Vector || (X = collect(X))
    A = GBMatrix{T}(nrows, ncols; fill)
    build(A, I, J, X; combine)
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
    nrows = maximum(I), ncols = maximum(J), fill = nothing) where {T}
    A = GBMatrix{T}(nrows, ncols; fill)
    build(A, I, J, x)
    return A
end


function GBMatrix(dims::Dims{2}, x::T; fill = nothing) where {T}
    A = GBMatrix{T}(dims; fill)
    A[:, :] = x
    return A
end

GBMatrix(nrows, ncols, x::T; fill::F = nothing) where {T, F} = GBMatrix((nrows, ncols), x; fill)

# TODO, switch to pointer fudging.
function GBMatrix(v::GBVector)
    A = GBMatrix{eltype(v)}(size(v, 1), size(v, 2))
    nz = findnz(v)
    for i ∈ 1:length(nz[1])
        A[nz[1][i], 1] = nz[2][i]
    end
    return A
end

# Some Base and basic SparseArrays/LinearAlgebra functions:
###########################################################

Base.unsafe_convert(::Type{LibGraphBLAS.GrB_Matrix}, A::GBMatrix) = A.p[]

function Base.copy(A::GBMatrix{T, F}) where {T, F}
    C = Ref{LibGraphBLAS.GrB_Matrix}()
    LibGraphBLAS.GrB_Matrix_dup(C, gbpointer(A))
    return GBMatrix{T, F}(C, A.fill)
end

function Base.similar(
    A::GBMatrix{T}, ::Type{TNew},
    dims::Union{Dims{1}, Dims{2}}; fill::F = A.fill
) where {T, TNew, F}
    if dims isa Dims{1}
        return GBVector{TNew}(dims...; fill)
    else
        return GBMatrix{TNew}(dims...; fill)
    end
end

# TODO: FIXME
# function LinearAlgebra.diagm(v::GBVector, k::Integer=0; desc = nothing)
#     return Diagonal(v, k; desc)
# end

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

# Linear indexing
function Base.getindex(A::GBMatOrTranspose, v::AbstractVector)
    throw("Not implemented")
end

