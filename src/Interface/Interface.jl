module Interface

using SuiteSparseGraphBLAS

import Base:
    getindex, setindex!, empty!, copy, size, adjoint, ==

import SuiteSparseGraphBLAS:
    GrB_Info, GrB_Index, GrB_Matrix, GrB_Vector, GrB_Descriptor, GrB_Desc_Field, GrB_Desc_Value,
    valid_types, get_GrB_Type, default_dup, equal_op

include("./Object_Methods/Matrix_Methods.jl")
include("./Object_Methods/Vector_Methods.jl")
include("./Object_Methods/Descriptor_Methods.jl")
export findnz, nnz, LowerTriangular, UpperTriangular, Diagonal

end # end of module
