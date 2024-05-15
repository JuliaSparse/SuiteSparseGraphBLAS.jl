# Constructors:
###############

# Some Base and basic SparseArrays/LinearAlgebra functions:
###########################################################
Base.unsafe_convert(::Type{LibGraphBLAS.GrB_Matrix}, v::GBVector) = v.p[]

function Base.copy(A::GBVector{T}) where {T}
    C = _newGrBRef()
    @wraperror LibGraphBLAS.GrB_Matrix_dup(C, A)
    return GBVector{T}(C)
end

# Indexing functions:
#####################

