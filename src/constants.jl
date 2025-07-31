const ptrtogbtype = IdDict{Ptr, GBType}()

const GrBOp = Union{
    LibGraphBLAS.GrB_Monoid,
    LibGraphBLAS.GrB_UnaryOp,
    LibGraphBLAS.GrB_Semiring,
    LibGraphBLAS.GrB_BinaryOp,
    LibGraphBLAS.GxB_SelectOp
}

const TypedOp = Union{
    TypedUnaryOperator,
    TypedBinaryOperator,
    TypedMonoid,
    TypedSemiring
}

const MonoidBinaryOrRig = Union{
    TypedMonoid,
    TypedSemiring,
    TypedBinaryOperator,
    AbstractMonoid
}

const OperatorUnion = Union{
    AbstractOp,
    GrBOp
}

const ALL = GBAllType(C_NULL)
