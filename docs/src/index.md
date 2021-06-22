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

!!! danger "Printing"

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

| GraphBLAS           | Operation                                                        | Julia                                   |
|:--------------------|:----------------------------------------:                        |----------:                              |
|`mxm`, `mxv`, `vxm`  |``\bf C \langle M \rangle = C \odot AB``                          |`mul[!]`                                 |
|`eWiseMult`          |``\bf C \langle M \rangle = C \odot (A \otimes B)``               |`emul[!]`                                |
|`eWiseAdd`           |``\bf C \langle M \rangle = C \odot (A \oplus  B)``               |`eadd[!]`                                |
|`extract`            |``\bf C \langle M \rangle = C \odot A(I,J)``                      |`extract[!]`, `getindex`                 |
|`subassign`          |``\bf C (I,J) \langle M \rangle = C(I,J) \odot A``                |`subassign[!]`, `setindex!`              |
|`assign`             |``\bf C \langle M \rangle (I,J) = C(I,J) \odot A``                |`assign[!]`                              |
|`apply`              |``{\bf C \langle M \rangle = C \odot} f{\bf (A)}``                |`map[!]`                                 |
|                     |``{\bf C \langle M \rangle = C \odot} f({\bf A},y)``              |                                         |
|                     |``{\bf C \langle M \rangle = C \odot} f(x,{\bf A})``              |                                         |
|`select`             |``{\bf C \langle M \rangle = C \odot} f({\bf A},k)``              |`select[!]`                              |
|`reduce`             |``{\bf w \langle m \rangle = w \odot} [{\oplus}_j {\bf A}(:,j)]`` |`reduce[!]`                              |
|                     |``s = s \odot [{\oplus}_{ij}  {\bf A}(i,j)]``                     |                                         |
|`transpose`          |``\bf C \langle M \rangle = C \odot A^{\sf T}``                   |`gbtranspose[!]`, lazy: `transpose`, `'` |
|`kronecker`          |``\bf C \langle M \rangle = C \odot \text{kron}(A, B)``           |`kron[!]`                                |

where ``\bf M`` is a `GBArray` mask, ``\odot`` is a binary operator for accumulating into ``\bf C``, and ``\otimes`` and ``\oplus`` are a binary operation and commutative monoid respectively. 

!!! note "assign vs subassign"

    `subassign` is equivalent to `assign` except that the mask in `subassign` has the dimensions of ``\bf C(I,J)`` vs the dimensions of ``C`` for `assign`, and elements outside of the mask will never be modified by `subassign`.

### Common arguments

The operations above have a typical set of common arguments. These are:

#### `op` - `UnaryOp`, `BinaryOp`, `Monoid`, or `Semiring`:

This is the key argument to most of these operations, which determines ``\oplus``, ``\otimes``, or ``f`` in the table above as well as the semiring used in `mul`.
Most operations are restricted to one type of operator.

!!! warning "Keyword vs Positional"
    For some operations like `mul` and `emul` this is a keyword argument which defaults to the typical arithmetic operators.
    For others like `map` this is the first argument, since there is no sensible default choice.



!!! tip "Built-Ins"
    The built-in operators can be found in the submodules: `UnaryOps`, `BinaryOps`, `Monoids`, and `Semirings`.

#### `desc` - `Descriptor`:

The descriptor argument allows the user to modify the operation in some fashion. The most common options are:

- `desc.[input1 | input2] == [DEFAULT | TRANSPOSE]` 

    Transposes the inputs and can be found in `Descriptors.[T0 | T1 | T0T1]`. 
    Typically you should use Julia's built-in transpose functionality.

- `desc.mask == [DEFAULT | STRUCTURE | COMPLEMENT | STRUCTURE + COMPLEMENT]` 

    If `STRUCTURE` is set the operation will use the presence of a value rather than the value itself to determine whether the index is masked. 
    If `COMPLEMENT` is set the presence/truth value is complemented (ie. if **no** value is present or the value is **false** that index is masked).

- `desc.output` == [DEFAULT | REPLACE]

    If `REPLACE` is set the operation will replace all values in the output matrix **after** the accumulation step. 
    If an index is found in the output matrix, but not in the results of the operation it will be set to `nothing`. 


#### `accum` - `BinaryOp`:

The `accum` keyword argument provides a binary operation to accumulate results into the result array. 
The accumulation step is performed **before** masking.

#### `mask` - `GBArray`:

The `mask` keyword argument determines whether each index from the result of an operation appears in the output. 
The mask may be structural, where the presence of a value indicates the mask is `true`, or valued where the value of the mask indicates its truth value. 
The mask may also be complemented.


### Order of Operations

A GraphBLAS operation occurs in the following order (steps are skipped when possible):

1. Calculate `T = <operation>(args...)`
2. Elementwise accumulate `Z[i,j] = accum(C[i,j], T[i,j])`
3. Optionally masked assignment `C[i,j] = mask[i,j] ? Z[i,j] : [nothing | C[i,j]]`

If `REPLACE` is set the option in step 3. is `nothing`, otherwise it is `C[i,j]`.

## GraphBLAS Operators

GraphBLAS operators are one of the following:

- `UnaryOps` such as `SIN`, `SQRT`, `ABS`, ...
- `BinaryOps` such as `GE`, `MAX`, `POW`, `FIRSTJ`, ...
- `Monoids` such as `PLUS_MONOID`, `LXOR_MONOID`, ...
- `Semirings` such as `PLUS_TIMES` (the arithmetic semiring), `MAX_PLUS` (a tropical semiring), `PLUS_PLUS`, ...

Built-in operators can be found in exported submodules:

```julia
julia> BinaryOps.

ANY       BSET       DIV        FIRSTJ1    ISGE       LDEXP      MIN        RDIV       SECONDJ
ATAN2     BSHIFT     EQ         FMOD       ISGT       LE         MINUS      REMAINDER  SECONDJ1
BAND      BXNOR      FIRST      GE         ISLE       LOR        NE         RMINUS     TIMES
BCLR      BXOR       FIRSTI     GT         ISLT       LT         PAIR       SECOND
BGET      CMPLX      FIRSTI1    HYPOT      ISNE       LXOR       PLUS       SECONDI
BOR       COPYSIGN   FIRSTJ     ISEQ       LAND       MAX        POW        SECONDI1
```

## Example



```julia
```