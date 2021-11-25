# Unary Operators

`UnaryOp`s are fairly straightforward $z = f(x)$ and their meaning should be clear from the name in most cases. 

`UnaryOp`s are used only in the [`map`](@ref) function, for example:

```@repl
using SuiteSparseGraphBLAS

x = GBVector([1.5, 0, pi])

y = map(UnaryOps.SIN, x)

map(UnaryOps.ASIN, y)

```

## Built-Ins

```@eval
using Pkg
Pkg.activate("..")
cd("..")
using SuiteSparseGraphBLAS
using Latexify
head = ["UnaryOp", "Function Form", "Types"]
v1 = filter((x) -> getproperty(UnaryOps, x) isa SuiteSparseGraphBLAS.AbstractUnaryOp, names(UnaryOps))
ops = getproperty.(Ref(UnaryOps), v1)
v2 = convert(Vector{Any}, SuiteSparseGraphBLAS.juliaop.(ops))
v4 = SuiteSparseGraphBLAS.validtypes.(ops)

v1 = "`" .* string.(v1) .* "`"
v2 = "`" .* string.(v2) .* "`"
Latexify.mdtable(hcat(v1,v2,v4); head, latex=false)
```