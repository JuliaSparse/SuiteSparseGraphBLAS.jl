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

```@autodocs
Modules = [SuiteSparseGraphBLAS]
Pages   = ["unaryops.jl"]
```