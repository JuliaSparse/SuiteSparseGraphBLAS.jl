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

function Base.convert(::Type{M}, A::N; fill::F = getfill(A)) where {F, M<:AbstractGBArray, N<:AbstractGBArray}
    !(F <: Union{Nothing, Missing}) && (fill = convert(storedeltype(M), fill))
    B = M(size(A, 1), size(A, 2); fill)
    applyjl!(storedeltype(B), B, A)
end
function Base.convert(::Type{M}, A::N; fill::F = getfill(A)) where {F, M<:AbstractGBVector, N<:AbstractGBVector}
    !(F <: Union{Nothing, Missing}) && (fill = convert(eltype(M), fill))
    B = M(size(A, 1); fill)
    applyjl!(storedeltype(B), B, A)
end

Base.convert(::Type{M}, A::M; fill = nothing) where {M<:AbstractGBArray} = A

function LinearAlgebra.copy_oftype(A::GBArrayOrTranspose, ::Type{T}) where T
    order = storageorder(A)
    C = similar(A, T, size(A))
    applyjl!(T, C, A)
end
# TODO: Implement this? 
Base.convert(::Type{M}, ::AbstractGBArray; fill = nothing) where {M<:AbstractGBShallowArray} = 
    throw(ArgumentError("Cannot convert into a shallow array."))
