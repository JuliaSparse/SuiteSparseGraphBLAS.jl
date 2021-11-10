# Array Types

There are two primary datastructures in in `SuiteSparseGraphBLAS.jl`: the `GBVector` and `GBMatrix`.

Both types currently implement most of the `AbstractArray` interface and part of the `SparseArrays`
interface. 

## Matrix Construction
```@setup mat
using SuiteSparseGraphBLAS
using SparseArrays
```
```@repl mat
x = GBMatrix{Bool}(20_000_000, 50_000)
x = GBMatrix([[1,2] [3,4]])
x = GBMatrix(sprand(100, 100, 0.5))
x = GBMatrix(rand(1:50_000, 5000), rand(1:500_000, 5000), 1; ncols = 500_000, nrows = 500_000)
```

```@docs
GBMatrix
SuiteSparseGraphBLAS.GBMatrix(::Matrix)
SuiteSparseGraphBLAS.GBMatrix(::SparseMatrixCSC)
```
Conversion back to matrices, sparse or dense, is also supported.
## Vector Construction
```@repl mat
v = GBVector{ComplexF32}(100)
v = GBMatrix(rand(ComplexF64, 3))
v = GBVector(sprand(Bool, 100_000_000, 0.001))
```

```@docs
GBVector
SuiteSparseGraphBLAS.GBVector(::Vector)
SuiteSparseGraphBLAS.GBVector(::AbstractVector{<:Integer}, ::AbstractVector)
```

# Indexing

Normal AbstractArray and SparseArray indexing should work here. Including indexing by scalars, vectors, and ranges.

!!! danger "Indexing Structural Zeros"
    When indexing a `SparseMatrixCSC` from `SparseArrays` a structural, or implicit, zero will be returned as `zero(T)` where `T` is the elemtn type of the matrix.

    When indexing a GBArray a structural zero is instead returned as `nothing`. While this is a significant departure from the `SparseMatrixCSC` it more closely matches the GraphBLAS spec, and enables the consuming method to determine the value of implicit zeros. 
    
    For instance with an element type of `Float64` you may want the zero to be `0.0`, `-∞` or `+∞` depending on your algorithm. In addition, for graph algorithms there may be a distinction between an implicit zero, indicating the lack of an edge between two vertices in an adjacency matrix, and an explicit zero where the edge exists but has a `0` weight.

```@repl mat
A = GBMatrix([1,1,2,2,3,4,4,5,6,7,7,7], [2,4,5,7,6,1,3,6,3,3,4,5], [1:12...])
SparseMatrixCSC(A)
A[4]
A[1,2]
A[[1,3,5,7], :]
A[1:2:7, :]
A[:,:]
A[:, 5]
SparseMatrixCSC(A'[:,:]) #Transpose the first argument
```

The functionality illustrated above extends to `GBVector` as well.

# Transpose
The lazy Julia `transpose` is available, and the adjoint operator `'` is also
overloaded to be equivalent.

# Utilities

```@docs
clear!
```