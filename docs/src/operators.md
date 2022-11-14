# Operators

Operators are one of the basic objects of GraphBLAS. In Julia, however, users must only interact directly with operators on rare occasions, and should instead pass functions to GraphBLAS operations.

There are five operator types in SuiteSparseGraphBLAS: `UnaryOp`, `IndexUnaryOp`, `BinaryOp`, `Monoid`, and `Semiring`.

!!! danger "Note"
    Operators are **not** callable objects like functions. They **do** behave like functions when used as arguments to higher-order functions ([Operations](@ref) in the language of GraphBLAS).

    Operators are no longer first class objects in SuiteSparseGraphBLAS.jl v0.8. Only Monoids
    and possibly [`IndexOp`](@ref) require direct user interaction.

Typically operators are positional arguments in one of two places.
For operations with a clear default operator they appear as the last positional argument:

- [`emul(A, B, op::Function)`](@ref emul)
- [`eadd(A, B, op::Function)`](@ref eadd)
- [`kron(A, B, op::Function)`](@ref kron)
- [`*(A, B, op::Tuple{Function, Function})`](@ref *)

For other operations without a clear default operator they appear as the first argument:

- [`apply(op::Function, A)`](@ref apply)
- [`reduce(op::Union{Monoid, Function}, A)`](@ref reduce)
- [`select(op::Union{SelectOp, Function}, A)`](@ref select)

!!! note "Built-in vs User-defined operators"

    GraphBLAS supports both built-in and user-defined operators. Built-in operators are precompiled C functions, while user-defined operators are function pointers to Julia functions. 

    Built-in operators are typically much faster than user-defined ones. See the page for the particular operator type (unary, binary, select, etc.) for more information.

!!! danger "User Defined Closure Functions"
    Due to Julia limitations on the `aarch64` and `ppc64` architectures it is not possible to use closure functions, or callable
    objects as operators in `SuiteSparseGraphBLAS.jl`

## UnaryOps, IndexUnaryOps, BinaryOps, Monoids, and Semirings

Each operator is defined on a specific domain. For some this is the usual primitive datatypes like booleans, floats, and signed and unsigned integers of the typical sizes.

### Natively Supported Types

SuiteSparseGraphBLAS.jl natively supports the following types:

- Booleans
- Integers with sizes 8, 16, 32, 64
- Unsigned Integers with sizes 8, 16, 32, 64
- Float32 and Float64
- ComplexF32 and ComplexF64

Users may freely use non-native `isbitstypes` as well, although they will incur a performance penalty.