mutable struct OrientedGBMatrix{T, O, F} <: AbstractGBMatrix{T, F}
    p::Base.RefValue{LibGraphBLAS.GrB_Matrix}
    fill::F
end

const GBMatrixC{T, F} = OrientedGBMatrix{T, StorageOrders.ColMajor(), F}
const GBMatrixR{T, F} = OrientedGBMatrix{T, StorageOrders.RowMajor(), F}
StorageOrders.storageorder(::OrientedGBMatrix{T, O, F}) where {T, O, F} = O

# Constructors:
###############
"""
    OrientedGBMatrix{T}(nrows, ncols; fill = nothing)

Create a GBMatrix of the specified size.
"""
function OrientedGBMatrix{T, O, F}(nrows::Integer, ncols::Integer; fill::F = nothing) where {T, O, F}
    m = Ref{LibGraphBLAS.GrB_Matrix}()
    @wraperror LibGraphBLAS.GrB_Matrix_new(m, gbtype(T), nrows, ncols)
    A = GBMatrix{T, F}(finalizer(m) do ref
        @wraperror LibGraphBLAS.GrB_Matrix_free(ref)
    end, fill)
    gbset(A, :format, O === StorageOrders.ColMajor() ? :bycol : :byrow)
    return OrientedGBMatrix{T, O, F}(A)
end
OrientedGBMatrix{T, O}(nrows::Integer, ncols::Integer; fill::F = nothing) where {T, O, F} = OrientedGBMatrix{T, O, F}(nrows, ncols; fill)
GBMatrixC{T}(nrows::Integer, ncols::Integer; fill::F = nothing) where {T, F} = GBMatrixC{T, F}(nrows, ncols; fill)
GBMatrixR{T}(nrows::Integer, ncols::Integer; fill::F = nothing) where {T, F} = GBMatrixR{T, F}(nrows, ncols; fill)

OrientedGBMatrix{T, O, F}(dims::Dims{2}; fill::F = nothing) where {T, O, F} = OrientedGBMatrix{T, O}(dims...; fill)
OrientedGBMatrix{T, O, F}(dims::Tuple{<:Integer}; fill::F = nothing) where {T, O, F} = OrientedGBMatrix{T, O}(dims...; fill)
OrientedGBMatrix{T, O, F}(size::Tuple{Base.OneTo, Base.OneTo}; fill::F = nothing) where {T, O, F} =
    OrientedGBMatrix{T, O}(size[1].stop, size[2].stop; fill)

OrientedGBMatrix{T, O}(dims::Tuple; fill::F = nothing) where {T, O, F} = OrientedGBMatrix{T, O, F}(dims; fill)
GBMatrixC{T}(dims::Tuple; fill::F = nothing) where {T, F} = GBMatrixC{T, F}(dims; fill)
GBMatrixR{T}(dims::Tuple; fill::F = nothing) where {T, F} = GBMatrixR{T, F}(dims; fill)
"""
    OrientedGBMatrix(I, J, X; combine = +, nrows = maximum(I), ncols = maximum(J))

Create an nrows x ncols GBMatrix M such that M[I[k], J[k]] = X[k]. The combine function defaults
to `|` for booleans and `+` for nonbooleans.
"""
function OrientedGBMatrix{T, O, F}(
    I::AbstractVector, J::AbstractVector, X::AbstractVector{T};
    combine = +, nrows = maximum(I), ncols = maximum(J), fill::F = nothing
) where {T, O, F}
    I isa Vector || (I = collect(I))
    J isa Vector || (J = collect(J))
    X isa Vector || (X = collect(X))
    A = OrientedGBMatrix{T, O}(nrows, ncols; fill)
    build!(A, I, J, X; combine)
    return A
end
function OrientedGBMatrix{O}(
    I::AbstractVector, J::AbstractVector, X::AbstractVector{T}; 
    combine = +, nrows = maximum(I), ncols = maximum(J), fill::F = nothing
) where {T, O, F}
    return OrientedGBMatrix{T, O, F}(I, J, X,; combine, nrows, ncols, fill)
end


GBMatrixC(
    I::AbstractVector, J::AbstractVector, X::AbstractVector; 
    combine = +, nrows = maximum(I), ncols = maximum(J), fill = nothing
) = OrientedGBMatrix{ColMajor()}(I, J, X; combine, nrows, ncols, fill)
GBMatrixR(
    I::AbstractVector, J::AbstractVector, X::AbstractVector;
    combine = +, nrows = maximum(I), ncols = maximum(J), fill = nothing
) = OrientedGBMatrix{RowMajor()}(I, J, X; combine, nrows, ncols, fill)


#iso constructors
"""
    OrientedGBMatrix(I, J, x; nrows = maximum(I), ncols = maximum(J))

Create an nrows x ncols GBMatrix M such that M[I[k], J[k]] = x.
The resulting matrix is "iso-valued" such that it only stores `x` once rather than once for
each index.
"""
function OrientedGBMatrix{T, O, F}(I::AbstractVector, J::AbstractVector, x::T;
    nrows = maximum(I), ncols = maximum(J), fill::F = nothing) where {T, O, F}
    A = OrientedGBMatrix{T, O, F}(nrows, ncols; fill)
    build!(A, I, J, x)
    return A
end
OrientedGBMatrix{O}(I::AbstractVector, J::AbstractVector, x::T; nrows = maximum(I), ncols = maximum(J), fill::F = nothing) where {T, O, F} = 
    OrientedGBMatrix{T, O, F}(I, J, x; nrows, ncols, fill)


function OrientedGBMatrix{T, O, F}(dims::Dims{2}, x::T; fill::F = nothing) where {T, O, F}
    A = OrientedGBMatrix{T, O, F}(dims; fill)
    A[:, :] = x
    return A
end
OrientedGBMatrix{O}(dims::Dims{2}, x::T; fill::F = nothing) where {T, O, F} = OrientedGBMatrix{T, O, F}(dims, x; fill)

OrientedGBMatrix{T, O, F}(nrows, ncols, x::T; fill::F = nothing) where {T, O, F} = OrientedGBMatrix{O}((nrows, ncols), x; fill)
OrientedGBMatrix{O}(nrows, ncols, x::T; fill::F = nothing) where {T, O, F} = OrientedGBMatrix{T, O, F}(nrows, ncols, x; fill)

function OrientedGBMatrix{T, O, F}(v::GBVector) where {T, O, F}
    O === ByRow() && throw(ArgumentError("Cannot wrap a GBVector in a ByRow matrix."))
    # this copies, I think that's ideal, and I can implement @view or something at a later date.
    return copy(OrientedGBMatrix{T, O, F}(v.p, v.fill)) 
end
function OrientedGBMatrix{O}(v::GBVector) where {O}
    # this copies, I think that's ideal, and I can implement @view or something at a later date.
    return OrientedGBMatrix{eltype(v), typeof(v.fill), O}(v) 
end

function OrientedGBMatrix{T, O, F}(A::AbstractGBMatrix) where {T, O, F}
    storageorder(A) != O && throw(ArgumentError("Cannot wrap a GBMatrix in an OrientedGBMatrix with a different orientation."))
    # this copies, I think that's ideal, and I can implement @view or something at a later date.
    return copy(OrientedGBMatrix{T, O, F}(A.p, A.fill)) 
end
function OrientedGBMatrix{O}(A::AbstractGBMatrix) where {O}
    # this copies, I think that's ideal, and I can implement @view or something at a later date.
    return OrientedGBMatrix{eltype(A), typeof(A.fill), O}(A) 
end

GBMatrixR(A::AbstractGBMatrix) = OrientedGBMatrix{RowMajor()}(A)
GBMatrixC(A::AbstractGBMatrix) = OrientedGBMatrix{ColMajor()}(A)

GBMatrixC(
    I::AbstractVector, J::AbstractVector, X::T;
    nrows = maximum(I), ncols = maximum(J), fill = nothing
) where {T} = OrientedGBMatrix{ColMajor()}(I, J, X; nrows, ncols, fill)
GBMatrixR(
    I::AbstractVector, J::AbstractVector, X::T;
     nrows = maximum(I), ncols = maximum(J), fill = nothing
) where {T} = OrientedGBMatrix{RowMajor()}(I, J, X; nrows, ncols, fill)

Base.unsafe_convert(::Type{LibGraphBLAS.GrB_Matrix}, A::OrientedGBMatrix) = A.p[]

function Base.copy(A::OrientedGBMatrix{T, O, F}) where {T, O, F}
    C = Ref{LibGraphBLAS.GrB_Matrix}()
    LibGraphBLAS.GrB_Matrix_dup(C, A)
    return OrientedGBMatrix{T, O, F}(C, A.fill) # This should automatically be the same orientation.
end

# because of the fill kwarg we have to redo a lot of the Base.similar dispatch stack.
function Base.similar(
    A::OrientedGBMatrix{T, O, F}, ::Type{TNew} = T,
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

function gbset(A::OrientedGBMatrix, option, value)
    if option === :format
        throw(ArgumentError("Cannot change orientation of an OrientedGBMatrix"))
    end
    option = option_toconst(option)
    value = option_toconst(value)
    GxB_Matrix_Option_set(A, option, value)
    return nothing
end