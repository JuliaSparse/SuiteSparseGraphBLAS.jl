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
