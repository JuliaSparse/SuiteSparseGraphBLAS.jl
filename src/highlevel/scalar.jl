# Shape / type based constructors:
function EagerGBScalar{T, F}(fill=defaultfill(F); resetfill=fill) where {T, F}
    A = GrB.Scalar{T}()
    return EagerGBScalar{T, F}(A, convert(F, fill), convert(F, resetfill))
end
function EagerGBScalar{T}(fill::F = defaultfill(T); resetfill=fill) where {T, F}
    return EagerGBScalar{T, F}(fill; resetfill)
end

function LazyGBScalar{T, F}(fill=defaultfill(F); resetfill=fill) where {T, F}
    return LazyGBScalar{T, F}(nothing, convert(F, fill), convert(F, resetfill))
end
function LazyGBScalar{T}(fill::F = defaultfill(T); resetfill=fill) where {T, F}
    return LazyGBScalar{T, F}(fill; resetfill)
end

function GBScalar{T, F}(fill=defaultfill(F); resetfill=fill) where {T, F}
    return GBScalar{T, F}(nothing, convert(F, fill), convert(F, resetfill), WeakKeyDict{Any, Bool}())
end
function GBScalar{T}(fill::F = defaultfill(T); resetfill=fill) where {T, F}
    return GBScalar{T, F}(fill; resetfill)
end

