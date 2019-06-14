module Interface

using SuiteSparseGraphBLAS

import Base:
    getindex, setindex!, empty!, copy, size

import SuiteSparseGraphBLAS:
    GrB_Info, GrB_Index, GrB_Matrix, valid_types, get_GrB_Type, default_dup

include("./Object_Methods/Matrix_Methods.jl")
export findnz, nnz

end # end of module