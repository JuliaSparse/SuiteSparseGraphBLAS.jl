# Constructors:
###############

# Some Base and basic SparseArrays/LinearAlgebra functions:
###########################################################
Base.unsafe_convert(::Type{LibGraphBLAS.GrB_Matrix}, v::GBVector) = v.p[]

function Base.copy(A::GBVector{T, F}) where {T, F}
    C = Ref{LibGraphBLAS.GrB_Matrix}()
    LibGraphBLAS.GrB_Matrix_dup(C, A)
    return GBVector{T, F}(C, A.fill)
end

# Indexing functions:
#####################

