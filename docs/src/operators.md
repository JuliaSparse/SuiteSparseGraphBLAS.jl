# Basics

There are five operator types in SuiteSparseGraphBLAS. Four are defined for all GraphBLAS implementations: `UnaryOp`, `BinaryOp`, `Monoid`, and `Semiring`. 
One is an extension to the `v1.3` specification: `SelectOp`.

!!! danger "Note"
    Operators are **not** callable objects like functions. They **do** behave like functions as arguments to higher-order functions (operations in the language of GraphBLAS). However `BinaryOp` and `UnaryOp` operators
    typically have a synonymous julia function, which can be found using `juliaop(op)`.

Typically operators are positional arguments in one of two places.
For operations with a clear default operator they appear as the last positional argument:

- [`emul(A, B, op::Union{BinaryOp, Function})`](@ref emul)
- [`eadd(A, B, op::Union{BinaryOp, Function})`](@ref eadd)
- [`kron(A, B, op::Union{BinaryOp, Function})`](@ref kron)
- [`mul(A, B, op::Union{Semiring, Tuple{Function, Function}})`](@ref mul)

For other operations without a clear default operator they appear as the first argument:

- [`map(op::Union{UnaryOp, Function}, A)`](@ref map)
- [`reduce(op::Union{BinaryOp, Function}, A)`](@ref reduce)
- [`select(op::Union{SelectOp, Function}, A)`](@ref select)

## UnaryOps, BinaryOps, Monoids, and Semirings

Each operator is defined on a specific domain. For some this is the usual primitive datatypes like booleans, floats, and signed and unsigned integers of the typical sizes.

Each operator is represented as its own concrete type for dispatch purposes. 
For instance `BinaryOps.PLUS <: AbstractBinaryOp <: AbstractOp`.
Operators are effectively dictionaries containing the type-specific operators indexed by the `DataType` of their arguments. 

### Supported Types

SuiteSparseGraphBLAS.jl natively supports the following types:

- Booleans
- Integers with sizes 8, 16, 32, 64
- Unsigned Integers with sizes 8, 16, 32, 64
- Float32 and Float64
- ComplexF32 and ComplexF64

The supported types can be found as in the example below:
```@setup operators
using SuiteSparseGraphBLAS
```
```@repl operators
Semiring(max, +)
Semirings.MAX_PLUS
Semirings.MAX_PLUS[Float64]
```

All operations will accept the function/tuple form, the `DataType` form, or the `TypedSemiring` form.
Unless you need to specifically cast the arguments to a specific type there is no need to specify the operator type.

You can determine the available types for an operator and the input and output types of a type-specific operator with the functions below:

```@docs
xtype
ytype
ztype
```
```@docs
validtypes
```

Some examples of these functions are below. 
Note the difference between `ISGT` which returns a result with the same type as the input, and `GT` which returns a `Boolean`.

```@repl operators
xtype(Semirings.LOR_GT[Float64])
ztype(Semirings.LOR_GT[Float64])
xtype(BinaryOps.ISGT[Int8])
ztype(BinaryOps.ISGT[Int8])
ztype(BinaryOps.GT[Int8])
```

## SelectOps

The [`SelectOp`](@ref) is a SuiteSparse extension to the specification, although a similar construct is likely to be found in a future specification.
Unlike the other operators there are no type-specific operators, and as such you cannot index into them with types to obtain a type-specific version.