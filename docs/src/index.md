# SuiteSparseGraphBLAS.jl

SuiteSparseGraphBLAS.jl is a WIP package for sparse linear algebra on arbitrary semirings, with a particular focus on graph computations.
It aims to provide a Julian wrapper over Tim Davis' SuiteSparse reference implementation of the GraphBLAS C specification.

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

!!! warning Printing 
    Printing is done directly by GraphBLAS in this release. This means printed indices are 0-based, and the displayed type is the equivalent C type. The v1.0 release will alleviate this issue.

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

GraphBLAS harnesses the well-understood duality between graphs and matrices. 
Specifically a graph can be represented by its [adjacency matrix](https://en.wikipedia.org/wiki/Adjacency_matrix), [incidence matrix](https://en.wikipedia.org/wiki/Incidence_matrix), or the many variations on those formats. 
With this matrix representation in hand we have a method to operate on the graph using linear algebra operations on the matrix.

Below is an example of the adjacency matrix of a directed graph, and finding the neighbors of a single vertex using basic matrix-vector multiplication on the arithemtic semiring.

![BFS and Adjacency Matrix](./assets/AdjacencyBFS.png)

# GraphBLAS Concepts

The three primary components of GraphBLAS are: matrices, operators, and operations. Operators include monoids, binary operators, and semirings. Operations include the typical linear algebraic operations like matrix multiplication as well as indexing operations.

## GBArrays

SuiteSparseGraphBLAS.jl provides `GBVector` and `GBMatrix` array types which are subtypes of `SparseArrays.AbstractSparseVector` and `SparseArrays.AbstractSparseMatrix` respectively. Both can be constructed with no arguments to use the maximum size.

```julia
julia> GBVector{Float64}()
1152921504606846976x1 GraphBLAS double vector, sparse by col
  no entries

1152921504606846976x1152921504606846976 GraphBLAS int8_t matrix, hypersparse by col
  no entries
```

GraphBLAS array types are opaque to the user in order to allow the library author to choose the best storage format.
SuiteSparse:GraphBLAS takes advantage of this by storing matrices in one of four formats: dense, bitmap, sparse-compressed, or hypersparse-compressed; and in either row or column major orientation.
SuiteSparseGraphBLAS.jl sets the default to column major to ensure fast imports and exports.

A complete list of construction methods can be found in [Construction](@ref), but the matrix and vector above can be constructed as follows:

```julia
julia> A = GBMatrix([1,1,2,2,3,4,4,5,6,7,7,7], [2,4,5,7,6,1,3,6,3,3,4,5], [1:12...])
7x7 GraphBLAS int64_t matrix, bitmap by col
  12 entries

    (3,0)   6
    (0,1)   1
    (3,2)   7
    (5,2)   9
    (6,2)   10
    (0,3)   2
    (6,3)   11
    (1,4)   3
    (6,4)   12
    (2,5)   5
    (4,5)   8
    (1,6)   4

v = GBVector([4], [10])
4x1 GraphBLAS int64_t vector, bitmap by col
  1 entry

    (3,0)   10
```
## GraphBLAS Operations

A complete list of supported operations can be found in [Operations](@ref).
GraphBLAS operations are, where possible, wrapped in existing Julia functions. The equivalent Julia functions are:

| GraphBLAS     | Operation                                | Julia     |
|---------------|------------------------------------------|-----------|
| mxm, mxv, vxm | ``\bf C \langle M \rangle = C \odot AB`` | mul!, mul |
|               |                                          |           |
|               |                                          |           |
