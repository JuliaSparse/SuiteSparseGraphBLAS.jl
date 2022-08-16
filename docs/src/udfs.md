# User Defined Operators

!!! warning "Experimental"
    This is still a work in progress, and subject to change. Please open an issue if you find any problems!

GraphBLAS supports users to supply functions as operators. Constructors exported are:

- `UnaryOp(name::String, fn::Function, [type | types | ztype, xtype | ztypes, xtypes])`
- `BinaryOp(name::String, fn::Function, [type | types | ztype, xtype | ztypes, xtypes])`
- `Monoid(name::String, binop::Union{GrB_BinaryOp}, id::T, terminal::T = nothing)`: all types must be the same.
- `Semiring(name::String, add::[GrB_Monoid | AbstractMonoid], mul::GrB_BinaryOp)`

`GrB_` prefixed arguments are typed operators, such as the result of `UnaryOps.COS[Float64]`.
Type arguments may be single types or vectors of types.
If no type is supplied to `UnaryOp` or `BinaryOp` they will default to constructing typed operators for all the built-in primitive types.

The `fn` arguments to `UnaryOp` and `BinaryOp` must have one or two arguments respectively.

!!! danger "Performance"
    Due to the nature of the underlying C library user-defined operators may be significantly slower than their built-in counterparts.
    When possible use the built-in operators, or combinations of them.

!!! note "Where to Find User-Defined Operators"
    The constructors for an operator add that operator to the submodule for that operator type.
    For instance `UnaryOp(minus, -, Int64, Int64)` will add `UnaryOps.minus`.

