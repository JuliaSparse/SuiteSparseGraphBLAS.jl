# SuiteSparseGraphBLAS.jl

SuiteSparseGraphBLAS.jl is a package for sparse linear algebra on arbitrary semirings, with a particular focus on graph computations.
It aims to provide a Julian wrapper over Tim Davis' SuiteSparse:GraphBLAS reference implementation of the GraphBLAS C specification.

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

Then in the REPL or script `using SuiteSparseGraphBLAS` will import the package.

# Introduction

GraphBLAS harnesses the well-understood duality between graphs and matrices.
Specifically a graph can be represented by the [adjacency matrix](https://en.wikipedia.org/wiki/Adjacency_matrix) and/or [incidence matrix](https://en.wikipedia.org/wiki/Incidence_matrix), or one of the many variations on those formats. 
With this matrix representation in hand we have a method to operate on the graph with linear algebra.

Below is an example of the adjacency matrix of a directed graph, and finding the neighbors of a single vertex using basic matrix-vector multiplication on the arithemtic semiring.

![BFS and Adjacency Matrix](./assets/AdjacencyBFS.png)

## GBArrays

The core SuiteSparseGraphBLAS.jl array types are `GBVector` and `GBMatrix` which are subtypes `SparseArrays.AbstractSparseVector` and `SparseArrays.AbstractSparseMatrix` respectively.

!!! note "GBArray"
    These docs will often refer to the `GBArray` type, which is the union of `GBVector`, `GBMatrix` and their lazy Transpose objects.

```@setup intro
using SuiteSparseGraphBLAS
using SparseArrays
```

```@repl intro
# create a size 13 empty sparse vector with Float64 elements.
v = GBVector{Float64}(13) 

# create a 1000 x 1000 empty sparse matrix with ComplexF64 elements.
A = GBMatrix{ComplexF64}(1000, 1000)

A[1,5] === nothing
```

Here we can already see several differences compared to `SparseArrays.SparseMatrixCSC`.

The first is that `A` is stored in `hypersparse` format, and by row.

`GBArrays` are (technically) opaque to the user in order to allow the library author to choose the best storage format.\
GraphBLAS takes advantage of this by storing matrices in one of four formats: `dense`, `bitmap`, `sparse-compressed`, or `hypersparse-compressed`; and in either `row` or `column` major orientation.

!!! warning "Default Orientation"
    The default orientation of a `GBMatrix` is by-row, the opposite of Julia arrays. However, a `GBMatrix` constructed from a `SparseMatrixCSC` or 
    `Matrix` will be stored by-column.\
    The orientation of a `GBMatrix` can be modified using
    `gbset(A, :format, :byrow)` or `gbset(A, :format, :bycol)`, and queried by `gbget(A, :format)`

Information about storage formats, orientation, conversion, construction and more can be found in [Arrays](@ref).

The second difference is that a `GBArray` doesn't assume the fill-in value of a sparse array.\
Since `A[1,5]` isn't stored in the matrix (it's been "compressed" out), we return `nothing`.\

This matches the GraphBLAS spec, where `NO_VALUE` is returned, rather than `zero(eltype(A))`. 

An empty matrix and vector won't do us much good, so let's see how to construct the matrix and vector from the graphic above. Both `A` and `v` below are constructed from coordinate format or COO.

```@repl intro
#GBMatrix(I::Vector{<:Integer}, J::Vector{<:Integer}, V::Vector{T})
A = GBMatrix([1,1,2,2,3,4,4,5,6,7,7,7], [2,4,5,7,6,1,3,6,3,3,4,5], [1:12...])

#GBVector(I::Vector{<:Integer}, V::Vector{T})
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
