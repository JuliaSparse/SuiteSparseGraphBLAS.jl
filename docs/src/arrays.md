# Array Types

There are two primary array types in SuiteSparseGraphBLAS.jl: [`GBVector`](@ref) and [`GBMatrix`](@ref), as well as a few specialized versions of those array types. The full type hierarchy is:

```
AbstractGBArray{T, N, F} <: AbstractSparseArray{T, N}
 ├ N = 2 ─ AbstractGBMatrix{T, F} 
 │   ├─ GBMatrix{T, F}
 │   └─ OrientedGBMatrix{T, F, O}
 └ N = 1 ─ AbstractGBVector{T, F}
     └─ GBVector{T, F}
```

The `T` parameter is the element type of the array, `N` is the dimensionality, `F` is the type of the fill value (often `Nothing` or `T`). The [`OrientedGBMatrix`](@ref) restricts the orientation to the parameter `O` which is either `ByRow()` or `ByCol()`. 

All of these types attempt to implement most of the `AbstractArray` interface, and the relevant parts of the `SparseArrays` interface.

## GBMatrix

There are several methods to construct GBArrays. Shown here are empty construction, conversion from a dense matrix and a sparse matrix, and coordinate form with uniform or *iso* coefficients. 
```@setup mat
using SuiteSparseGraphBLAS
using SparseArrays
```
```@repl mat
x = GBMatrix{Bool}(20_000_000, 50_000)
x = GBMatrix([[1,2] [3,4]])
x = GBMatrix(sprand(100, 100, 0.5); fill = 0.0)
x = GBMatrix(
    rand(1:50_000, 5000), rand(1:500_000, 5000), 1; 
    ncols = 500_000, nrows = 500_000
)
```

```@docs
GBMatrix
SuiteSparseGraphBLAS.GBMatrix(::Matrix)
```

## GBVector
```@repl mat
v = GBVector{ComplexF32}(100)
v = GBMatrix(rand(ComplexF64, 3); fill = nothing)
v = GBVector(sprand(Bool, 100_000_000, 0.001))
```

```@docs
GBVector
SuiteSparseGraphBLAS.GBVector(::Vector)
```

# Indexing

The usual AbstractArray and SparseArray indexing capabilities are available. Including indexing by scalars, vectors, and ranges.

!!! danger "Indexing Structural Zeros"
    When indexing a `SparseMatrixCSC` from `SparseArrays` a structural, or implicit, zero will be returned as `zero(T)` where `T` is the element type of the matrix.

    When indexing a GBArray structural zeros are instead returned as `nothing`. 
    While this is a significant departure from the `SparseMatrixCSC` it more closely matches the GraphBLAS spec,
    and enables the consuming method to determine the value of implicit zeros. 
    
    For instance with an element type of `Float64` you may want the zero to be `0.0`, `-∞` or `+∞` depending on your algorithm. In addition, for graph algorithms there may be a distinction between an implicit zero, indicating the lack of an edge between two vertices in an adjacency matrix, and an explicit zero where the edge exists but has a `0` weight.

    Better compatibility with `SparseMatrixCSC` and the ability to specify the value of implicit zeros is provided
    by `SuiteSparseGraphBLAS.SparseArrayCompat.SparseMatrixGB` array type.

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

!!! danger "Adjoint vs Transpose"
    The adjoint operator `'` currently transposes matrices rather than performing the
    conjugate transposition. In the future this will change to the complex conjugate
    for complex types, but currently you must do `map(conj, A')` to achieve this.

# Utilities

```@docs
clear!
```