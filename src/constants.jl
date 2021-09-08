const GBVecOrMat{T} = Union{GBVector{T}, GBMatrix{T}}
const GBMatOrTranspose{T} = Union{GBMatrix{T}, Transpose{T, GBMatrix{T}}}
const GBVecOrTranspose{T} = Union{GBVector{T}, Transpose{T, GBVector{T}}}
const GBArray{T} = Union{GBVecOrTranspose{T}, GBMatOrTranspose{T}}
const ptrtogbtype = Dict{Ptr, AbstractGBType}()

const GrBOp = Union{
    libgb.GrB_Monoid,
    libgb.GrB_UnaryOp,
    libgb.GrB_Semiring,
    libgb.GrB_BinaryOp,
    libgb.GxB_SelectOp
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
