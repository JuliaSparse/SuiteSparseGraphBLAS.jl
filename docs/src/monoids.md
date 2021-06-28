# Monoids
## About

A monoid is made up of a set or domain $T$ and a binary operator $z = f(x, y)$ operating on the same domain, $T \times T \rightarrow T$.
This binary operator must be associative, that is $f(a, f(b, c)) = f(f(a, b), c)$ is always true. Associativity is important for operations like `reduce` and the multiplication step of `mul`.

The operator must also be equipped with an identity such that $f(x, 0) = f(0, x) = x$. Some monoids are equipped with a terminal or annihilator such that $z = f(z, x) \forall x$.

## Built-Ins
!!! note "Note"
    In the case of floating point numbers +∞ and -∞ have their typical meanings. However, for integer types they indicate `typemax` and `typemin` respectively.

```@autodocs
Modules = [SuiteSparseGraphBLAS]
Pages   = ["monoids.jl"]
```