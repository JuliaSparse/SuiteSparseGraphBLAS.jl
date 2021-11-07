# SuiteSparseGraphBLAS.jl

SuiteSparseGraphBLAS.jl is a package for sparse linear algebra on arbitrary semirings, with a particular focus on graph computations.
It aims to provide a Julian wrapper over Tim Davis' SuiteSparse reference implementation of the GraphBLAS C specification.

# Installation

Install using the Julia package manager in the REPL:

```
] add SuiteSparseGraphBLAS
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

SuiteSparseGraphBLAS.jl provides `GBVector` and `GBMatrix` array types which are subtypes of `SparseArrays.AbstractSparseVector` and `SparseArrays.AbstractSparseMatrix` respectively.

```@setup intro
using SuiteSparseGraphBLAS
using SparseArrays
```

```@repl intro
GBVector{Float64}(13)

GBMatrix{ComplexF64}(1000, 1000)
```

GraphBLAS array types are opaque to the user in order to allow the library author to choose the best storage format.
SuiteSparse:GraphBLAS takes advantage of this by storing matrices in one of four formats: dense, bitmap, sparse-compressed, or hypersparse-compressed; and in either row or column major orientation.

!!! warning "Default Orientation"
    The default orientation of a `GBMatrix` is by-row, the opposite of Julia arrays, for speed
    in certain operations. However, a `GBMatrix` constructed from a `SparseMatrixCSC` or 
    `Matrix` will be stored by-column. This can be changed using `gbset(A, :format, :byrow)`.

The matrix and vector in the graphic above can be constructed as follows:

```@repl intro
A = GBMatrix([1,1,2,2,3,4,4,5,6,7,7,7], [2,4,5,7,6,1,3,6,3,3,4,5], [1:12...])

v = GBVector([4], [10])
```
## GraphBLAS Operations

The complete documentation of supported operations can be found in [Operations](@ref).
GraphBLAS operations are, where possible, methods of existing Julia functions  listed in the third column.

| GraphBLAS           | Operation                                                        | Julia                                      |
|:--------------------|:----------------------------------------:                        |----------:                                 |
|`mxm`, `mxv`, `vxm`  |``\bf C \langle M \rangle = C \odot AB``                          |`mul[!]` or `*`                             |
|`eWiseMult`          |``\bf C \langle M \rangle = C \odot (A \otimes B)``               |`emul[!]` or `.` broadcasting               |
|`eWiseAdd`           |``\bf C \langle M \rangle = C \odot (A \oplus  B)``               |`eadd[!]`                                   |
|`extract`            |``\bf C \langle M \rangle = C \odot A(I,J)``                      |`extract[!]`, `getindex` or `A[i...]`       |
|`subassign`          |``\bf C (I,J) \langle M \rangle = C(I,J) \odot A``                |`subassign[!]`, `setindex!` or `A[i...]=3.5`|
|`assign`             |``\bf C \langle M \rangle (I,J) = C(I,J) \odot A``                |`assign[!]`                                 |
|`apply`              |``{\bf C \langle M \rangle = C \odot} f{\bf (A)}``                |`map[!]` or `.` broadcasting                |
|                     |``{\bf C \langle M \rangle = C \odot} f({\bf A},y)``              |                                            |
|                     |``{\bf C \langle M \rangle = C \odot} f(x,{\bf A})``              |                                            |
|`select`             |``{\bf C \langle M \rangle = C \odot} f({\bf A},k)``              |`select[!]`                                 |
|`reduce`             |``{\bf w \langle m \rangle = w \odot} [{\oplus}_j {\bf A}(:,j)]`` |`reduce[!]`                                 |
|                     |``s = s \odot [{\oplus}_{ij}  {\bf A}(i,j)]``                     |                                            |
|`transpose`          |``\bf C \langle M \rangle = C \odot A^{\sf T}``                   |`gbtranspose[!]`, lazy: `transpose`, `'`    |
|`kronecker`          |``\bf C \langle M \rangle = C \odot \text{kron}(A, B)``           |`kron[!]`                                   |

where ``\bf M`` is a `GBArray` mask, ``\odot`` is a binary operator for accumulating into ``\bf C``, and ``\otimes`` and ``\oplus`` are a binary operation and commutative monoid respectively. 

## GraphBLAS Operators

A GraphBLAS operator is a unary or binary function, the commutative monoid form of a binary function,
or a semiring, made up of a binary op and a commutative monoid.
SuiteSparse:GraphBLAS ships with many of the common unary and binary operators as built-ins,
along with monoids and semirings built commonly used in graph algorithms. 
In most cases these operators can be used with familiar Julia syntax and functions, which then map to
objects found in the submodules below:

- `UnaryOps` such as `SIN`, `SQRT`, `ABS`
- `BinaryOps` such as `GE`, `MAX`, `POW`, `FIRSTJ`
- `Monoids` such as `PLUS_MONOID`, `LXOR_MONOID`
- `Semirings` such as `PLUS_TIMES` (the arithmetic semiring), `MAX_PLUS` (a tropical semiring), `PLUS_PLUS`, ...

The above objects should, in almost all cases, be used by instead passing the equivalent functions, `sin` for `SIN`, `+` for `PLUS_MONOID` etc.

A user may choose to call a function in multiple different forms: `A .+ B`, `eadd(A, B, +)`,
or `eadd(A, B, BinaryOps.PLUS)`. 

Functions which only accept monoids like `reduce` will automatically find the correct monoid,
so a call to `reduce(+, A)`, will lower to `reduce(Monoids.PLUS_MONOID, A)`.

Matrix multiplication, which accepts a semiring, can be called with either `*(max, +)(A, B)`,
`mul(A, B, (max, +))`, or `mul(A, B, Semirings.MAX_PLUS)`. 

!!! warning "Performance of User Defined Functions"
    Operators which are not already built-in are automatically constructed using function pointers when called. 
    Note, however, that their performance is significantly degraded compared to built-in operators,
    and where possible user code should avoid this capability.

## Example

Here is an example of two different methods of triangle counting with GraphBLAS.
The methods are drawn from the LAGraph [repo](https://github.com/GraphBLAS/LAGraph).

Input `A` must be a square, symmetric matrix with any element type.
We'll test it using the matrix from the GBArray section above, which has two triangles in its undirected form.

```@repl intro
function cohen(A)
  U = select(triu, A)
  L = select(tril, A)
  return reduce(+, mul(L, U, (+, pair); mask=A)) ÷ 2
end

function sandia(A)
  L = select(tril, A)
  return reduce(+, mul(L, L, (+, pair); mask=L))
end

M = eadd(A, A', +) #Make undirected/symmetric
cohen(M)
sandia(M)
```
