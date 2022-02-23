const GBVecOrMat{T} = Union{GBVector{T}, GBMatrix{T}}
const GBMatOrTranspose{T} = Union{GBMatrix{T}, Transpose{T, GBMatrix{T}}}
const GBVecOrTranspose{T} = Union{GBVector{T}, Transpose{T, GBVector{T}}}
const GBArray{T} = Union{GBVecOrTranspose{T}, GBMatOrTranspose{T}}
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
    AbstractSemiring,
    AbstractBinaryOp,
    AbstractMonoid
}

const OperatorUnion = Union{
    AbstractOp,
    GrBOp
}

const ALL = GBAllType(C_NULL)