# TODO: FIXME
# function LinearAlgebra.diagm(v::GBVector, k::Integer=0; desc = nothing)
#     return Diagonal(v, k; desc)
# end

# Indexing functions
####################

# Linear indexing
function Base.getindex(A::GBMatrixOrTranspose, v::AbstractVector)
    throw("Not implemented")
end

# Pack based constructors:
function GBMatrix{T, F}(
    A::SparseVector; 
    fill = defaultfill(F)
) where {T, F}
    C = GBMatrix{T, F}(size(A, 1), 1; fill)
    return unsafepack!(C, _copytoraw(A)..., false)
end
GBMatrix{T}(
    A::SparseVector; 
    fill::F = defaultfill(T)
) where {T, F} = GBMatrix{T, F}(A; fill)
GBMatrix(
    A::SparseVector{T}; 
    fill::F = defaultfill(T)
) where {T, F} = GBMatrix{T, F}(A; fill)

function GBMatrix{T, F}(
    A::SparseMatrixCSC; 
    fill = defaultfill(F)
) where {T, F}
    C = GBMatrix{T, F}(size(A)...; fill)
    return unsafepack!(C, _copytoraw(A)..., false)
end
GBMatrix{T}(
    A::SparseMatrixCSC; 
    fill::F = defaultfill(T)
) where {T, F} = GBMatrix{T, F}(A; fill)
GBMatrix(
    A::SparseMatrixCSC{T}; 
    fill::F = defaultfill(T)
) where {T, F} = GBMatrix{T, F}(A; fill)