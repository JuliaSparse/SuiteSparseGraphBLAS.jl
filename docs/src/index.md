# SuiteSparseGraphBLAS.jl

SuiteSparseGraphBLAS.jl is a WIP package for sparse linear algebra on arbitrary semirings, with a particular focus on graph computations.
It is a wrapper over the Tim Davis' SuiteSparse reference implementation of the GraphBLAS C API, although it aims to expose a Julian interface to the user.

# Roadmap

While the core library is mostly complete, and all GraphBLAS functionality is present, there are still quite a few features being worked on for v1.0:

1. ChainRules.jl integration for AD.
2. Complete SparseArrays and ArrayInterface interfaces.
3. Import and Export in all formats including bitmap and csr. Currently only dense and csc are supported.
4. Printing v2.
5. User-defined types and functions.
6. Alternative syntax for GraphBLAS ops (currently must use `BinaryOps.PLUS` instead of `+`).
7. Complex builtins.

Once these are completed there will be a v1.0 release, with the goal being JuliaCon 2021.

Post 1.0 goals include:

1. LightGraphs integration.
2. GeometricFlux or other graph machine learning framework integration.
3. More efficient import and export between Julia and GraphBLAS
4. Support for other GraphBLAS implementations in a follow-up GraphBLAS.jl

# Installation

Install using the Julia package manager in the REPL:

```
] add SuiteSparseGraphBLAS#master
```

or with `Pkg`

```
using Pkg
Pkg.add("SuiteSparseGraphBLAS")
```

The SuiteSparse:GraphBLAS binary is installed automatically as `SSGraphBLAS_jll`.

# Introduction

GraphBLAS harnesses the well-understood duality between graphs and matrices. Specifically a graph 
can be represented by its adjacency matrix, incidence matrix, or the many variations on those formats. With this matrix representation in hand we have a method to operate on the graph using linear algebra operations on the matrix.

![BFS](./assets/AdjacencyMatrixBFS.png)