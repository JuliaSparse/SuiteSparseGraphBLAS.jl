# Basic AbstractArray interfaces:

# Base.similar cascade:
#######################
Base.similar(a::A; kwargs...) where {T, A <: AbstractGBArray{T}} = similar(a, T; kwargs...)
Base.similar(a::A, ::Type{T}; kwargs...) where {T, A <: AbstractGBArray} = similar(a, T, Base.to_shape(axes(a)); kwargs...)
Base.similar(a::A, dims::Tuple; kwargs...) where {T, A <: AbstractGBArray{T}} = similar(a, T, Base.to_shape(dims); kwargs...)
Base.similar(a::A, dims::Base.DimOrInd...; kwargs...) where {T, A <: AbstractGBArray{T}} = similar(a, T, Base.to_shape(dims); kwargs...)
Base.similar(a::A, ::Type{T}, dims::Base.DimOrInd...; kwargs...) where {T, A <: AbstractGBArray}  = similar(a, T, Base.to_shape(dims); kwargs...)
Base.similar(a::A, ::Type{T}, dims::Tuple{Union{Integer, OneTo}, Vararg{Union{Integer, OneTo}}}; kwargs...) where {T, A <: AbstractGBArray} = 
    similar(a, T, Base.to_shape(dims); kwargs...)
Base.similar(a::A, ::Type{T}, dims::Tuple{Integer, Vararg{Integer}}; kwargs...) where {T, A <: AbstractGBArray} = 
    similar(a, T, Base.to_shape(dims); kwargs...)

# TODO:
# This method cascade is incredibly verbose. This works fine rn since there's only 9 total types...
# There's 27 total methods already here (3 dims in * 3 dims out * 3 types)
# But this will not work in Spartan.

# Eager:
function Base.similar(
    A::EagerGBScalar, ::Type{T2}, dims::Dims{0}; 
    fill::F2 = getfill(A),
    resetfill = fill,
) where {T2, F2}
    return EagerGBScalar{T2, F2}(fill; resetfill)
end
function Base.similar(
    A::EagerGBScalar, ::Type{T2}, dims::Dims{1}; 
    fill::F2 = getfill(A),
    resetfill = fill,
) where {T2, F2}
    return EagerGBVector{T2, F2}(dims..., fill; resetfill)
end
function Base.similar(
    A::EagerGBScalar, ::Type{T2}, dims::Dims{2}; 
    fill::F2 = getfill(A),
    resetfill = fill,
    order = SparseBase.RuntimeOrder(),
    materializeviews = true
) where {T2, F2}
    return EagerGBMatrix{T2, F2, order}(dims..., fill; materializeviews, resetfill)
end

function Base.similar(
    A::EagerGBVector, ::Type{T2}, dims::Dims{0}; 
    fill::F2 = getfill(A),
    resetfill = fill,
) where {T2, F2}
    return EagerGBScalar{T2, F2}(fill; resetfill)
end
function Base.similar(
    A::EagerGBVector, ::Type{T2}, dims::Dims{1}; 
    fill::F2 = getfill(A),
    resetfill = fill,
) where {T2, F2}
    return EagerGBVector{T2, F2}(dims..., fill; resetfill)
end
function Base.similar(
    A::EagerGBVector, ::Type{T2}, dims::Dims{2}; 
    fill::F2 = getfill(A),
    resetfill = fill,
    order = SparseBase.RuntimeOrder(),
    materializeviews = true
) where {T2, F2}
    return EagerGBMatrix{T2, F2, order}(dims..., fill; materializeviews, resetfill)
end

function Base.similar(
    A::EagerGBMatrix, ::Type{T2}, dims::Dims{0}; 
    fill::F2 = getfill(A),
    resetfill = fill,
) where {T2, F2}
    return EagerGBScalar{T2, F2}(fill; resetfill)
end
function Base.similar(
    A::EagerGBMatrix, ::Type{T2}, dims::Dims{1}; 
    fill::F2 = getfill(A),
    resetfill = fill,
) where {T2, F2}
    return EagerGBVector{T2, F2}(dims..., fill; resetfill)
end
function Base.similar(
    A::EagerGBMatrix{T, F, O}, ::Type{T2}, dims::Dims{2}; 
    materializeviews = A.views.allowmaterialize,
    fill::F2 = getfill(A),
    resetfill = fill,
    order = O
) where {T, F, O, T2, F2}
    return EagerGBMatrix{T2, F2, order}(dims..., fill; materializeviews, resetfill)
end

# Lazy: 
function Base.similar(
    A::LazyGBScalar, ::Type{T2}, dims::Dims{0}; 
    fill::F2 = getfill(A),
    resetfill = fill,
) where {T2, F2}
    return LazyGBScalar{T2, F2}(fill; resetfill)
end
function Base.similar(
    A::LazyGBScalar, ::Type{T2}, dims::Dims{1}; 
    fill::F2 = getfill(A),
    resetfill = fill,
) where {T2, F2}
    return LazyGBVector{T2, F2}(dims..., fill; resetfill)
end
function Base.similar(
    A::LazyGBScalar, ::Type{T2}, dims::Dims{2}; 
    fill::F2 = getfill(A),
    resetfill = fill,
    order = SparseBase.RuntimeOrder(),
    materializeviews = true
) where {T2, F2}
    return LazyGBMatrix{T2, F2, order}(dims..., fill; materializeviews, resetfill)
end

function Base.similar(
    A::LazyGBVector, ::Type{T2}, dims::Dims{0}; 
    fill::F2 = getfill(A),
    resetfill = fill,
) where {T2, F2}
    return LazyGBScalar{T2, F2}(fill; resetfill)
end
function Base.similar(
    A::LazyGBVector, ::Type{T2}, dims::Dims{1}; 
    fill::F2 = getfill(A),
    resetfill = fill,
) where {T2, F2}
    return LazyGBVector{T2, F2}(dims..., fill; resetfill)
end
function Base.similar(
    A::LazyGBVector, ::Type{T2}, dims::Dims{2}; 
    fill::F2 = getfill(A),
    resetfill = fill,
    order = SparseBase.RuntimeOrder(),
    materializeviews = true
) where {T2, F2}
    return LazyGBMatrix{T2, F2, order}(dims..., fill; materializeviews, resetfill)
end

function Base.similar(
    A::LazyGBMatrix, ::Type{T2}, dims::Dims{0}; 
    fill::F2 = getfill(A),
    resetfill = fill,
) where {T2, F2}
    return LazyGBScalar{T2, F2}(fill; resetfill)
end
function Base.similar(
    A::LazyGBMatrix, ::Type{T2}, dims::Dims{1}; 
    fill::F2 = getfill(A),
    resetfill = fill,
) where {T2, F2}
    return LazyGBVector{T2, F2}(dims..., fill; resetfill)
end
function Base.similar(
    A::LazyGBMatrix{T, F, O}, ::Type{T2}, dims::Dims{2}; 
    materializeviews = A.views.allowmaterialize,
    fill::F2 = getfill(A),
    resetfill = fill,
    order = O
) where {T, F, O, T2, F2}
    return LazyGBMatrix{T2, F2, order}(dims..., fill; materializeviews, resetfill)
end

# GB:
function Base.similar(
    A::GBScalar, ::Type{T2}, dims::Dims{0}; 
    fill::F2 = getfill(A),
    resetfill = fill,
) where {T2, F2}
    return GBScalar{T2, F2}(fill; resetfill)
end
function Base.similar(
    A::GBScalar, ::Type{T2}, dims::Dims{1}; 
    fill::F2 = getfill(A),
    resetfill = fill,
) where {T2, F2}
    return GBVector{T2, F2}(dims..., fill; resetfill)
end
function Base.similar(
    A::GBScalar, ::Type{T2}, dims::Dims{2}; 
    fill::F2 = getfill(A),
    resetfill = fill,
    order = SparseBase.RuntimeOrder(),
    materializeviews = true
) where {T2, F2}
    return GBMatrix{T2, F2, order}(dims..., fill; materializeviews, resetfill)
end

function Base.similar(
    A::GBVector, ::Type{T2}, dims::Dims{0}; 
    fill::F2 = getfill(A),
    resetfill = fill,
) where {T2, F2}
    return GBScalar{T2, F2}(fill; resetfill)
end
function Base.similar(
    A::GBVector, ::Type{T2}, dims::Dims{1}; 
    fill::F2 = getfill(A),
    resetfill = fill,
) where {T2, F2}
    return GBVector{T2, F2}(dims..., fill; resetfill)
end
function Base.similar(
    A::GBVector, ::Type{T2}, dims::Dims{2}; 
    fill::F2 = getfill(A),
    resetfill = fill,
    order = SparseBase.RuntimeOrder(),
    materializeviews = true
) where {T2, F2}
    return GBMatrix{T2, F2, order}(dims..., fill; materializeviews, resetfill)
end

function Base.similar(
    A::GBMatrix, ::Type{T2}, dims::Dims{0}; 
    fill::F2 = getfill(A),
    resetfill = fill,
) where {T2, F2}
    return GBVector{T2, F2}(fill; resetfill)
end
function Base.similar(
    A::GBMatrix, ::Type{T2}, dims::Dims{1}; 
    fill::F2 = getfill(A),
    resetfill = fill,
) where {T2, F2}
    return GBVector{T2, F2}(dims..., fill; resetfill)
end
function Base.similar(
    A::GBMatrix{T, F, O}, ::Type{T2}, dims::Dims{2}; 
    materializeviews = A.views.allowmaterialize,
    fill::F2 = getfill(A),
    resetfill = fill,
    order = O
) where {T, F, O, T2, F2}
    return GBMatrix{T2, F2, order}(dims..., fill; materializeviews, resetfill)
end

Base.IndexStyle(::AbstractGBArray) = IndexCartesian()
Base.size(A::AbstractLazyGBMatrix) = A.size
Base.size(A::AbstractGBMatrix) = size(A.A)
