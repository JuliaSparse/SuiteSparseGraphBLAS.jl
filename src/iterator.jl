struct GBIterator{O}
    p::Base.RefValue{LibGraphBLAS.GxB_Iterator}
    A::AbstractGBArray
    function GBIterator(A::AbstractGBArray)
        #garbaage collection
        i = Ref{LibGraphBLAS.GxB_Iterator}()
        @wraperror LibGraphBLAS.GxB_Iterator_new(i)
        p = finalizer(iter) do ref
            @wraperror LibGraphBLAS.GxB_Iterator_free(ref)
        end
        return new{storageorder(A)}(p, A)
    end
end
gbpointer(I::GBIterator) = I.p[]

function _attach(I::GBIterator{O}, A::AbstractGBArray; desc = nothing) where {O}
    desc = _handledescriptor(desc)
    @wraperror LibGraphBLAS.GxB_Iterator_attach(gbpointer(I), gbpointer(A), desc)
end

