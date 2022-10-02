# First we'll just support element type conversions.
# This is crucial since we can't pass DataTypes to UDF handlers.

# pass through for most cases
conform(M::AbstractGBArray) = M

function Base.convert(::Type{M}, A::N; fill = getfill(A)) where {M<:AbstractGBArray, N<:AbstractGBArray}
    isabstracttype(M) && throw(ArgumentError("$M is an abstract type, which cannot be constructed."))
    sparsity = sparsitystatus(A)
    x = tempunpack_noformat!(A)
    repack! = x[end]
    values = x[end - 1]
    indices = x[begin:end-2]
    display(typeof.(indices))
    display(typeof(values))
    newvalues = unsafe_wrap(Array, _sizedjlmalloc(length(values), T), size(values))
    display(typeof(newvalues))
    copyto!(newvalues, values)
    newindices = _copytoraw.(indices)
    repack!()
    B = M(size(A); fill)
    unsafepack!(B, newindices..., newvalues, false)
    
end

Base.convert(::Type{M}, A::M; fill = nothing) where {M<:AbstractGBArray} = A

# TODO: Implement this? No strong reason not to? 
Base.convert(::Type{M}, ::AbstractGBArray; fill = nothing) where {M<:AbstractGBShallowArray} = 
    throw(ArgumentError("Cannot convert into a shallow array."))
