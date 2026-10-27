import ..libgraphblas

NULL = C_NULL
INT64_MAX = typemax(Int64)

# Clang.jl maps both C complex types to ComplexF32
const GxB_FC64_t = ComplexF64
const GxB_FC32_t = ComplexF32
