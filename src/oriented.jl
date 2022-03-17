mutable struct OrientedGBMatrix{T, F, O} <: AbstractGBMatrix{T, F}
    p::Ref{LibGraphBLAS.GrB_Matrix}
    fill::F
end

const GBMatrixC{T, F} = OrientedGBMatrix{T, F, StorageOrders.ColMajor()}
const GBMatrixR{T, F} = OrientedGBMatrix{T, F, StorageOrders.RowMajor()}
StorageOrders.storageorder(::OrientedGBMatrix{T, F, O}) where {T, F, O} = O

# Constructors:
###############
"""
    GBMatrix{T}(nrows, ncols; fill = nothing)

Create a GBMatrix of the specified size, defaulting to the maximum on each dimension, 2^60.
"""
function OrientedGBMatrix{T, O}(nrows::Integer, ncols::Integer; fill::F = nothing) where {T, F, O}
    m = Ref{LibGraphBLAS.GrB_Matrix}()
    @wraperror LibGraphBLAS.GrB_Matrix_new(m, gbtype(T), nrows, ncols)
    A = GBMatrix{T, F}(finalizer(m) do ref
        @wraperror LibGraphBLAS.GrB_Matrix_free(ref)
    end, fill)
    gbset(A, :format, O === StorageOrders.ColMajor() ? :bycol : :byrow)
end

OrientedGBMatrix{T, O}(dims::Dims{2}; fill = nothing) where {T, O} = OrientedGBMatrix{T, O}(dims...; fill)
OrientedGBMatrix{T, O}(dims::Tuple{<:Integer}; fill = nothing) where {T, O} = OrientedGBMatrix{T, O}(dims...; fill)
OrientedGBMatrix{T, O}(size::Tuple{Base.OneTo, Base.OneTo}; fill = nothing) where {T, O} =
    OrientedGBMatrix{T, O}(size[1].stop, size[2].stop; fill)

"""
    GBMatrix(I, J, X; combine = +, nrows = maximum(I), ncols = maximum(J))

Create an nrows x ncols GBMatrix M such that M[I[k], J[k]] = X[k]. The combine function defaults
to `|` for booleans and `+` for nonbooleans.
"""
function OrientedGBMatrix{O}(
    I::AbstractVector, J::AbstractVector, X::AbstractVector{T};
    combine = +, nrows = maximum(I), ncols = maximum(J), fill = nothing
) where {T, O}
    I isa Vector || (I = collect(I))
    J isa Vector || (J = collect(J))
    X isa Vector || (X = collect(X))
    A = OrientedGBMatrix{T, O}(nrows, ncols; fill)
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
function OrientedGBMatrix{O}(I::AbstractVector, J::AbstractVector, x::T;
    nrows = maximum(I), ncols = maximum(J), fill = nothing) where {T, O}
    A = OrientedGBMatrix{T, O}(nrows, ncols; fill)
    build(A, I, J, x)
    return A
end


function OrientedGBMatrix{O}(dims::Dims{2}, x::T; fill = nothing) where {T, O}
    A = OrientedGBMatrix{T, O}(dims; fill)
    A[:, :] = x
    return A
end

OrientedGBMatrix{O}(nrows, ncols, x::T; fill::F = nothing) where {T, F, O} = OrientedGBMatrix{O}((nrows, ncols), x; fill)
function OrientedGBMatrix{O}(v::GBVector) where {O}
    # this copies, I think that's ideal, and I can implement @view or something at a later date.
    return copy(OrientedGBMatrix{eltype(v), typeof(v.fill), O}(v.p, v.fill)) 
end

Base.unsafe_convert(::Type{LibGraphBLAS.GrB_Matrix}, A::OrientedGBMatrix) = A.p[]

function Base.copy(A::OrientedGBMatrix{T, F, O}) where {T, F, O}
    C = Ref{LibGraphBLAS.GrB_Matrix}()
    LibGraphBLAS.GrB_Matrix_dup(C, gbpointer(A))
    return OrientedGBMatrix{T, F, O}(C, A.fill) # This should automatically be the same orientation.
end

# because of the fill kwarg we have to redo a lot of the Base.similar dispatch stack.
function Base.similar(
    A::OrientedGBMatrix{T, F, O}, ::Type{TNew} = T,
    dims::Tuple{Int64, Vararg{Int64, N}} = size(A); fill = parent(A).fill
) where {T, TNew, N, F, O}
    if dims isa Dims{1}
        return GBVector{TNew}(dims...; fill)
    else
        A = OrientedGBMatrix{TNew, O}(dims...; fill)
    end
end

function Base.similar(A::OrientedGBMatrix{T}, dims::Tuple; fill = parent(A).fill) where {T}
    return similar(A, T, dims; fill)
end

function Base.similar(
    A::OrientedGBMatrix{T}, ::Type{TNew},
    dims::Integer; fill = parent(A).fill
) where {T, TNew}
    return similar(A, TNew, (dims,); fill)
end

function Base.similar(
    A::OrientedGBMatrix{T}, ::Type{TNew},
    dim1::Integer, dim2::Integer; fill = parent(A).fill
) where {T, TNew}
    return similar(A, TNew, (dim1, dim2); fill)
end

function Base.similar(
    A::OrientedGBMatrix{T},
    dims::Integer; fill = parent(A).fill
) where {T}
    return similar(A, (dims,); fill)
end

function Base.similar(
    A::OrientedGBMatrix{T},
    dim1::Integer, dim2::Integer; fill = parent(A).fill
) where {T}
    return similar(A, (dim1, dim2); fill)
end