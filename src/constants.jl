const GBVecOrMat{T} = Union{<:AbstractGBVector{T}, <:AbstractGBMatrix{T}}
const GBMatrixOrTranspose{T} = Union{<:AbstractGBMatrix{T}, Transpose{T, <:AbstractGBMatrix{T}}}
const GBVectorOrTranspose{T} = Union{<:AbstractGBVector{T}, Transpose{T, <:AbstractGBVector{T}}}
const GBArrayOrTranspose{T} = Union{<:AbstractGBArray{T}, Transpose{T, <:AbstractGBArray{T}}}

const VecMatOrTrans = Union{<:DenseVecOrMat, <:Transpose{<:Any, <:DenseVecOrMat}}
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