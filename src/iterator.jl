mutable struct GxBIterator{O, T, G<:AbstractGBArray{T}}
    p::Blobs.Blob{LibGraphBLAS.GB_Iterator_opaque}
    A::G
    function GxBIterator(A::G) where {T, G<:AbstractGBArray{T}}
        #garbaage collection
        p = Ref{LibGraphBLAS.GxB_Iterator}()
        LibGraphBLAS.GxB_Iterator_new(p)
        return _attach(
            finalizer(new{storageorder(A), T, G}(
            Blobs.Blob{LibGraphBLAS.GB_Iterator_opaque}(
                Ptr{Nothing}(p[]), 0, sizeof(LibGraphBLAS.GB_Iterator_opaque)), 
            A
            )
            ) do I
                LibGraphBLAS.GxB_Iterator_free(
                    Ref(LibGraphBLAS.GxB_Iterator(getfield(I.p, :base)))
                )
            end
        )
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

@inline function _seek(I::GxBIterator{StorageOrders.RowMajor()}, row)
    return LibGraphBLAS.GB_Iterator_rc_seek(I, decrement(row), false)
end
@inline function _seek(I::GxBIterator{StorageOrders.ColMajor()}, col)
    return LibGraphBLAS.GB_Iterator_rc_seek(I, decrement(col), false)
end

function _kseek(I::GxBIterator{StorageOrders.RowMajor()}, row)
    return LibGraphBLAS.GB_Iterator_rc_seek(I, decrement(row), true)
end
function _kseek(I::GxBIterator{StorageOrders.ColMajor()}, col)
    return LibGraphBLAS.GB_Iterator_rc_seek(I, decrement(col), true)
end

function _kount(I::GxBIterator)
    return I.p.anvec[]
end

function _rc_knext(I::GxBIterator)
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

function _rc_inext(I::GxBIterator)
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

function _rc_getj(I::GxBIterator)
    k = I.p.k[]
    return k >= I.p.anvec[] ? 
        I.p.avdim[] : 
        I.p.A_sparsity[] == LibGraphBLAS.GxB_HYPERSPARSE ?
            unsafe_load(I.p.Ah[], k) :
            k
end

function _rc_geti(I::GxBIterator)
    return I.p.Ai[] != C_NULL ?
        unsafe_load(I.p.Ai[], i.p.p[]) : I.p.p[] - I.p.pstart[]
end

nextrow(I::GxBIterator{RowMajor()}) = _rc_knext(I)
nextcol(I::GxBIterator{RowMajor()}) = _rc_inext(I)

getrow(I::GxBIterator{RowMajor()}) = _rc_getj(I) + 1
getcol(I::GxBIterator{RowMajor()}) = _rc_geti(I) + 1

nextcol(I::GxBIterator{ColMajor()}) = _rc_knext(I)
nextrow(I::GxBIterator{ColMajor()}) = _rc_inext(I)

getcol(I::GxBIterator{ColMajor()}) = _rc_getj(I) + 1
getrow(I::GxBIterator{ColMajor()}) = _rc_geti(I) + 1

function getval(I::GxBIterator{<:Any, T}) where T
    return unsafe_load(Ptr{T}(I.p.Ax[]), I.p.iso[] ? 1 : I.p.p[] + 1)
end

get_tuple(I::GxBIterator) = (getrow(I), getcol(I), getval(I))