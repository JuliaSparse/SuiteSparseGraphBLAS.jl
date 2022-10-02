# Constructors:
###############

# Empty constructors:
# TODO: match above, FIXME
function GBMatrix(v::GBVector{T, F}) where {T, F}
    # this copies, I think that's ideal, and I can implement @view or something at a later date.
    return copy(GBMatrix{T, F}(v.p, v.fill)) 
end

# Some Base and basic SparseArrays/LinearAlgebra functions:
###########################################################

function Base.copy(A::GBMatrix{T, F}) where {T, F}
    return GBMatrix{T, F}(_copyGrBMat(A.p), A.fill)
end

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
