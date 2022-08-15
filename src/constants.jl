const GBVecOrMat{T} = Union{<:AbstractGBVector{T}, <:AbstractGBMatrix{T}}
const GBMatOrTranspose{T} = Union{<:AbstractGBMatrix{T}, Transpose{T, <:AbstractGBMatrix{T}}}
const GBVecOrTranspose{T} = Union{<:AbstractGBVector{T}, Transpose{T, <:AbstractGBVector{T}}}
const GBArray{T} = Union{<:GBVecOrTranspose{T}, <:GBMatOrTranspose{T}}

const GBMatrixOrTranspose{T} = Union{<:GBMatrix{T}, Transpose{T, <:GBMatrix{T}}}
const GBVectorOrTranspose{T} = Union{<:GBVector{T}, Transpose{T, <:GBVector{T}}}
const AbsGBArrayOrTranspose{T} = Union{<:AbstractGBArray{T}, Transpose{T, <:AbstractGBArray{T}}}

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