abstract type AbstractGBArray{T, F, O, N} <: SparseBase.AbstractSparseFormat{T, F, O, Int64, N} end
abstract type AbstractLazyGBArray{T, F, O, N} <: AbstractGBArray{T, F, O, N} end
const AbstractGBMatrix{T, F, O} = AbstractGBArray{T, F, O, 2}
const AbstractLazyGBMatrix{T, F, O} = AbstractLazyGBArray{T, F, O, 2}

# Should maybe be NoOrder()? Not sure
const AbstractGBVector{T, F} = AbstractGBArray{T, F, SparseBase.ColMajor(), 1}
const AbstractLazyGBVector{T, F} = AbstractLazyGBArray{T, F, SparseBase.ColMajor(), 1}

const AbstractGBScalar{T, F} = AbstractGBArray{T, F, StorageOrders.NoOrder(), 0}
const AbstractLazyGBScalar{T, F} = AbstractLazyGBArray{T, F, StorageOrders.NoOrder(), 0}

struct Operation{Operation}
    out::Any
    mask::Any
    accum::Any
    operation::Operation
    operator::Any
    inputs::Tuple
    metadata::NamedTuple
end

mutable struct MaterializedViews{T}
    allowmaterialize::Bool
    transpose::Union{Nothing, GrB.Matrix{T}}
    adjoint::Union{Nothing, GrB.Matrix{T}}
end

mutable struct EagerGBMatrix{T, F, O} <: AbstractGBMatrix{T, F, O}
    A::GrB.Matrix{T}
    views::MaterializedViews{T}
    fill::F
    resetfill::F # Should be the same as fill unless there's a "densifying op". 
                 # In which case this is needed for a deletion.
end
const EagerGBMatrixC{T, F} = EagerGBMatrix{T, F, SparseBase.ColMajor()}
const EagerGBMatrixR{T, F} = EagerGBMatrix{T, F, SparseBase.RowMajor()}

mutable struct LazyGBMatrix{T, F, O} <: AbstractLazyGBMatrix{T, F, O}
    A::Union{Nothing, GrB.Matrix{T}}
    const size::Dims{2}
    op::Union{Nothing, Operation}
    views::MaterializedViews{T}
    fill::F
    resetfill::F # should be the same as fill unless there's a full materalization followed by a deletion.
end
const LazyGBMatrixC{T, F} = LazyGBMatrix{T, F, SparseBase.ColMajor()}
const LazyGBMatrixR{T, F} = LazyGBMatrix{T, F, SparseBase.RowMajor()}

mutable struct GBMatrix{T, F, O} <: AbstractLazyGBMatrix{T, F, O}
    A::Union{Nothing, GrB.Matrix{T}}
    const size::Dims{2}
    op::Union{Nothing, Operation}
    views::MaterializedViews{T}
    fill::F
    resetfill::F # should be the same as fill unless there's a full materalization followed by a deletion.
    consumers::WeakKeyDict{Any, Bool} # To safely push forward before changes.
end
const GBMatrixC{T, F} = GBMatrix{T, F, SparseBase.ColMajor()}
const GBMatrixR{T, F} = GBMatrix{T, F, SparseBase.RowMajor()}

mutable struct EagerGBVector{T, F} <: AbstractGBVector{T, F}
    A::GrB.Matrix{T}
    fill::F
    resetfill::F # Should be the same as fill unless there's a "densifying op". 
                 # In which case this is needed for a deletion.
end

mutable struct LazyGBVector{T, F} <: AbstractLazyGBVector{T, F}
    A::Union{Nothing, GrB.Matrix{T}}
    const size::Dims{1}
    op::Union{Nothing, Operation}
    fill::F
    resetfill::F # Should be the same as fill unless there's a "densifying op". 
                 # In which case this is needed for a deletion.
end

mutable struct GBVector{T, F} <: AbstractLazyGBVector{T, F}
    A::Union{Nothing, GrB.Matrix{T}}
    const size::Dims{1}
    op::Union{Nothing, Operation}
    fill::F
    resetfill::F # Should be the same as fill unless there's a "densifying op". 
                 # In which case this is needed for a deletion.
    consumers::WeakKeyDict{Any, Bool} # To safely push forward before changes.
end

mutable struct EagerGBScalar{T, F} <: AbstractGBScalar{T, F}
    A::GrB.Scalar{T}
    fill::F
    resetfill::F # Should be the same as fill unless there's a "densifying op". 
                 # In which case this is needed for a deletion.
end

mutable struct LazyGBScalar{T, F} <: AbstractLazyGBVector{T, F}
    A::Union{Nothing, GrB.Scalar{T}}
    op::Union{Nothing, Operation}
    fill::F
    resetfill::F # Should be the same as fill unless there's a "densifying op". 
                 # In which case this is needed for a deletion.
end

mutable struct GBScalar{T, F} <: AbstractLazyGBScalar{T, F}
    A::Union{Nothing, GrB.Scalar{T}}
    op::Union{Nothing, Operation}
    fill::F
    resetfill::F # Should be the same as fill unless there's a "densifying op". 
                 # In which case this is needed for a deletion.
    consumers::WeakKeyDict{Any, Bool} # To safely push forward before changes.
end
