# First we'll just support element type conversions.
# This is crucial since we can't pass DataTypes to UDF handlers.

function applyjl!(F, C::AbstractGBArray, A::AbstractGBArray)
    isabstracttype(F) && throw(ArgumentError("$M is an abstract type, which cannot be constructed."))
    x = tempunpack!(A)
    repack! = x[end]
    values = x[end - 1]
    indices = x[begin:end-2]
    newvalues = unsafe_wrap(Array, _sizedjlmalloc(length(values), storedeltype(C)), size(values))
    map!(F, newvalues, values)
    newindices = _copytoraw.(indices)
    repack!()
    unsafepack!(C, newindices..., newvalues, false; decrementindices = false, order = storageorder(A))
    return C
end

function Base.convert(::Type{M}, A::N) where {M<:AbstractGBArray, N<:AbstractGBArray}
    B = M(size(A, 1), size(A, 2))
    applyjl!(storedeltype(B), B, A)
end
function Base.convert(::Type{M}, A::N) where {M<:AbstractGBVector, N<:AbstractGBVector}
    B = M(size(A, 1))
    applyjl!(storedeltype(B), B, A)
end

Base.convert(::Type{M}, A::M) where {M<:AbstractGBArray} = A

function LinearAlgebra.copy_oftype(A::GBArrayOrTranspose, ::Type{T}) where T
    if storedeltype(A) == T
        return copy(A)
    end
    C = similar(A, T, size(parent(A)))
    applyjl!(T, C, parent(A))
    return A isa Transpose ? copy(transpose(C)) : C # gross double copy. TODO: FIX
end
# TODO: Implement this? 
Base.convert(::Type{M}, ::AbstractGBArray) where {M<:AbstractGBShallowArray} = 
    throw(ArgumentError("Cannot convert into a shallow array."))
