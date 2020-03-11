module Interface

using GraphBLASInterface, SuiteSparseGraphBLAS

import Base:
    getindex, setindex!, empty!, copy, size, adjoint, ==

import SuiteSparseGraphBLAS:
        GrB_Matrix, GrB_Vector, GrB_Descriptor

include("utils.jl")
include("./object_methods/matrix.jl")
include("./object_methods/vector.jl")
include("./object_methods/descriptor.jl")
export findnz, nnz, LowerTriangular, UpperTriangular, Diagonal, dropzeros!

end # end of module
