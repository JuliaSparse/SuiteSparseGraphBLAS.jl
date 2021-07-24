# GBArrays

There are two datastructures in in `SuiteSparseGraphBLAS.jl`: the `GBVector` and `GBMatrix`.

Both types currently implement most of the `AbstractArray` interface and part of the `SparseArrays`
interface. 
The goal is to cover the entirety of both (applicable) interfaces as well as `ArrayInterface.jl`
with the `v1.0` release. 

Most functions accept either type, which is represented by the union 
`GBArray = {GBVector, GBMatrix, Transpose{<:Any, <:GBMatrix}}`. 

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
SuiteSparseGraphBLAS.GBVector{T}()
SuiteSparseGraphBLAS.GBVector(::Vector, ::Vector)
SuiteSparseGraphBLAS.GBVector(::SparseVector)
```

# Indexing

The usual AbstractArray and SparseArray indexing should work here. Including indexing by scalars, vectors, and ranges.

!!! danger "Indexing Structural Zeros"
    When you index a `SparseMatrixCSC` from `SparseArrays` and hit a structural zero (a value within the dimensions of the matrix but not stored) you can expect a `zero(T)`.

    When you index a GBArray you will get `nothing` when you hit a structural zero. This is because the zero in GraphBLAS depends not just on the domain of the elements but also on what you are __doing__ with them. For instance with an element type of `Float64` you could want the zero to be `0.0`, `-∞` or `+∞`.

We'll use the small matrix from the Introduction to illustrate the indexing capabilities. We will also use `SparseArrays.SparseMatrixCSC` for the pretty printing functionality, which should be available in this package in `v1.0`.

```@repl mat
A = GBMatrix([1,1,2,2,3,4,4,5,6,7,7,7], [2,4,5,7,6,1,3,6,3,3,4,5], [1:12...])
SparseMatrixCSC(A)
A[4]
A[1,2]
A[[1,3,5,7], :]
A[1:2:7, :]
A[:,:]
A[:, 5]
SparseMatrixCSC(A[:,:, desc=T0]) #Transpose the first argument
```

All of this same functionality exists for vectors in 1-dimension.

# Transpose
The typical lazy Julia `transpose` is available as usual, and the adjoint operator `'` is also
overloaded to be equivalent.

`x = A'` will create a `Transpose` wrapper.
When an operation uses this argument it will cause the `desc` to set `INP<0|1> = T_<0|1>`. 

!!! warning
    Vectors do not support transposition at this time. A matrix with the column or row size set to `1` may be a solution.

# Utilities

```@docs
clear!
```