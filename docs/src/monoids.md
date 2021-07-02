# Monoids

A monoid is made up of a set or domain $T$ and a binary operator $z = f(x, y)$ operating on the same domain, $T \times T \rightarrow T$.
This binary operator must be associative, that is $f(a, f(b, c)) = f(f(a, b), c)$ is always true. Associativity is important for operations like `reduce` and the multiplication step of `mul`.

The operator is also be equipped with an identity such that $f(x, 0) = f(0, x) = x$. Some monoids are equipped with a terminal or annihilator such that $z = f(z, x) \forall x$.

Monoids are used primarily in the `reduce`(@ref) operation. Their other use is as a component of semirings in the [`mul`](@ref) operation.

## Built-Ins

All built-in monoids can be found in the `Monoids` submodule.

The documentation below uses `T` to refer to any of the valid primitive types listed in [Supported Types](@ref), `ℤ` to refer to integers (signed and unsigned), `F` to refer to floating point types, `ℝ` to refer to real numbers (non-complex numbers).

!!! note "Note"
    In the case of floating point numbers +∞ and -∞ have their typical meanings. However, for integer types they indicate `typemax` and `typemin` respectively.

```@autodocs
Modules = [SuiteSparseGraphBLAS]
Pages   = ["monoids.jl"]
```