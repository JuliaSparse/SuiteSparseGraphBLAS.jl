# Basics

Operators are one of the basic objects of GraphBLAS. In Julia, however, users must only interact directly with operators on rare occasions, and should instead pass functions to GraphBLAS operations.

There are five operator types in SuiteSparseGraphBLAS. Four are defined for all GraphBLAS implementations: `UnaryOp`, `BinaryOp`, `Monoid`, and `Semiring`. 
One is an extension to the `v1.3` specification: `SelectOp`.

!!! danger "Note"
    Operators are **not** callable objects like functions. They **do** behave like functions when used as arguments to higher-order functions (operations in the language of GraphBLAS).

Typically operators are positional arguments in one of two places.
For operations with a clear default operator they appear as the last positional argument:

- [`emul(A, B, op::Union{BinaryOp, Function})`](@ref emul)
- [`eadd(A, B, op::Union{BinaryOp, Function})`](@ref eadd)
- [`kron(A, B, op::Union{BinaryOp, Function})`](@ref kron)
- [`mul(A, B, op::Union{Semiring, Tuple{Function, Function}})`](@ref mul)

For other operations without a clear default operator they appear as the first argument:

- [`apply(op::Union{UnaryOp, Function}, A)`](@ref apply)
- [`reduce(op::Union{BinaryOp, Function}, A)`](@ref reduce)
- [`select(op::Union{SelectOp, Function}, A)`](@ref select)

!!! note "Built-in vs User-defined operators"

    GraphBLAS supports both built-in and user-defined operators. Built-in operators are precompiled C functions, while user-defined operators are function pointers to Julia functions. 

    Built-in operators are typically much faster than user-defined ones. See the page for the particular operator type (unary, binary, select, etc.) for more information.


## UnaryOps, BinaryOps, Monoids, and Semirings

Each operator is defined on a specific domain. For some this is the usual primitive datatypes like booleans, floats, and signed and unsigned integers of the typical sizes.

### Supported Types

SuiteSparseGraphBLAS.jl natively supports the following types:

- Booleans
- Integers with sizes 8, 16, 32, 64
- Unsigned Integers with sizes 8, 16, 32, 64
- Float32 and Float64
- ComplexF32 and ComplexF64

### Lowering

Operators are lowered from a Julia function to a container like `BinaryOp` or `Semiring`. After this they are lowered once again using the type to a `TypedBinaryOp`, `TypedSemiring`, etc. The `TypedBinaryOp` contains the reference to the C-side GraphBLAS operator. Typed operators, like `TypedSemiring` are constants, found in a submodule (`SuiteSparseGraphBLAS.Semirings` in the case of `TypedSemiring`s).

```@setup operators
using SuiteSparseGraphBLAS
```
```@repl operators
b = BinaryOp(+)
b(Int32)

s = Semiring(max, +)
s(Float64)
```

All operations should accept the function/tuple form, the `Semiring{typeof(max), typeof(+)}` form, or the `TypedSemiring` form.
Unless you need to specifically cast the arguments to a specific type there is generally no need to use the latter two forms.

You can determine the the input and output types of a type-specific operator with the functions below:

```@docs
xtype
ytype
ztype
```

Some examples of these functions are below. 
Note the difference between `ISGT` which returns a result with the same type as the input, and `GT` which returns a `Boolean`.

```@repl operators
xtype(Semirings.LOR_GT_UINT16)
ztype(Semirings.LOR_GT_FP64)
xtype(BinaryOps.ISGT_INT8)
ztype(BinaryOps.ISGT_INT8)
ztype(BinaryOps.GT_INT8)
```

## SelectOps

The [`SelectOp`](@ref) is a SuiteSparse extension to the specification, although a similar construct is likely to be found in a future specification.
Unlike the other operators there are no type-specific operators, and as such you cannot index into them with types to obtain a type-specific version.
