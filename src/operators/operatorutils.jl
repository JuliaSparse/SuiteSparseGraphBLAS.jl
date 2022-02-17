function optype(atype, btype)
    #If atype is signed, optype must be signed and at least big enough.
    if atype <: Integer || btype <: Integer
        if atype <: Signed || btype <: Signed
            p = promote_type(atype, btype)
            if p <: Integer
                return signed(p)
            else
                return p
            end
        else
            return promote_type(atype, btype)
        end
    else
        return promote_type(atype, btype)
    end
end
optype(::GBArray{T}, ::GBArray{U}) where {T, U} = optype(T, U)

const Utypes = (:UInt8, :UInt16, :UInt32, :UInt64)
const Itypes = (:Int8, :Int16, :Int32, :Int64, :UInt8, :UInt16, :UInt32, :UInt64)
const Ftypes = (:Float32, :Float64)
const IFtypes = (Itypes..., Ftypes...)
const Ztypes = (:ComplexF32, :ComplexF64)
const FZtypes = (Ftypes..., Ztypes...)
const Rtypes = (Itypes..., Ftypes..., :Bool)
const nBtypes = (Itypes..., FZtypes...)
const Ntypes = (:Int64, ) # :Int32 as well, but can't disambiguate, and hopefully unecessary
const Ttypes = (Rtypes..., Ztypes...)
function symtotype(sym)
    if sym === :I
        return Itypes
    elseif sym === :F
        return Ftypes
    elseif sym === :Z
        return Ztypes
    elseif sym === :R
        return Rtypes
    elseif sym === :N
        return Ntypes
    elseif sym === :FZ
        return FZtypes
    elseif sym === :T
        return Ttypes
    elseif sym === :nB
        return nBtypes
    elseif sym === :IF
        return IFtypes
    elseif sym === :U
        return Utypes
    else
        return sym
    end
end

function juliaop end
# """
#     validtypes(operator::AbstractOp)::Vector{DataType}
#     validtypes(operator::SelectOp)::Nothing
# 
# Determine the types available as a domain for a particular operator.
# Each operator is defined on a specific set of types, for instance the [`Semirings.LAND_LOR`](@ref)
#     semiring is only defined for `Boolean` arguments.
# 
# When applied to an `AbstractSelectOp` this will return `nothing`.
# When applied to certain operators like positional semirings it will return `[Any]`.
# """
# function validtypes(o::AbstractOp)
#     if !_isloaded(o)
#         _load(o)
#     end
#     return collect(keys(o.typedops))
# end
# 
# function Base.getindex(o::AbstractOp, t::DataType)
#     _isloaded(o) || _load(o)
#     if Any ∈ keys(o.typedops)
#         getindex(o.typedops, Any)
#     else
#         if !haskey(o.typedops, t)
#             addtoop(o, t)
#         end
#         getindex(o.typedops, t)
#     end
# end
# 
# function Base.getindex(o::Union{AbstractSemiring, AbstractBinaryOp}, t1::DataType, t2::DataType)
#     _isloaded(o) || _load(o)
#     if (Any, Any) ∈ keys(o.typedops)
#         getindex(o.typedops, (Any, Any))
#     else
#         if !haskey(o.typedops, (t1, t2))
#             addtoop(o, t1, t2)
#         end
#         getindex(o.typedops, (t1, t2))
#     end
# end
# Base.getindex(o::Union{AbstractSemiring, AbstractBinaryOp}, tup::Tuple{DataType, DataType}) = o[tup...]
# Base.getindex(o::Union{AbstractBinaryOp, AbstractSemiring}, t::DataType) = o[t, t]
# 
# Base.setindex!(o::Union{AbstractSemiring, AbstractBinaryOp}, x, tup::Tuple{DataType, DataType}) = setindex!(o.typedops, x, tup)
# Base.setindex!(o::Union{AbstractSemiring, AbstractBinaryOp}, x, t1::DataType, t2::DataType) = setindex!(o, x, (t1, t2))
# Base.setindex!(o::Union{AbstractSemiring, AbstractBinaryOp}, x, t::DataType) = setindex!(o, x, (t, t))
# 
# function addtoop(op::AbstractUnaryOp, type)
#     f = Base.invokelatest(juliaop, op)
#     resulttypes = Base.return_types(f, (type,))
#     if length(resulttypes) != 1
#         throw(ArgumentError("Inferred more than one result type for function $(string(f)) on type $type."))
#     end
#     UnaryOps._addunaryop(op, f, resulttypes[1], type)
# end
# 
# function addtoop(op::AbstractBinaryOp, type1, type2)
#     f = Base.invokelatest(juliaop, op)
#     resulttypes = Base.return_types(f, (type1, type2))
#     if length(resulttypes) != 1
#         throw(ArgumentError("Inferred more than one result type for function $(string(f)) on type $type."))
#     end
#     BinaryOps._addbinaryop(op, f, resulttypes[1], type1, type2)
# end
# addtoop(op::AbstractBinaryOp, type) = addtoop(op, type, type)

# function Base.show(io::IO, ::MIME"text/plain", o::AbstractOp)
#     print(io, o.name, ": ", validtypes(o))
# end


# returntype(A, B, )