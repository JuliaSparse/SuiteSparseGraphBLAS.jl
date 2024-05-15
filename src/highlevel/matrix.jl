# Shape / type based constructors:
function EagerGBMatrix{T, F, O}(nrows, ncols, fill=defaultfill(F); materializeviews=true, resetfill=fill) where {T, F, O}
    A = GrB.Matrix{T}(nrows, ncols; storageorders=O)
    views = MaterializedViews{T}(materializeviews, nothing, nothing)
    return EagerGBMatrix{T, F, O}(A, views, convert(F, fill), resetfill)
end
function EagerGBMatrix{T, F}(nrows, ncols, fill=defaultfill(F); materializeviews=true, resetfill=fill) where {T, F}
    return EagerGBMatrix{T, F, SparseBase.RuntimeOrder()}(nrows, ncols, convert(F, fill); materializeviews, resetfill)
end
function EagerGBMatrix{T}(nrows, ncols, fill::F = defaultfill(T); materializeviews=true, resetfill=fill) where {T, F}
    return EagerGBMatrix{T, F, SparseBase.RuntimeOrder()}(nrows, ncols, fill; materializeviews, resetfill)
end

# TODO: Can we do better here? This is a lot of busy work... 
# unfortunately having the order be the last argument makes it hard to do better.
function EagerGBMatrixC{T, F}(nrows, ncols, fill=defaultfill(F); materializeviews=true, resetfill=fill) where {T, F}
    return EagerGBMatrix{T, F, SparseBase.ColMajor()}(nrows, ncols, convert(F, fill); materializeviews, resetfill)
end
function EagerGBMatrixR{T, F}(nrows, ncols, fill=defaultfill(F); materializeviews=true, resetfill=fill) where {T, F}
    return EagerGBMatrix{T, F, SparseBase.RowMajor()}(nrows, ncols, convert(F, fill); materializeviews, resetfill)
end
function EagerGBMatrixC{T}(nrows, ncols, fill::F = defaultfill(T); materializeviews=true, resetfill=fill) where {T, F}
    return EagerGBMatrix{T, F, SparseBase.ColMajor()}(nrows, ncols, fill; materializeviews, resetfill)
end
function EagerGBMatrixR{T}(nrows, ncols, fill::F = defaultfill(T); materializeviews=true, resetfill=fill) where {T, F}
    return EagerGBMatrix{T, F, SparseBase.RowMajor()}(nrows, ncols, fill; materializeviews, resetfill)
end

function LazyGBMatrix{T, F, O}(nrows, ncols, fill=defaultfill(F); materializeviews=true, resetfill=fill) where {T, F, O}
    views = MaterializedViews{T}(materializeviews, nothing, nothing)
    return LazyGBMatrix{T, F, O}(nothing, (nrows, ncols), views, convert(F, fill), resetfill)
end
function LazyGBMatrix{T, F}(nrows, ncols, fill=defaultfill(F); materializeviews=true, resetfill=fill) where {T, F}
    return LazyGBMatrix{T, F, SparseBase.RuntimeOrder()}(nrows, ncols, convert(F, fill); materializeviews, resetfill)
end
function LazyGBMatrix{T}(nrows, ncols, fill::F = defaultfill(T); materializeviews=true, resetfill=fill) where {T, F}
    return LazyGBMatrix{T, F, SparseBase.RuntimeOrder()}(nrows, ncols, fill; materializeviews, resetfill)
end

# TODO: Can we do better here? This is a lot of busy work... 
# unfortunately having the order be the last argument makes it hard to do better.
function LazyGBMatrixC{T, F}(nrows, ncols, fill=defaultfill(F); materializeviews=true, resetfill=fill) where {T, F}
    return LazyGBMatrix{T, F, SparseBase.ColMajor()}(nrows, ncols, convert(F, fill); materializeviews, resetfill)
end
function LazyGBMatrixR{T, F}(nrows, ncols, fill=defaultfill(F); materializeviews=true, resetfill=fill) where {T, F}
    return LazyGBMatrix{T, F, SparseBase.RowMajor()}(nrows, ncols, convert(F, fill); materializeviews, resetfill)
end
function LazyGBMatrixC{T}(nrows, ncols, fill::F = defaultfill(T); materializeviews=true, resetfill=fill) where {T, F}
    return LazyGBMatrix{T, F, SparseBase.ColMajor()}(nrows, ncols, fill; materializeviews, resetfill)
end
function LazyGBMatrixR{T}(nrows, ncols, fill::F = defaultfill(T); materializeviews=true, resetfill=fill) where {T, F}
    return LazyGBMatrix{T, F, SparseBase.RowMajor()}(nrows, ncols, fill; materializeviews, resetfill)
end

function GBMatrix{T, F, O}(nrows, ncols, fill=defaultfill(F); materializeviews=true, resetfill=fill) where {T, F, O}
    views = MaterializedViews{T}(materializeviews, nothing, nothing)
    return GBMatrix{T, F, O}(nothing, (nrows, ncols), views, convert(F, fill), resetfill, WeakKeyDict{Any, Bool}())
end
function GBMatrix{T, F}(nrows, ncols, fill=defaultfill(F); materializeviews=true, resetfill=fill) where {T, F}
    return GBMatrix{T, F, SparseBase.RuntimeOrder()}(nrows, ncols, convert(F, fill); materializeviews, resetfill)
end
function GBMatrix{T}(nrows, ncols, fill::F = defaultfill(T); materializeviews=true, resetfill=fill) where {T, F}
    return GBMatrix{T, F, SparseBase.RuntimeOrder()}(nrows, ncols, fill; materializeviews, resetfill)
end

# TODO: Can we do better here? This is a lot of busy work... 
# unfortunately having the order be the last argument makes it hard to do better.
function GBMatrixC{T, F}(nrows, ncols, fill=defaultfill(F); materializeviews=true, resetfill=fill) where {T, F}
    return GBMatrix{T, F, SparseBase.ColMajor()}(nrows, ncols, convert(F, fill); materializeviews, resetfill)
end
function GBMatrixR{T, F}(nrows, ncols, fill=defaultfill(F); materializeviews=true, resetfill=fill) where {T, F}
    return GBMatrix{T, F, SparseBase.RowMajor()}(nrows, ncols, convert(F, fill); materializeviews, resetfill)
end
function GBMatrixC{T}(nrows, ncols, fill::F = defaultfill(T); materializeviews=true, resetfill=fill) where {T, F}
    return GBMatrix{T, F, SparseBase.ColMajor()}(nrows, ncols, fill; materializeviews, resetfill)
end
function GBMatrixR{T}(nrows, ncols, fill::F = defaultfill(T); materializeviews=true, resetfill=fill) where {T, F}
    return GBMatrix{T, F, SparseBase.RowMajor()}(nrows, ncols, fill; materializeviews, resetfill)
end
