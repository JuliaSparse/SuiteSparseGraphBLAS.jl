# Index Operators

An `IndexUnaryOp` is a unary operation which is able to access the location of an element as well as its value.
They define predicates for use with the [`select!`](@ref) function as well as index access for [`apply!`](@ref).

## Built-Ins

Built-in `IndexUnaryOps`s can be found in the `SelectOps` submodule. However users should pass the equivalent Julia function when possible.

```@docs
SuiteSparseGraphBLAS.diagindex
SuiteSparseGraphBLAS.isindexop
SuiteSparseGraphBLAS.IndexOp
```