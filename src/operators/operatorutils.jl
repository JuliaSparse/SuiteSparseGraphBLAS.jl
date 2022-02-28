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