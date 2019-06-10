using SuiteSparseGraphBLAS
using Test

@test GrB_init(GrB_NONBLOCKING) == GrB_SUCCESS
