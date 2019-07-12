module Interface

using GraphBLASInterface, SuiteSparseGraphBLAS

import Base:
    getindex, setindex!, empty!, copy, size, adjoint, ==

import SuiteSparseGraphBLAS:
        GrB_Matrix, GrB_Vector, GrB_Descriptor

include("Utils.jl")
include("./Object_Methods/Matrix_Methods.jl")
include("./Object_Methods/Vector_Methods.jl")
include("./Object_Methods/Descriptor_Methods.jl")
export findnz, nnz, LowerTriangular, UpperTriangular, Diagonal, dropzeros!

end # end of module
