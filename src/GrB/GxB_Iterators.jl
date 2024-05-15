# TODO: Make this file less loathsome.

# These iterators are only somewhat useful.
# The biggest issue is that we can't, at the moment, use one to change values in another.
# So in place map! is doable like this, as is just simply getting values.
# But if you wanted to say `C[I] = <transform>(A[I])` even with identical structures
# there's no method. Non-identical patterns are off the table entirely.

abstract type IndexIteratorType end
struct IndicesIterator <: IndexIteratorType end # return the indices as integers
struct NeighborIterator <: IndexIteratorType end # Used only for Vector iterators
struct NoIndexIterator <: IndexIteratorType end # Used when we don't want the indices, just the value
struct IteratorIterator <: IndexIteratorType end # return the iterator object itself. Spooky!
# just returns the free index, only useful for single column/row iterators.

abstract type AbstractGBIterator end

"""
    GxBIterator{Order, Eltype, AbstractGBArray}
"""
mutable struct GxBIterator{O, T, IterateValues, IterationType, G} # internal, don't subtype AbstractGBIterator
    p::Blobs.Blob{LibGraphBLAS.GB_Iterator_opaque}
    A::G
    function GxBIterator{IterateValues, IterationType}(A::G) where {T, IterateValues, IterationType, G<:AbstractGBArray{T}}
        #garbaage collection
        IterationType isa IndexIteratorType ||
            throw(ArgumentError("IterationType must be an IndexIteratorType."))
        IterateValues isa Bool ||
            throw(ArgumentError("IterateValues must be a Bool."))
        p = Ref{LibGraphBLAS.GxB_Iterator}()
        LibGraphBLAS.GxB_Iterator_new(p)
        I = _attach(
            finalizer(new{storageorder(A), T, IterateValues, IterationType, G}(
            Blobs.Blob{LibGraphBLAS.GB_Iterator_opaque}(
                Ptr{Nothing}(p[]), 0, sizeof(LibGraphBLAS.GB_Iterator_opaque)), 
            wait(A)
            )
            ) do I
                LibGraphBLAS.GxB_Iterator_free(
                    Ref(LibGraphBLAS.GxB_Iterator(getfield(I.p, :base)))
                )
            end
        )
        return I
    end
end
Base.unsafe_convert(::Type{LibGraphBLAS.GxB_Iterator}, I::GxBIterator) = 
    LibGraphBLAS.GxB_Iterator(getfield(I.p, :base))

function _attach(I::GxBIterator{O}; desc = nothing) where {O}
    desc = _handledescriptor(desc)
    if O === ColMajor()
        @wraperror LibGraphBLAS.GB_Iterator_attach(I, I.A, LibGraphBLAS.GxB_BY_COL, desc)
    else
        O === RowMajor()
        @wraperror LibGraphBLAS.GB_Iterator_attach(I, I.A, LibGraphBLAS.GxB_BY_ROW, desc)
    end
    return I
end

@inline function _seek(I::GxBIterator{SparseBase.RowMajor()}, row)
    return LibGraphBLAS.GB_Iterator_rc_seek(I, decrement(row), false)
end
@inline function _seek(I::GxBIterator{SparseBase.ColMajor()}, col)
    return LibGraphBLAS.GB_Iterator_rc_seek(I, decrement(col), false)
end

@inline function _kseek(I::GxBIterator{SparseBase.RowMajor()}, row)
    return LibGraphBLAS.GB_Iterator_rc_seek(I, decrement(row), true)
end
@inline function _kseek(I::GxBIterator{SparseBase.ColMajor()}, col)
    return LibGraphBLAS.GB_Iterator_rc_seek(I, decrement(col), true)
end

@inline function _kount(I::GxBIterator)
    return I.p.anvec[]
end

# column by column or row by row iterators:
@inline function _rc_knext(I::GxBIterator)
    k = I.p.k[] + 1
    anvec = I.p.anvec[]
    if k >= anvec
        I.p.pstart[] = 0
        I.p.pend[] = 0
        I.p.p[] = 0
        I.p.k[] = anvec
        return LibGraphBLAS.GxB_EXHAUSTED
    else
        if I.p.A_sparsity[] <= Int(LibGraphBLAS.GxB_SPARSE)
            I.p.pstart[] = unsafe_load(I.p.Ap[], k)
            I.p.pend[] = unsafe_load(I.p.Ap[], k + 1)
            I.p.p[] = I.p.pstart[]
            return I.p.p[] >= I.p.pend[] ? LibGraphBLAS.GrB_NO_VALUE : LibGraphBLAS.GrB_SUCCESS
        else
            avlen = I.p.avlen[]
            I.p.pstart[] = I.p.pstart[] + avlen
            I.p.pend[] = I.p.pend[] + avlen
            I.p.p[] = I.p.pstart[]
            if I.p.A_sparsity[] <= Int(LibGraphBLAS.GxB_BITMAP)
                return LibGraphBLAS.GB_Iterator_rc_bitmap_next(I)
            else
                return I.p.p[] >= I.p.pend[] ? LibGraphBLAS.GrB_NO_VALUE : LibGraphBLAS.GrB_SUCCESS
            end
        end
    end
end

@inline function _rc_inext(I::GxBIterator)
    p = I.p.p[]
    I.p.p[] = p + 1
    if p + 1 >= I.p.pend[]
        return LibGraphBLAS.GrB_NO_VALUE
    else
        if I.p.A_sparsity[] == LibGraphBLAS.GxB_BITMAP
            return LibGraphBLAS.GB_Iterator_rc_bitmap_next(I)
        else
            return LibGraphBLAS.GrB_SUCCESS
        end
    end
end

@inline function _rc_getj(I::GxBIterator)
    k = I.p.k[]
    return k >= I.p.anvec[] ? 
        I.p.avdim[] : 
        I.p.A_sparsity[] == LibGraphBLAS.GxB_HYPERSPARSE ?
            unsafe_load(I.p.Ah[], k) :
            k
end

@inline function _rc_geti(I::GxBIterator)
    return I.p.Ai[] != C_NULL ?
        unsafe_load(I.p.Ai[], I.p.p[]) : I.p.p[] - I.p.pstart[]
end

@inline nextrow(I::GxBIterator{RowMajor()}) = _rc_knext(I)
@inline nextcol(I::GxBIterator{RowMajor()}) = _rc_inext(I)

@inline getrow(I::GxBIterator{RowMajor()}) = increment(_rc_getj(I))
@inline getcol(I::GxBIterator{RowMajor()}) = increment(_rc_geti(I))

@inline nextcol(I::GxBIterator{ColMajor()}) = _rc_knext(I)
@inline nextrow(I::GxBIterator{ColMajor()}) = _rc_inext(I)

@inline getcol(I::GxBIterator{ColMajor()}) = increment(_rc_getj(I))
@inline getrow(I::GxBIterator{ColMajor()}) = increment(_rc_geti(I))

@inline function getval(I::GxBIterator{<:Any, T}) where T
    return unsafe_load(Ptr{T}(I.p.Ax[]), I.p.iso[] ? 1 : I.p.p[] + 1)
end

@inline function setval(I::GxBIterator{<:Any, T}, x::T) where T
    I.p.iso[] && throw(ArgumentError("Cannot set value of iso valued matrix using iterator."))
    unsafe_store!(Ptr{T}(I.p.Ax[]), x, I.p.p[] + 1)
end

# TODO: Inelegant
@inline get_element(I::GxBIterator{<:Any, <:Any, true, IndicesIterator()}) = ((getrow(I), getcol(I)), getval(I))
@inline get_element(I::GxBIterator{<:Any, <:Any, false, IndicesIterator()}) = (getrow(I), getcol(I))
@inline get_element(I::GxBIterator{<:Any, <:Any, true, NeighborIterator()}) = (increment(_rc_geti(I)), getval(I))
@inline get_element(I::GxBIterator{<:Any, <:Any, false, NeighborIterator()}) = increment(_rc_geti(I))
@inline get_element(I::GxBIterator{<:Any, <:Any, true, NoIndexIterator()}) = getval(I)
@inline get_element(::GxBIterator{<:Any, <:Any, false, NoIndexIterator()}) = throw(ArgumentError("Must iterate over either indices or values."))
@inline get_element(I::GxBIterator{<:Any, <:Any, <:Any, IteratorIterator()}) = I


struct VectorIterator{B, O, T, IterateValues, IterationType, I<:GxBIterator}
    iterator::I
    v::B # vector(s) to iterate over, column of CSC or row of CSR
    function VectorIterator(iterator::I, v::B) where 
        {
            B<:Union{Integer, UnitRange}, O, T, IterateValues, IterationType, 
            G<:AbstractGBArray, I<:GxBIterator{O, T, IterateValues, IterationType, G}
        }
        B <: Integer && (v = convert(Int64, v))
        B <: UnitRange && (v = convert(UnitRange{Int64}, v))
        (B <: UnitRange && IterationType === NeighborIterator() && v.start != v.stop) &&
            throw(ArgumentError("Cannot use NeighborIterator() with more than one vector."))
        new{B, O, T, IterateValues, IterationType, I}(iterator, v)
    end
end
function VectorIterator{IterateValues, IterationType}(A::AbstractGBArray{T}, v) where 
        {T, IterateValues, IterationType}
    @boundscheck SparseBase.storageorder(A) === RowMajor() ? checkbounds(A, v, :) : checkbounds(A, :, v)
    I = GxBIterator{IterateValues, IterationType}(A)
    return VectorIterator(I, v)
end


@inline function knext(I::VectorIterator{UnitRange{Int64}})
    V = I
    I = V.iterator
    k = I.p.k[] + 1
    I.p.k[] = k
    anvec = I.p.anvec[]
    if k >= anvec || k > (V.v.stop - 1)
        I.p.pstart[] = 0
        I.p.pend[] = 0
        I.p.p[] = typemax(Int64) - 10 # Hmm is this correct? We don't want this iterator to be reused.
        I.p.k[] = anvec
        return nothing
    else
        if I.p.A_sparsity[] <= Int(LibGraphBLAS.GxB_SPARSE)
            I.p.pstart[] = unsafe_load(I.p.Ap[], k)
            I.p.pend[] = unsafe_load(I.p.Ap[], k + 1)
            I.p.p[] = I.p.pstart[]
            return I.p.p[] >= I.p.pend[] ?  knext(V) : (get_element(I), nothing)
        else
            avlen = I.p.avlen[]
            I.p.pstart[] = I.p.pstart[] + avlen
            I.p.pend[] = I.p.pend[] + avlen
            I.p.p[] = I.p.pstart[]
            if I.p.A_sparsity[] <= Int(LibGraphBLAS.GxB_BITMAP)
                return LibGraphBLAS.GB_Iterator_rc_bitmap_next(I) == LibGraphBLAS.GrB_SUCCESS ?
                    (get_element(I), nothing) : knext(V)
            else
                return I.p.p[] >= I.p.pend[] ? knext(V) : (get_element(I), nothing)
            end
        end
    end
end
@inline knext(::VectorIterator{Int64}) = nothing

@inline function inext(I::VectorIterator)
    p = I.iterator.p.p[]
    I.iterator.p.p[] = p + 1
    if p + 1 >= I.iterator.p.pend[]
        return knext(I)
    else
        if I.iterator.p.A_sparsity[] == LibGraphBLAS.GxB_BITMAP
            result = LibGraphBLAS.GB_Iterator_rc_bitmap_next(I.iterator)
            if result == LibGraphBLAS.GrB_SUCCESS
                return get_element(I), nothing
            else
                return knext(I)
            end
        else
            return get_element(I), nothing
        end
    end
end

get_element(I::VectorIterator) = get_element(I.iterator)
get_element(I::VectorIterator{<:Any, <:Any, <:Any, <:Any, IteratorIterator()}) = I

const RowIterator{B, T, IterateValues, IterationType} = VectorIterator{B, RowMajor(), T, IterateValues, IterationType}
const ColIterator{B, T, IterateValues, IterationType} = VectorIterator{B, ColMajor(), T, IterateValues, IterationType}

defaultiteration(::Integer) = NeighborIterator()
defaultiteration(::AbstractVector) = IndicesIterator()

RowIterator(A::AbstractGBArray, v, iteratevalues::Bool, indexiteration::IndexIteratorType = NeighborIterator()) =
    storageorder(A) === RowMajor() ? VectorIterator{iteratevalues, indexiteration}(A, v) : 
    throw(ArgumentError("A is not in RowMajor() order. Row iteration is only supported on RowMajor AbstractGBArrays. Try setstorageorder[!]"))
ColIterator(A::AbstractGBArray, v, iteratevalues::Bool, indexiteration::IndexIteratorType = NeighborIterator()) =
    storageorder(A) === ColMajor() ? VectorIterator{iteratevalues, indexiteration}(A, v) : 
    throw(ArgumentError("A is not in ColMajor() order. Col iteration is only supported on ColMajor AbstractGBArrays. Try setstorageorder[!]"))

RowIterator(A::AbstractGBArray, v, indexiteration::IndexIteratorType = NeighborIterator()) = RowIterator(A, v, true, indexiteration)
ColIterator(A::AbstractGBArray, v, indexiteration::IndexIteratorType = NeighborIterator()) = ColIterator(A, v, true, indexiteration)

iteratecols(A::AbstractGBArray, v, iteratevalues::Bool, indexiteration::IndexIteratorType = NeighborIterator()) =
    ColIterator(A, v, iteratevalues, indexiteration)
iteratecols(A::AbstractGBArray, v, indexiteration::IndexIteratorType = NeighborIterator()) =
    ColIterator(A, v, indexiteration)

iteraterows(A::AbstractGBArray, v, iteratevalues::Bool, indexiteration::IndexIteratorType = NeighborIterator()) =
    RowIterator(A, v, iteratevalues, indexiteration)
iteraterows(A::AbstractGBArray, v, indexiteration::IndexIteratorType = NeighborIterator()) =
    RowIterator(A, v, indexiteration)

function Base.iterate(I::VectorIterator)
    return _seek(I.iterator, I.v isa Int64 ? I.v : I.v.start) == LibGraphBLAS.GrB_NO_VALUE ? knext(I) : (get_element(I), nothing)
end
Base.iterate(I::VectorIterator, ::Nothing) = inext(I)

Base.getindex(A::AbstractArray, I::GxBIterator) = getindex(A, getrow(I), getcol(I))
Base.getindex(A::AbstractArray, v::VectorIterator) = getindex(A, v.iterator)
Base.setindex!(A::AbstractArray, x, I::GxBIterator) = setindex!(A, x, getrow(I), getcol(I))
Base.setindex!(A::AbstractArray, x, v::VectorIterator) = setindex!(A, x, v.iterator)
