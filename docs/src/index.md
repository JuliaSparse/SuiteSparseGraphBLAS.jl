# SuiteSparseGraphBLAS.jl

SuiteSparseGraphBLAS.jl is a WIP package for sparse linear algebra on arbitrary semirings, with a particular focus on graph computations.
It is a wrapper over the Tim Davis' SuiteSparse reference implementation of the GraphBLAS C API, although it aims to expose a Julian interface to the user.

While the core library is mostly complete, and all GraphBLAS functionality is present, there are still quite a few features being worked on:

1. ChainRules.jl integration for AD.
2. Complete SparseArrays and ArrayInterface interfaces.
3. Import and Export in all formats including bitmap and csr. Currently only dense and csc are supported.
4. Printing v2.
5. User-defined types and functions.
6. Alternative syntax for GraphBLAS ops (currently must use `BinaryOps.PLUS` instead of `+`).
7. Complex builtins.

Once these are completed there will be a v1.0 release, with the goal being JuliaCon 2021.

# Introduction