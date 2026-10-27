# Array Types

```@meta
DocTestSetup = :(using SuiteSparseGraphBLAS, SparseArrays)
DocTestFilters = [r"memory: \d+ bytes"]
```

There are two primary array types in SuiteSparseGraphBLAS.jl: [`GBVector`](@ref) and [`GBMatrix`](@ref), as well as a few specialized versions of those array types. The full type hierarchy is:

```
AbstractGBArray{T, F, O, N} <: AbstractSparseArray{Union{T, F}, N}
 ├ N = 2 ─ AbstractGBMatrix{T, F} 
 │   ├─ GBMatrix{T, F, RuntimeOrder()}
 │   ├─ OrientedGBMatrix{T, F, O}
 │   └─ GBShallowMatrix{T, F, ColMajor()}
 └ N = 1, O = ColMajor() ─ AbstractGBVector{T, F}
     ├─ GBVector{T, F}
     └─ GBShallowVector{T, F}
```

The `T` parameter is the element type of the array, `N` is the dimensionality, `F` is the type of the fill value (often `Nothing` or `T`), and `O` is the storage order. The `OrientedGBMatrix` restricts the orientation to the parameter `O` to either `ByRow()` or `ByCol()`. 

All of these types attempt to implement most of the `AbstractArray` interface, and the relevant parts of the `SparseArrays` interface.

## GBMatrix

The `GBMatrix` is an opaque sparse matrix structure, which adapts to the sparsity of a matrix by changing the implementation internally. There are 4 different internal representations, all stored in either row or column orientation:

1. _**Dense**_ - Equivalent to a Julia `Matrix`, except it may be stored in `RowMajor()` order.
2. _**Bitmap**_ - 2 dense arrays, one storing booleans in the pattern of the matrix, the other storing the values.
3. _**Sparse Compressed**_ - [Compressed Sparse Column (CSC)](http://netlib.org/linalg/html_templates/node92.html#SECTION00931200000000000000) or [Compressed Sparse Row(CSR)](http://netlib.org/linalg/html_templates/node91.html)
4. _**Doubly Compressed**_ or **Hypersparse** - Doubly Compressed Sparse Column (DCSC or Hypersparse CSC) and Doubly Compressed Sparse Row (DCSR or Hypersparse CSR). See this paper for more information: [pdf](https://people.eecs.berkeley.edu/~aydin/hypersparse-ipdps08.pdf).

Additionally, when the stored values in a `GBMatrix` are uniform the value array may be stored in the _**iso**_ version of one of the formats above. Rather than storing the full value array, an iso `GBMatrix` will only store the single scalar to improve performance. This is useful for matrices like the unweighted adjacency matrix, where all stored values may be `true`. 

Users should rarely need to directly interact with the underlying storage format, SuiteSparse:GraphBLAS will automatically convert between them as necessary.

### Construction

There are several methods to construct GBArrays. Shown here are empty construction, conversion from a dense matrix and a sparse matrix, and coordinate form with uniform or *iso* coefficients. 
```jldoctest mat
julia> x = GBMatrix{Bool}(20_000_000, 50_000)
20000000x50000 GraphBLAS bool matrix, hypersparse by row, ints: 32/32/32
  no entries, memory: 256 bytes

julia> x = GBMatrix([[1,2] [3,4]])
2x2 GraphBLAS int64_t matrix, full by col
  4 entries, memory: 272 bytes

    (1,1)   1
    (2,1)   2
    (1,2)   3
    (2,2)   4

julia> x = GBMatrix(sparse([1, 2, 3], [3, 1, 2], [1.0, 2.0, 3.0]); fill = 0.0)
3x3 GraphBLAS double matrix, bitmap by col
  3 entries, memory: 321 bytes

    (2,1)    2
    (3,2)    3
    (1,3)    1

julia> x = GBMatrix(
           [1, 20_000, 400_000], [7, 30_000, 500_000], 1, 500_000, 500_000
       )
500000x500000 GraphBLAS int64_t matrix, hypersparse by row, ints: 32/32/32
  3 entries, memory: 288 bytes
  iso value:   1

    (1,7)   1
    (20000,30000)   1
    (400000,500000)   1
```

```@docs
GBMatrix
```

## GBVector

A `GBVector` is the one-dimensional equivalent of the `GBMatrix`, and internally a `GBVector` is represented in exactly the same fashion. However, they are always column-oriented. 

### Construction 

```jldoctest mat
julia> v = GBVector{ComplexF32}(100)
100x1 GraphBLAS float complex matrix, sparse by col, ints: 32/32/32
  no entries, memory: 248 bytes

julia> v = GBMatrix(ComplexF64[1, 2im, 3 + 4im]; fill = nothing)
3x1 GraphBLAS double complex matrix, full by col
  3 entries, memory: 288 bytes
  fill value:  nothing

    (1,1)    1 + 0i
    (2,1)    0 + 2i
    (3,1)    3 + 4i

julia> v = GBVector(sparsevec([1, 50_000_000, 100_000_000], true, 100_000_000))
100000000x1 GraphBLAS bool matrix, sparse by col, ints: 64/64/64
  3 entries, memory: 283 bytes

    (1,1)   1
    (50000000,1)   1
    (100000000,1)   1
```

```@docs
GBVector
```

# Indexing

The usual AbstractArray and SparseArray indexing capabilities are available. Including indexing by scalars, vectors, and ranges.

!!! danger "Indexing Structural Zeros"
    When indexing a `SparseMatrixCSC` from `SparseArrays` a structural, or implicit, zero will be returned as `zero(T)` where `T` is the element type of the matrix.

    When indexing a GBArray structural zeros default to `nothing`.
    While this is a significant departure from the `SparseMatrixCSC` it more closely matches the GraphBLAS spec,
    and enables the consuming method to determine the value of implicit zeros in the presence of explicit zeros. 
    
    For instance with an element type of `Float64` you may want the implicit zero to be `0.0`, `-∞` or `+∞` depending on your algorithm. In addition, for graph algorithms there may be a distinction between an implicit zero, indicating the lack of an edge between two vertices in an adjacency matrix, and an explicit zero where the edge exists but has a `0` weight.

    However, many functions outside of GraphBLAS will throw an error if they receive `nothing` from an indexing operation. To accomodate these functions the user may set the fill value for an `AbstractGBArray` on construction and with [`setfill`](@ref) and [`setfill!`](@ref).

```jldoctest mat
julia> A = GBMatrix([1,1,2,2,3,4,4,5,6,7,7,7], [2,4,5,7,6,1,3,6,3,3,4,5], [1:12...])
7x7 GraphBLAS int64_t matrix, bitmap by row
  12 entries, memory: 681 bytes

    (1,2)   1
    (1,4)   2
    (2,5)   3
    (2,7)   4
    (3,6)   5
    (4,1)   6
    (4,3)   7
    (5,6)   8
    (6,3)   9
    (7,3)   10
    (7,4)   11
    (7,5)   12

julia> SparseMatrixCSC(A)
7×7 SparseMatrixCSC{Int64, Int64} with 12 stored entries:
 ⋅  1   ⋅   2   ⋅  ⋅  ⋅
 ⋅  ⋅   ⋅   ⋅   3  ⋅  4
 ⋅  ⋅   ⋅   ⋅   ⋅  5  ⋅
 6  ⋅   7   ⋅   ⋅  ⋅  ⋅
 ⋅  ⋅   ⋅   ⋅   ⋅  8  ⋅
 ⋅  ⋅   9   ⋅   ⋅  ⋅  ⋅
 ⋅  ⋅  10  11  12  ⋅  ⋅

julia> A[4]
6

julia> A[1,2]
1

julia> A[[1,3,5,7], :]
4x7 GraphBLAS int64_t matrix, bitmap by row
  7 entries, memory: 492 bytes

    (1,2)   1
    (1,4)   2
    (2,6)   5
    (3,6)   8
    (4,3)   10
    (4,4)   11
    (4,5)   12

julia> A[1:2:7, :]
4x7 GraphBLAS int64_t matrix, bitmap by row
  7 entries, memory: 492 bytes

    (1,2)   1
    (1,4)   2
    (2,6)   5
    (3,6)   8
    (4,3)   10
    (4,4)   11
    (4,5)   12

julia> A[:,:]
7x7 GraphBLAS int64_t matrix, bitmap by row
  12 entries, memory: 681 bytes

    (1,2)   1
    (1,4)   2
    (2,5)   3
    (2,7)   4
    (3,6)   5
    (4,1)   6
    (4,3)   7
    (5,6)   8
    (6,3)   9
    (7,3)   10
    (7,4)   11
    (7,5)   12

julia> A[:, 5]
7x1 GraphBLAS int64_t matrix, bitmap by col
  2 entries, memory: 304 bytes

    (2,1)   3
    (7,1)   12
```

The functionality illustrated above extends to `GBVector` as well.

# Transpose
The lazy Julia `transpose` is available, and the adjoint operator `'` is also
overloaded to be equivalent for non-`Complex` types.

# Special `GBArray` Types

```@docs
GBMatrixR
GBMatrixC
SuiteSparseGraphBLAS.GBShallowMatrix
SuiteSparseGraphBLAS.GBShallowVector
SuiteSparseGraphBLAS.GBScalar
```