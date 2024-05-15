const GBVecOrMat{T, O} = Union{AbstractGBVector{T, O}, AbstractGBMatrix{T, O}}
const GBMatrixOrTranspose{T, O} = Union{AbstractGBMatrix{T, O}, Transpose{<:Any, <:AbstractGBMatrix{T, O}}}
const GBVectorOrTranspose{T, O} = Union{AbstractGBVector{T, O}, Transpose{<:Any, <:AbstractGBVector{T, O}}}
const GBArrayOrTranspose{T, O} = Union{AbstractGBArray{T, O}, Transpose{<:Any, <:AbstractGBArray{T, O}}}
const VecMatOrTrans = Union{DenseVecOrMat, Transpose{<:Any, <:DenseVecOrMat}}

const ALL = GBAllType(C_NULL)
