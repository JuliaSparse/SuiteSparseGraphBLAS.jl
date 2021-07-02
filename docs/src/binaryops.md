# Binary Operators

Binary operators are defined on three domains $D_1 \times D_2 \rightarrow D_3$.
However, the vast majority of binary operators are defined on a single domain.

## Built-Ins

All built-in binary oeprators can be found in the `BinaryOps` submodule.

The documentation below uses `T` to refer to any of the valid primitive types listed in [Supported Types](@ref), `ℤ` to refer to integers (signed and unsigned), `F` to refer to floating point types, `ℝ` to refer to real numbers (non-complex numbers).

```@autodocs
Modules = [SuiteSparseGraphBLAS]
Pages   = ["binaryops.jl"]
```