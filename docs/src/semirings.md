# Semirings
## About

A semiring in GraphBLAS is a domain $T$ along with two binary operators. The first, $\oplus$ or "add" is a commutative and associative monoid. The second, $\otimes$ or "multiply", is a binary operator `z = f(x, y)` such that the monoid type matches the type of `z`.

## Built-Ins
```@eval
using Pkg
Pkg.activate("..")
cd("..")
using SuiteSparseGraphBLAS
using Latexify
head = ["Semiring", "⊕", "⊗", "Types"]
v1 = filter((x) -> x != "Semirings", string.(names(Semirings)))
v2 = "[" .* getindex.(split.(v1, '_'),1) .* "_MONOID](@ref)"
v3 = "[" .* getindex.(split.(v1, '_'), 2) .* "](@ref)"
v4 = []
v1 = "`" .* v1 .* "`"
for op in names(Semirings)
    op == :Semirings && continue
    op = getproperty(Semirings, op)
    push!(v4, SuiteSparseGraphBLAS.validtypes(op))
end
Latexify.mdtable(hcat(v1,v2,v3,v4); head, latex=false)
```