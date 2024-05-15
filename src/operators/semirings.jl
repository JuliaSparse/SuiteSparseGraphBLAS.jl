module Semirings
import ..GrB
import ..GrB: isGxB, isGrB, Utypes,
    builtin_vec, GrB_Type, symtotype, Itypes, Ftypes, Ztypes, FZtypes, IFtypes,
    Rtypes, Ntypes, Ttypes, nBtypes, suffix,  
    second, rminus, ispair, ∨, ∧, lxor, xnor, bxnor, bget, bset,
    bclr, firsti0, firsti, firstj0, firstj, secondi0, 
    secondi, secondj0, secondj,
    builtin_union, inputisany, isGrB, isGxB,
    Uunion, Iunion, Funion, IFunion, Zunion, FZunion, Runion, nBunion, Nunion, Tunion, 
    GB_promote, GxB_fprint, Monoids, Monoids.defaultmonoid,
    Monoids.GrB_Monoid, BinaryOps, 
    BinaryOps.BinaryOp, load_global, storedeltype, LibGraphBLAS, gxbprint, domains

export Semiring

mutable struct Semiring{X, Y, Z, M, B}
    const builtin::Bool
    loaded::Bool
    const typestr::String
    p::LibGraphBLAS.GrB_Semiring
    addop::M
    mulop::B
    function Semiring(
        builtin, loaded, typestr, p, 
        addop::Monoids.GrB_Monoid{FA, Z}, mulop::BinaryOp{FM, F2, X, Y, Z}
    ) where {FA, FM, F2, X, Y, Z}
        semiring = new{X, Y, Z, typeof(addop), typeof(mulop)}(builtin, loaded, typestr, p, addop, mulop)
        return finalizer(semiring) do rig
            GrB.@checkfree LibGraphBLAS.GrB_Semiring_free(Ref(rig.p))
        end
    end
end

domains(::BinaryOp{X, Y, Z}) where {X, Y, Z} = (X, Y) => Z

function (op::Semiring)(::Type{T1}, ::Type{T2}) where {T1, T2}
    return op
end

function Base.unsafe_convert(::Type{LibGraphBLAS.GrB_Semiring}, rig::Semiring)
    if !rig.loaded
        if rig.builtin
            rig.p = load_global(rig.typestr, LibGraphBLAS.GrB_Semiring)
        else
            opref = Ref{LibGraphBLAS.GrB_Semiring}()
            info = LibGraphBLAS.GrB_Semiring_new(opref, rig.addop, rig.mulop)
            if info != LibGraphBLAS.GrB_SUCCESS
                GrB.@domainmismatch info rig.addop rig.mulop
                GrB.@uninitializedobject info rig.mulop, rig.addop
                GrB.@fallbackerror info
            end
            rig.p = opref[]
        end
        rig.loaded = true
    end
    if !rig.loaded
        error("This operator could not be loaded, and is invalid.")
    else
        return rig.p
    end
end

function GrB.nothrow_wait!(op::Semiring, mode) 
    return LibGraphBLAS.GrB_Semiring_wait(op, mode)
end
function GrB.wait!(op::Semiring, mode) 
    info = GrB.nothrow_wait!(op, mode)
    if info != LibGraphBLAS.GrB_SUCCESS
        # Technically pending OOB can throw here, but I don't see how on a Monoid.
        GrB.@invalidvalue info mode
        GrB.@uninitializedobject info op
        GrB.@fallbackerror info
    end
end

Semiring(addop, mulop) = Semiring(false, false, "", LibGraphBLAS.GrB_Semiring(), addop, mulop)

const SEMIRINGS = IdDict{Any, Semiring}()
const BUILTINSEMIRINGS = IdDict{Any, Any}() # semiring tuple -> name, datatype

Semiring(ops::Tuple, ::Type{T}, ::Type{U}, ::Type{V}) where {T, U, V} = Semiring(ops..., T, U, V)
Semiring(ops::Tuple, ::Type{T}) where {T} = Semiring(ops..., T, T, T)
Semiring(addop, mulop ::Type{T}) where {T} = Semiring(addop, mulop, T, T, T)
Semiring(ops::Tuple, A::AbstractArray, B::AbstractArray, ::Type{V}) where {V} = Semiring(ops..., storedeltype(A), storedeltype(B), V)

Semiring(s::Semiring, x...) = s

function Semiring(addop, mulop, ::Type{T}, ::Type{U}, ::Type{V}) where {T, U, V}
    t, u = inputisany(mulop) ? (Any, Any) : (T, U)
    binop = BinaryOp(mulop, t, u, V)
    monoid = defaultmonoid(addop, V)
    return get!(SEMIRINGS, (monoid, binop, T, U)) do
        if t == u && t <: builtin_union
            builtin = isbuiltinsemiring(addop, mulop, t)
            name = "GxB_$(gbname(addop))_$(gbname(mulop))_$(suffix(t))"
        else
            builtin = false
        end
        if !builtin
            name = string(addop, mulop, "_$(T)_$(U)_SEMIRING")
        end
        return Semiring(
            builtin, false, name, LibGraphBLAS.GrB_Semiring(),
            GrB_Monoid(monoid, V), binop
        )
    end
end

function isbuiltinsemiring(addop, mulop, ::Type{T}) where {T <: builtin_union}
    if addop ∈ (min, max, +, *, any)
        if mulop ∈  (firsti, firsti0, secondi, secondi0, firstj, firstj0, secondj, secondj0) ||
            (mulop ∈ (
                first, second, ispair, min, max, +, -, rminus, *, /, \, 
                #=iseq, isne, isgt, islt, isge, isle,=# ∨, ∧, lxor
            ) && T <: IFunion)
                return true
        end
    end
    if addop ∈ (∧, ∨, lxor, ==, any) && mulop ∈ (==, !=, >, <, >=, <=) && T <: IFunion
        return true
    elseif addop ∈ (∧, ∨, lxor, ==, any) &&
        mulop ∈ (first, second, ispair, ∨, ∧, lxor, >, <, >=, <=) && t === Bool
        return true
    elseif T <: Complex && addop ∈ (+, *, any) && mulop ∈ (first, second, ispair, +, -, *, /, \, rminus)
        return true
    elseif T <: Uunion && addop ∈ (|, &, ⊻, bxnor) && mulop ∈ (|, &, ⊻, bxnor)
        return true
    end
    return false
end

function GrB.GxB_fprint(x::Semiring, name, level, file)
    info = LibGraphBLAS.GxB_Semiring_fprint(x, name, level, file)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info x
        GrB.@fallbackerror info
    end
end
function Base.show(io::IO, ::MIME"text/plain", t::Semiring{X, Y, Z, M, B}) where {X, Y, Z, M, B}
    print(io, "GrB_Semiring{$(string(M))($Z, $Z) -> $Z, $(string(B))($X, $Y) -> $Z}: ")
    gxbprint(io, t)
end

gbname(f) = uppercase(string(f))
gbname(::typeof(+)) = "PLUS"
gbname(::typeof(-)) = "MINUS"
gbname(::typeof(*)) = "TIMES"
gbname(::typeof(/)) = "DIV"
gbname(::typeof(\)) = "RDIV"
gbname(::typeof(∨)) = "LOR"
gbname(::typeof(∧)) = "LAND"
gbname(::typeof(==)) = "EQ"
gbname(::typeof(!=)) = "NE"
gbname(::typeof(>)) = "GT"
gbname(::typeof(<)) = "LT"
gbname(::typeof(>=)) = "GE"
gbname(::typeof(<=)) = "LE"
gbname(::typeof(⊻)) = "BXOR"
gbname(::typeof(|)) = "BOR"
gbname(::typeof(&)) = "BAND"
gbname(::typeof(firsti0)) = "FIRSTI" 
gbname(::typeof(firsti)) = "FIRSTI1" 
gbname(::typeof(firstj0)) = "FIRSTJ" 
gbname(::typeof(firstj)) = "FIRSTJ1" 
gbname(::typeof(secondi0)) = "SECONDI" 
gbname(::typeof(secondi)) = "SECONDI1" 
gbname(::typeof(secondj0)) = "SECONDJ" 
gbname(::typeof(secondj)) = "SECONDJ1"
end
