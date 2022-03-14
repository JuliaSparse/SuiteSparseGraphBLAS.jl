struct GBIterator{O}
    p::Ref{LibGraphBLAS.GxB_Iterator}
end
gbpointer(I::GBIterator) = I.p[]

function GBIterator(bycol=true) # this should be removed eventually. We always want an attached one.
    i = Ref{LibGraphBLAS.GxB_Iterator}()
    @wraperror LibGraphBLAS.GxB_Iterator_new(i)
    return GBIterator{}(finalizer(iter) do ref
        @wraperror LibGraphBLAS.GxB_Iterator_free(ref)
    end)
end

function attach(I::GBIterator, A::AbstractGBArray; desc = nothing, itercolumns)
    desc = _handledescriptor(desc)
    @wraperror LibGraphBLAS.GxB_Iterator_attach(gbpointer(I), gbpointer(A), desc)
end

