# Shape / type based constructors:
function EagerGBVector{T, F}(n, fill=defaultfill(F); resetfill=fill) where {T, F}
    A = GrB.Matrix{T}(n, 1)
    return EagerGBVector{T, F}(A, convert(F, fill), convert(F, resetfill))
end
function EagerGBVector{T}(n, fill::F = defaultfill(T); resetfill=fill) where {T, F}
    return EagerGBVector{T, F}(n, fill; resetfill)
end

function LazyGBVector{T, F}(n, fill=defaultfill(F); resetfill=fill) where {T, F}
    return LazyGBVector{T, F}(nothing, (n,), convert(F, fill), resetfill)
end
function LazyGBVector{T}(n, fill::F = defaultfill(T); resetfill=fill) where {T, F}
    return LazyGBVector{T, F}(n, fill; resetfill)
end

function GBVector{T, F}(n, fill=defaultfill(F); resetfill=fill) where {T, F}
    return GBVector{T, F}(nothing, (n,), convert(F, fill), convert(F, resetfill), WeakKeyDict{Any, Bool}())
end
function GBVector{T}(n, fill::F = defaultfill(T); resetfill=fill) where {T, F}
    return GBVector{T, F}(n, fill; resetfill)
end
