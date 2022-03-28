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
    GBMatrix(I, J, X; combine = +, nrows = maximum(I), ncols = maximum(J); fill = nothing)

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
    GBMatrix(I, J, x; nrows = maximum(I), ncols = maximum(J); fill = nothing)

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

function GBMatrix(v::GBVector)
    # this copies, I think that's ideal, and I can implement @view or something at a later date.
    return copy(GBMatrix{eltype(v), typeof(v.fill)}(v.p, v.fill)) 
end

# Some Base and basic SparseArrays/LinearAlgebra functions:
###########################################################

Base.unsafe_convert(::Type{LibGraphBLAS.GrB_Matrix}, A::GBMatrix) = A.p[]

function Base.copy(A::GBMatrix{T, F}) where {T, F}
    C = Ref{LibGraphBLAS.GrB_Matrix}()
    LibGraphBLAS.GrB_Matrix_dup(C, gbpointer(A))
    return GBMatrix{T, F}(C, A.fill)
end


# because of the fill kwarg we have to redo a lot of the Base.similar dispatch stack.
function Base.similar(
    A::GBMatrixOrTranspose{T}, ::Type{TNew} = T,
    dims::Tuple{Int64, Vararg{Int64, N}} = size(A); fill = parent(A).fill
) where {T, TNew, N}
    if dims isa Dims{1}
        return GBVector{TNew}(dims...; fill)
    else
        return GBMatrix{TNew}(dims...; fill)
    end
end

function Base.similar(A::GBMatrixOrTranspose{T}, dims::Tuple; fill = parent(A).fill) where {T}
    return similar(A, T, dims; fill)
end

function Base.similar(
    A::GBMatrixOrTranspose{T}, ::Type{TNew},
    dims::Integer; fill = parent(A).fill
) where {T, TNew}
    return similar(A, TNew, (dims,); fill)
end

function Base.similar(
    A::GBMatrixOrTranspose{T}, ::Type{TNew},
    dim1::Integer, dim2::Integer; fill = parent(A).fill
) where {T, TNew}
    return similar(A, TNew, (dim1, dim2); fill)
end

function Base.similar(
    A::GBMatrixOrTranspose{T},
    dims::Integer; fill = parent(A).fill
) where {T}
    return similar(A, (dims,); fill)
end

function Base.similar(
    A::GBMatrixOrTranspose{T},
    dim1::Integer, dim2::Integer; fill = parent(A).fill
) where {T}
    return similar(A, (dim1, dim2); fill)
end

# TODO: FIXME
# function LinearAlgebra.diagm(v::GBVector, k::Integer=0; desc = nothing)
#     return Diagonal(v, k; desc)
# end

# Indexing functions
####################

# Linear indexing
function Base.getindex(A::GBMatOrTranspose, v::AbstractVector)
    throw("Not implemented")
end

