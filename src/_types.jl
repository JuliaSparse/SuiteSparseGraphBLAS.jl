"""
    @gbmatrixtype <typename>

Automatically define the basic AbstractGBMatrix interface constructors.
"""
macro gbmatrixtype(typename)
    esc(quote
        # Empty Constructors:
        function $typename{T}(nrows::Integer, ncols::Integer) where {T}
            m = _newGrBRef()
            @wraperror LibGraphBLAS.GrB_Matrix_new(m, gbtype(T), nrows, ncols)
            return $typename{T}(m)
        end

        $typename{T}(dims::D) where {T, D<:Union{Dims{2}, Tuple{<:Integer, <:Integer}}} = 
            $typename{T}(dims...)

        $typename{T}(size::Tuple{Base.OneTo, Base.OneTo}) where {T} =
            $typename{T}(size[1].stop, size[2].stop)
        
        # Coordinate Form Constructors:
        function $typename{T}(
            I::AbstractVector, J::AbstractVector, X::AbstractVector{T2}, nrows, ncols;
            combine = +
        ) where {T, T2}
            I isa Vector || (I = collect(I))
            J isa Vector || (J = collect(J))
            (T2 == T && X isa DenseVector) || (X = convert(Vector{T2}, X))
            A = $typename{T}(nrows, ncols)
            build!(A, I, J, X; combine)
            return A
        end
        $typename{T}(
            I::AbstractVector, J::AbstractVector, X::AbstractVector;
            combine = +
        ) where {T} = $typename{T}(I, J, X, maximum(I), maximum(J); combine)
        
        $typename(
            I::AbstractVector, J::AbstractVector, X::AbstractVector{T}, nrows, ncols;
            combine = +
        ) where T = $typename{T}(I, J, X, nrows, ncols; combine)
        $typename(
            I::AbstractVector, J::AbstractVector, X::AbstractVector{T};
            combine = +
        ) where {T} = $typename{T}(I, J, X; combine)

        # ISO constructors:
        function $typename{T}(
            I::AbstractVector, J::AbstractVector, x, 
            nrows, ncols
        ) where {T}
            A = $typename{T}(nrows, ncols)
            build!(A, I, J, convert(T, x))
            return A
        end
        $typename{T}(
            I::AbstractVector, J::AbstractVector, x
        ) where {T} = $typename{T}(I, J, x, maximum(I), maximum(J))
        
        function $typename(
            I::AbstractVector, J::AbstractVector, x::T, nrows, ncols) where {T}
            $typename{T}(I, J, x, nrows, ncols)
        end
        $typename(I::AbstractVector, J::AbstractVector, x::T) where T = 
            $typename{T}(I, J, x, maximum(I), maximum(J))
        
        function $typename{T}(dims::Dims{2}, x) where {T}
            A = $typename{T}(dims)
            A .= x
            return A
        end
        
        $typename{T}(nrows, ncols, x) where {T} = 
            $typename{T}((nrows, ncols), x)
        $typename(nrows, ncols, x::T) where T = 
            $typename{T}((nrows, ncols), x)
        $typename(dims::Tuple{<:Integer}, x::T) where T = 
            $typename{T}(dims..., x)
        $typename(size::Tuple{Base.OneTo, Base.OneTo}, x::T) where T = 
            $typename{T}(size[1].stop, size[2].stop, x)
        
        # Convert based ctors:
        function $typename{T}(v::AbstractGBVector) where {T}
            return convert($typename{T}, v)
        end
        function $typename(v::AbstractGBVector{T}) where {T}
            return $typename{T}(v)
        end
        function $typename{T}(A::AbstractGBMatrix) where {T}
            return convert($typename{T}, A)
        end
        function $typename(A::AbstractGBMatrix{T}) where {T}
            return $typename{T}(A)
        end
        # Pack based constructors:
        # General matrices!
        function $typename{T}(
            A::Union{<:AbstractVector, <:AbstractMatrix};
        ) where {T}
            vpack = _sizedjlmalloc(length(A), T)
            vpack = unsafe_wrap(Array, vpack, size(A))
            copyto!(vpack, A)
            C = $typename{T}(size(A, 1), size(A, 2))
            return unsafepack!(C, vpack, false; order = storageorder(A))
        end
        $typename(
            A::Union{<:AbstractVector{T}, <:AbstractMatrix{T}}; 
    
        ) where {T} = $typename{T}(A)

        # Sparse Matrices:
        function $typename{T}(
            A::SparseVector
        ) where {T}
            C = $typename{T}(size(A, 1), 1)
            return unsafepack!(C, _copytoraw(A)..., false)
        end
        
        function $typename{T}(
            A::SparseMatrixCSC
        ) where {T}
            C = $typename{T}(size(A)...)
            return unsafepack!(C, _copytoraw(A)..., false)
        end
        $typename(
            A::SparseMatrixCSC{T}
        ) where {T} = $typename{T}(A)

        # Diagonal ctor
        function $typename{T}(
            A::Diagonal
        ) where {T}
            C = $typename{T}(size(A))
            GBDiagonal!(C, A)
        end
        $typename(A::Diagonal{T}) where {T} =
            $typename{T}(A)

        # Uniform Scaling
        function $typename{T}(
            A::UniformScaling, args...
        ) where {T}
            C = $typename{T}(args...)
            GBDiagonal!(C, A(size(C, 1)))
        end
        $typename(A::UniformScaling{T}, args...) where {T} =
            $typename{T}(A, args...)
        $typename(A::UniformScaling{T}, n::Integer) where {T} =
            $typename{T}(A, n, n)
        # similar
        function Base.similar(
            A::$typename{T}, ::Type{TNew} = T,
            dims::Tuple{Int64, Vararg{Int64, N}} = size(A)
        ) where {T, TNew, N}
            if dims isa Dims{1}
                # TODO: When new Vector types are added this will be incorrect.
                x = GBVector{TNew}(dims...)
            elseif $typename <: AbstractGBVector
                x = GBMatrix{TNew}(dims...)
            else
                x = $typename{TNew}(dims...)
            end
            _hasconstantorder(x) || setstorageorder!(x, storageorder(A))
            return x
        end
        strip_parameters(::Type{<:$typename}) = $typename
    end)
end

macro gbvectortype(typename)
    esc(quote
        function $typename{T}(n::Integer) where {T}
            m = _newGrBRef()
            @wraperror LibGraphBLAS.GrB_Matrix_new(m, gbtype(T), n, 1)
            return $typename{T}(m)
        end
        
        $typename{T}(dims::D) where {T, D<:Union{Dims{1}, Tuple{<:Integer}}} = 
            $typename{T}(dims...)

        $typename{T}(size::Tuple{Base.OneTo}) where {T} =
            $typename{T}(size[1].stop)
        
        function $typename{T}(
            I::AbstractVector, X::AbstractVector{T2}, n;
            combine = +
        ) where {T, T2}
            I isa Vector || (I = collect(I))
            (T2 == T && X isa DenseVector) || (X = convert(Vector{T2}, X))
            A = $typename{T}(n)
            build!(A, I, X; combine)
            return A
        end
        $typename{T}(
            I::AbstractVector, X::AbstractVector;
            combine = +
        ) where {T} = $typename{T}(I, X, maximum(I); combine)
        
        $typename(
            I::AbstractVector, X::AbstractVector{T}, n;
            combine = +
        ) where T = $typename{T}(I, X, n; combine)
        $typename(
            I::AbstractVector, X::AbstractVector{T};
            combine = +
        ) where {T} = $typename{T}(I, X; combine)

        function $typename{T}(
            I::AbstractVector, x, 
            n = maximum(I)
        ) where {T}
            A = $typename{T}(n)
            build!(A, I, convert(T, x))
            return A
        end
        
        function $typename(
            I::AbstractVector, x::T, n = maximum(I)) where {T}
            $typename{T}(I, J, x, n)
        end
        
        function $typename{T}(dims::Dims{1}, x) where {T}
            A = $typename{T}(dims)
            A .= x
            return A
        end
        $typename(dims::Dims{1}, x::T) where T = 
            $typename{T}(dims, x)
        
        $typename{T}(nrows, x) where T =
            $typename{T}((nrows,), x)
        $typename(nrows, x::T) where T = 
            $typename{T}(nrows, x)
        $typename(dims::Tuple{<:Integer}, x::T) where T = 
            $typename{T}(dims..., x)
        $typename(size::Tuple{Base.OneTo}, x::T) where T = 
            $typename{T}(size[1].stop, x)
        
        function $typename{T}(v::AbstractGBVector) where {T}
            return convert($typename{T}, v)
        end
        function $typename(v::AbstractGBVector{T}) where {T}
            return $typename{T}(v)
        end

        # Pack based constructors:
        function $typename{T}(
            A::AbstractVector
        ) where {T}
            vpack = _sizedjlmalloc(length(A), T)
            vpack = unsafe_wrap(Array, vpack, size(A))
            copyto!(vpack, A)
            C = $typename{T}(size(A))
            return unsafepack!(C, vpack, false; order = storageorder(A))
        end

        $typename(A::AbstractVector{T}) where {T} = $typename{T}(A)

        function $typename{T}(A::SparseVector) where {T}
            C = $typename{T}(size(A, 1))
            return unsafepack!(C, _copytoraw(A)..., false)
        end
        $typename(A::SparseVector{T}) where {T} = $typename{T}(A)

        function Base.similar(
            v::$typename{T}, ::Type{TNew} = T,
            dims::Tuple{Int64, Vararg{Int64, N}} = size(v)
        ) where {T, TNew, N}
            if dims isa Dims{1}
                # TODO: When new Vector types are added this will be incorrect.
                x = $typename{TNew}(dims...)
            else
                x = GBMatrix{TNew}(dims...)
            end
            _hasconstantorder(x) || setstorageorder!(x, storageorder(v))
            return x
        end
        # misc utilities: 
        strip_parameters(::Type{<:$typename}) = $typename
    end)
end

"""
    GBVector{T} <: AbstractSparseArray{Union{T, NoValue}, UInt64, 1}

One-dimensional GraphBLAS array with elements of type T.
Internal representation is specified as opaque, but may be either a dense vector, bitmap vector, or 
compressed sparse vector.

See also: [`GBMatrix`](@ref).

# Construction Signatures

    GBVector{T}(n::Integer)
    GBVector(I::AbstractVector, X::AbstractVector{T}, n; combine=+)
    GBVector(I::AbstractVector, x::T, n; combine=+)
    GBVector(v::Union{<:AbstractGBVector, <:AbstractVector})

All constructors, no matter their input, may specify parameters for 
element type `T`, conversions are handled internally.
"""
mutable struct GBVector{T} <: AbstractGBVector{T, ColMajor()}
    p::Base.RefValue{LibGraphBLAS.GrB_Matrix} # a GBVector is a GBMatrix internally.
end

# we call @gbvectortype GBVector below GBMatrix defn.

"""
    GBMatrix{T} <: AbstractSparseArray{Union{T, NoValue}, UInt64, 2}

Two-dimensional GraphBLAS array with elements of type `T`.
Internal representation is specified as opaque, but in this implementation is stored as one of 
the following in either row or column orientation:

    1. Dense
    2. Bitmap
    3. Sparse Compressed
    4. Hypersparse

The storage type is automatically determined by the library.

#Signatures

    GBMatrix{T}(nrows::Integer, ncols::Integer)
    GBMatrix(I::AbstractVector, J::AbstractVector, X::AbstractVector{T}, dims...; combine=+)
    GBMatrix(I::AbstractVector, J::AbstractVector, x::T, dims...; combine=+)
    GBMatrix(A::Union{<:AbstractGBArray, <:AbstractMatrix})

All constructors, no matter their input, may specify an element type `T`, conversions are handled internally.

`GBMatrix` construction from an existing AbstractArray will maintain the storage order of the original,
typically `ColMajor()`. 
"""
mutable struct GBMatrix{T} <: AbstractGBMatrix{T, RuntimeOrder()}
    p::Base.RefValue{LibGraphBLAS.GrB_Matrix}
end

@gbmatrixtype GBMatrix
@gbvectortype GBVector

"""
    OrientedGBMatrix{T, O} <: AbstractSparseArray{Union{T, NoValue}, UInt64, 2}

Two-dimensional GraphBLAS array with elements of type `T`.
Exactly the same as [`GBMatrix`](@ref), except the memory orientation is static: either
`SparseBase.RowMajor()` (default) or `SparseBase.ColMajor()`.

The aliases `GBMatrixC` and `GBMatrixR` are the preferred construction methods.

#Signatures

    GBMatrix[R | C]{T}(nrows::Integer, ncols::Integer)
    GBMatrix[R | C](I::AbstractVector, J::AbstractVector, X::AbstractVector{T}, dims...; combine=+)
    GBMatrix[R | C](I::AbstractVector, J::AbstractVector, x::T, dims...; combine=+)
    GBMatrix[R | C](A::Union{<:AbstractGBArray, <:AbstractMatrix})

All constructors, no matter their input, may specify an element type `T`, conversions are handled internally.
"""
mutable struct OrientedGBMatrix{T, O} <: AbstractGBMatrix{T, O}
    p::Base.RefValue{LibGraphBLAS.GrB_Matrix}
    function OrientedGBMatrix{T, O}(
        p::Base.RefValue{LibGraphBLAS.GrB_Matrix}
    ) where {T, O}
        O isa SparseBase.StorageOrder || throw(ArgumentError("$O is not a valid StorageOrder"))
        A = new{T, O}(p)
        gbset!(A, :orientation, O)
        return A
    end
end

const GBMatrixC{T} = OrientedGBMatrix{T, SparseBase.ColMajor()}
const GBMatrixR{T} = OrientedGBMatrix{T, SparseBase.RowMajor()}
@doc (@doc OrientedGBMatrix) GBMatrixC
@doc (@doc OrientedGBMatrix) GBMatrixR

@gbmatrixtype GBMatrixC
@gbmatrixtype GBMatrixR

#=
    Shallow array types

These types do not have the general constructors created by `@gbmatrixtype` since they
should *never* be constructed by a user directly. Only through the `pack` interface.
=#
"""
    GBShallowVector{T, P, B, A} <: AbstractSparseArray{Union{T, NoValue}, UInt64, 1}

Shallow GraphBLAS vector type wrapping a Julia-resident vector. Currently supported
only for `Vector`

The primary constructor for this type is the [`pack`](@ref) function, 
although it may also be constructed directly via `GBShallowVector(A::Vector)`.
"""
mutable struct GBShallowVector{T, P, B, A} <: AbstractGBShallowArray{T, ColMajor(), P, B, A, 1}
    p::Base.RefValue{LibGraphBLAS.GrB_Matrix}
    # storage for sparse formats supported by SS:GraphBLAS
    ptr::P #colptr / rowptr
    idx::P # rowidx / colidx
    h::P # hypersparse-only
    bitmap::B # bitmap only
    nzval::A # array storage for dense arrays, nonzero values storage for everyone else.
end
function GBShallowVector{T}(p, ptr::P, idx::P, h::P, bitmap::B, nzval::A) where {T, P, B, A}
    GBShallowVector{T, P, B, A}(p, ptr, idx, h, bitmap, nzval)
end

"""
    GBShallowMatrix{T, O, P, B, A} <: AbstractSparseArray{Union{T, NoValue}, UInt64, 2}

Shallow GraphBLAS matrix type wrapping a Julia-resident array. Currently supported
only for `Matrix`

The primary constructor for this type is the [`pack`](@ref) function, although it may also be constructed directly via `GBShallowMatrix(A::Matrix)`.
"""
mutable struct GBShallowMatrix{T, O, P, B, A} <: AbstractGBShallowArray{T, O, P, B, A, 2}
    p::Base.RefValue{LibGraphBLAS.GrB_Matrix}
    # storage for sparse formats supported by SS:GraphBLAS
    ptr::P #colptr / rowptr
    idx::P # rowidx / colidx
    h::P # hypersparse-only
    bitmap::B # bitmap only
    nzval::A # array storage for dense arrays, nonzero values storage for everyone else.
end
function GBShallowMatrix{T}(p, ptr::P, idx::P, h::P, bitmap::B, nzval::A, order = ColMajor()) where {T, P, B, A}
    GBShallowMatrix{T, order, P, B, A}(p, ptr, idx, h, bitmap, nzval)
end


strip_parameters(::Type{<:GBShallowMatrix}) = GBShallowMatrix
strip_parameters(::Type{<:GBShallowVector}) = GBShallowVector
