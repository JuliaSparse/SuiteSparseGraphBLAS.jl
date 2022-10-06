const GBVecOrMat{T, F} = Union{AbstractGBVector{T, F}, AbstractGBMatrix{T, F}}
const GBMatrixOrTranspose{T, F} = Union{AbstractGBMatrix{T, F}, Transpose{<:Any, <:AbstractGBMatrix{T, F}}}
const GBVectorOrTranspose{T, F} = Union{AbstractGBVector{T, F}, Transpose{<:Any, <:AbstractGBVector{T, F}}}
const GBArrayOrTranspose{T, F} = Union{AbstractGBArray{T, F}, Transpose{<:Any, <:AbstractGBArray{T, F}}}
const VecMatOrTrans = Union{DenseVecOrMat, Transpose{<:Any, <:DenseVecOrMat}}
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