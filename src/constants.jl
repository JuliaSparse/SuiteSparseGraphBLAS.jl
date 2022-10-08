const GBVecOrMat{T, F, O} = Union{AbstractGBVector{T, F, O}, AbstractGBMatrix{T, F, O}}
const GBMatrixOrTranspose{T, F, O} = Union{AbstractGBMatrix{T, F, O}, Transpose{<:Any, <:AbstractGBMatrix{T, F, O}}}
const GBVectorOrTranspose{T, F, O} = Union{AbstractGBVector{T, F, O}, Transpose{<:Any, <:AbstractGBVector{T, F, O}}}
const GBArrayOrTranspose{T, F, O} = Union{AbstractGBArray{T, F, O}, Transpose{<:Any, <:AbstractGBArray{T, F, O}}}
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