# Select Operators

A `SelectOp` is effectively a binary or unary operation which is able to access the location of an element as well as its value.
They define predicates for use with the [`select`](@ref) function.

Applying `select` with a `SelectOp` will always return a result with the same type and shape as its argument.

## Built-Ins

Built-in `SelectOp`s can be found in the `SelectOps` submodule.

```@docs
SuiteSparseGraphBLAS.TRIL
SuiteSparseGraphBLAS.TRIU
SuiteSparseGraphBLAS.DIAG
SuiteSparseGraphBLAS.OFFDIAG
SuiteSparseGraphBLAS.NONZERO
SuiteSparseGraphBLAS.NE
SuiteSparseGraphBLAS.EQ
SuiteSparseGraphBLAS.GT
SuiteSparseGraphBLAS.GE
SuiteSparseGraphBLAS.LT
SuiteSparseGraphBLAS.LE
```