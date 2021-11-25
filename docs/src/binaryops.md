# Binary Operators

Binary operators are defined on three domains $D_1 \times D_2 \rightarrow D_3$.
However, the vast majority of binary operators are defined on a single domain.

## Built-Ins

All built-in binary operators can be found in the `BinaryOps` submodule.

```@eval
using Pkg
Pkg.activate("..")
cd("..")
using SuiteSparseGraphBLAS
using Latexify
head = ["UnaryOp", "Function Form", "Types"]
v1 = filter((x) -> getproperty(BinaryOps, x) isa SuiteSparseGraphBLAS.AbstractBinaryOp, names(BinaryOps))
ops = getproperty.(Ref(BinaryOps), v1)
v2 = convert(Vector{Any}, SuiteSparseGraphBLAS.juliaop.(ops))
v4 = SuiteSparseGraphBLAS.validtypes.(ops)

v1 = "`" .* string.(v1) .* "`"
v2 = "`" .* string.(v2) .* "`"
Latexify.mdtable(hcat(v1,v2,v4); head, latex=false)
```