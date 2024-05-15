function GB_promote(atype, btype)
    #If atype is signed, GB_promote must be signed and at least big enough.
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
# GB_promote(::GBArrayOrTranspose{T}, ::GBArrayOrTranspose{U}) where {T, U} = GB_promote(T, U)

"""
    inputisany(f) -> Bool

Returns `true` if `f` can operate over any data type, `false` otherwise.
"""
inputisany(x) = false

const Utypes = (UInt8, UInt16, UInt32, UInt64)
const Itypes = (Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32, UInt64)
const Ftypes = (Float32, Float64)
const IFtypes = (Itypes..., Ftypes...)
const Ztypes = (ComplexF32, ComplexF64)
const FZtypes = (Ftypes..., Ztypes...)
const Rtypes = (Itypes..., Ftypes..., Bool)
const nBtypes = (Itypes..., FZtypes...)
const Ntypes = (Int64, ) # :Int32 as well, but can't disambiguate, and hopefully unecessary
const Ttypes = (Rtypes..., Ztypes...)


const Usyms = Symbol.(Utypes)
const Isyms = Symbol.(Itypes)
const Fsyms = Symbol.(Ftypes)
const IFsyms = Symbol.(IFtypes)
const Zsyms = Symbol.(Ztypes)
const FZsyms = Symbol.(FZtypes)
const Rsyms = Symbol.(Rtypes)
const nBsyms = Symbol.(nBtypes)
const Nsyms = Symbol.(Ntypes)
const Tsyms = Symbol.(Ttypes)

const Uunion = Union{Utypes...}
const Iunion = Union{Itypes...}
const Funion = Union{Ftypes...}
const IFunion = Union{IFtypes...}
const Zunion = Union{Ztypes...}
const FZunion = Union{FZtypes...}
const Runion = Union{Rtypes...}
const nBunion = Union{nBtypes...}
const Nunion = Union{Ntypes...}
const Tunion = Union{Ttypes...}

function symtotype(sym)
    if sym === :I
        return Isyms
    elseif sym === :F
        return Fsyms
    elseif sym === :Z
        return Zsyms
    elseif sym === :R
        return Rsyms
    elseif sym === :N
        return Nsyms
    elseif sym === :FZ
        return FZsyms
    elseif sym === :T
        return Tsyms
    elseif sym === :nB
        return nBsyms
    elseif sym === :IF
        return IFsyms
    elseif sym === :U
        return Usyms
    else
        return sym
    end
end
