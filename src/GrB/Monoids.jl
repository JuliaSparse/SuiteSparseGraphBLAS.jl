module Monoids

import ..GrB
import ..GrB: isGxB, isGrB,
    builtin_vec, symtotype, Itypes, Ftypes, Ztypes, FZtypes, Rtypes, 
    Ntypes, nBtypes, Ttypes, suffix, BinaryOps, BinaryOps.BinaryOp, ∨, 
    ∧, lxor, xnor, bxnor, builtin_union, domains,
    gxb_vec, load_global, LibGraphBLAS, GxB_fprint, gxbprint, Monoid, SuiteSparseGraphBLAS

domains(::Monoid{T}) where {T} = (T, T) => T

BinaryOps.BinaryOp(m::Monoid) = m.binaryop

function (op::Monoid{F, Z, T})(::Type{X}) where {F, X, Z, T}
    return op
end

for Z ∈ builtin_vec
    if Z ∈ gxb_vec
        prefix = :GxB
    else
        prefix = :GrB
    end
    # Build functions
    func = Symbol(prefix, :_Monoid_new_, suffix(Z))
    functerm = Symbol(:GxB_Monoid_terminal_new_, suffix(Z))
    @eval begin
        function _monoidnew!(monoid::Monoid{F, $Z}) where F
            opref = Ref{LibGraphBLAS.GrB_Monoid}()
            if op.terminal === nothing
                info = LibGraphBLAS.$func(opref, monoid.binaryop, monoid.identity)
            else
                info = LibGraphBLAS.$functerm(opref, monoid.binaryop, monoid.identity, monoid.terminal)
            end
            if info != LibGraphBLAS.GrB_SUCCESS
                GrB.@domainmismatch info monoid.binaryop monoid.identity monoid.terminal
                GrB.@uninitializedobject info monoid.binaryop
                GrB.@fallbackerror info
            end
            op.p = opref[]
        end
    end
end

function _monoidnew!(monoid::Monoid)
    opref = Ref{LibGraphBLAS.GrB_Monoid}()
    if monoid.terminal === nothing
        info = LibGraphBLAS.GrB_Monoid_new_UDT(opref, monoid.binaryop, Ref(monoid.identity))
    else
        info = LibGraphBLAS.GxB_Monoid_terminal_new_UDT(opref, monoid.binaryop, Ref(monoid.identity), Ref(monoid.terminal))
    end
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@domainmismatch info monoid.binaryop monoid.identity monoid.terminal
        GrB.@uninitializedobject info monoid.binaryop
        GrB.@fallbackerror info
    end
    monoid.p = opref[]
end

function GrB.nothrow_wait!(op::Monoid, mode) 
    return LibGraphBLAS.GrB_Monoid_wait(op, mode)
end
function GrB.wait!(op::Monoid, mode) 
    info = GrB.nothrow_wait!(op, mode)
    if info != LibGraphBLAS.GrB_SUCCESS
        # Technically pending OOB can throw here, but I don't see how on a Monoid.
        GrB.@invalidvalue info mode
        GrB.@uninitializedobject info op
        GrB.@fallbackerror info
    end
end

function Base.unsafe_convert(::Type{LibGraphBLAS.GrB_Monoid}, op::Monoid)
    if !op.loaded
        if op.builtin
            op.p = load_global(op.typestr, LibGraphBLAS.GrB_Monoid)
        else
            _monoidnew!(op)
        end
        op.loaded = true
    end
    if !op.loaded
        error("This operator could not be loaded, and is invalid.")
    else
        return op.p
    end
end

function _builtinMonoid(typestr, binaryop::BinaryOp{F, F2, Z, Z, Z}, identity, terminal::T) where {F, F2, Z, T}
    return Monoid(true, false, typestr, LibGraphBLAS.GrB_Monoid(), binaryop, identity, terminal)
end

function Monoid(binop::BinaryOp{F, F2, Z, Z, Z}, identity, terminal::T) where {F, F2, Z, T}
    return Monoid(false, false, string(binop.fn), LibGraphBLAS.GrB_Monoid(), binop, convert(Z, identity), terminal)
end

#Enable use of functions for determining identity and terminal values. Could likely be pared down to 2 functions somehow.
Monoid(builtin, loaded, typestr, p, binaryop::BinaryOp{F, F2, Z, Z, Z}, identity::Function, terminal::Function) where {F, F2, Z} =
    Monoid(builtin, loaded, typestr, p, binaryop, identity(Z), terminal(Z))

Monoid(builtin, loaded, typestr, p, binaryop::BinaryOp{F, F2, Z, Z, Z}, identity::Function, terminal::Nothing) where {F, F2, Z} =
    Monoid(builtin, loaded, typestr, p, binaryop, identity(Z), terminal)

Monoid(binop::BinaryOp{F, F2, Z, Z, Z}, identity::Function) where {F, F2, Z} = Monoid(binop, identity(Z))
Monoid(binop::BinaryOp{F, F2, Z, Z, Z}, identity::Function, terminal::Function) where {F, F2, Z} = Monoid(binop, identity(Z), terminal(Z))
Monoid(binop::BinaryOp{F, F2, Z, Z, Z}, identity::Function, terminal::Nothing) where {F, F2, Z} = Monoid(binop, identity(Z), terminal)

Monoid(binop::BinaryOp, identity) = Monoid(binop, identity, nothing)


const MONOIDS = IdDict{Any, Monoid}() # (f, identity, [nothing | terminal], datatype) -> monoid
# only one datatype since monoids have 1 domain.
const BUILTINMONOIDS = IdDict{Any, Any}() # (f, identity, [nothing | terminal]) -> name, datatype

# CONTINUE: disaggregate Monoid argument here.
function Monoid(m::SuiteSparseGraphBLAS.Monoid, ::Type{T}) where {T}
    return Base.get!(MONOIDS, (m, T)) do
        builtin_result = Base.get(BUILTINMONOIDS, m, nothing)
        if builtin_result !== nothing
            builtin_name, types = builtin_result
            if T == types || T ∈ types
                builtin_name = string(builtin_name)
                if builtin_name[1:3] == "GxB" || T <: Complex
                    builtin_name = "GxB" * builtin_name[4:end] * "_$(suffix(T))_MONOID"
                else
                    builtin_name = builtin_name * "_MONOID_$(suffix(T))"
                end
                return _builtinMonoid(
                    builtin_name, 
                    BinaryOp(m.fn, T),
                    m.identity, 
                    m.terminal
                )
            end
        end
        return Monoid(BinaryOp(m.fn, T), m.identity, m.terminal)
    end
end

Monoid(op::Monoid, x...) = op


# Use defaultmonoid when available. User should verify that this results in the correct monoid.
Monoid(f, ::Type{T}) where T = Monoid(SuiteSparseGraphBLAS.defaultmonoid(f, T), T)

function GrB.GxB_fprint(x::Monoid, name, level, file)
    info = LibGraphBLAS.GxB_Monoid_fprint(x, name, level, file)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info x
        GrB.@fallbackerror info
    end
end
function Base.show(io::IO, ::MIME"text/plain", t::Monoid{F, Z}) where {F, Z}
    print(io, "GrB_Monoid{$(string(F))($Z, $Z) -> $Z}: ")
    gxbprint(io, t)
end

# We link to the BinaryOp rather than the Julia functions, 
# because users will mostly be exposed to the higher level interface.
const PLUSMONOID = SuiteSparseGraphBLAS.Monoid(+, zero)
SuiteSparseGraphBLAS.defaultmonoid(::typeof(+), ::Type{<:Number}) = PLUSMONOID
BUILTINMONOIDS[PLUSMONOID] = ("GrB_PLUS", nBtypes)

const TIMESMONOID = SuiteSparseGraphBLAS.Monoid(*, one, zero)
SuiteSparseGraphBLAS.defaultmonoid(::typeof(*), ::Type{<:Integer}) = TIMESMONOID
BUILTINMONOIDS[TIMESMONOID] = ("GrB_TIMES", Itypes)

const FLOATTIMESMONOID = SuiteSparseGraphBLAS.Monoid(*, one) # float * monoid doesn't have a terminal.
SuiteSparseGraphBLAS.defaultmonoid(::typeof(*), ::Type{<:Union{Complex, AbstractFloat}}) = FLOATTIMESMONOID
BUILTINMONOIDS[FLOATTIMESMONOID] = ("GrB_TIMES", FZtypes)

# This is technically incorrect. The identity and terminal are *ANY* value in the domain.
# TODO: Users MAY NOT extend the any monoid, and this should be banned somehow.
const ANYMONOID = SuiteSparseGraphBLAS.Monoid(any, one, one)
SuiteSparseGraphBLAS.defaultmonoid(::typeof(any), ::Type{<:builtin_union}) = ANYMONOID
BUILTINMONOIDS[ANYMONOID] = ("GxB_ANY", Ttypes)

const MINMONOID = SuiteSparseGraphBLAS.Monoid(min, typemax, typemin)
SuiteSparseGraphBLAS.defaultmonoid(::typeof(min), ::Type{<:Real}) = MINMONOID
BUILTINMONOIDS[MINMONOID] = ("GrB_MIN", Rtypes)

const MAXMONOID = SuiteSparseGraphBLAS.Monoid(max, typemin, typemax)
SuiteSparseGraphBLAS.defaultmonoid(::typeof(max), ::Type{<:Real}) = MAXMONOID
BUILTINMONOIDS[MAXMONOID] = ("GrB_MAX", Rtypes)

const ORMONOID = SuiteSparseGraphBLAS.Monoid(∨, false, true)
SuiteSparseGraphBLAS.defaultmonoid(::typeof(∨), ::Type{Bool}) = ORMONOID
SuiteSparseGraphBLAS.defaultmonoid(::typeof(+), ::Type{Bool}) = ORMONOID
BUILTINMONOIDS[ORMONOID] = ("GrB_LOR", Bool)

const ANDMONOID = SuiteSparseGraphBLAS.Monoid(∧, true, false)
SuiteSparseGraphBLAS.defaultmonoid(::typeof(∧), ::Type{Bool}) = ANDMONOID
SuiteSparseGraphBLAS.defaultmonoid(::typeof(*), ::Type{Bool}) = ANDMONOID
BUILTINMONOIDS[ANDMONOID] = ("GrB_LAND", Bool)

const XORMONOID = SuiteSparseGraphBLAS.Monoid(lxor, false)
SuiteSparseGraphBLAS.defaultmonoid(::typeof(lxor), ::Type{Bool}) = XORMONOID
BUILTINMONOIDS[XORMONOID] = ("GrB_LXOR", Bool)

const EQMONOID = SuiteSparseGraphBLAS.Monoid(==, true)
SuiteSparseGraphBLAS.defaultmonoid(::typeof(==), ::Type{Bool}) = EQMONOID
BUILTINMONOIDS[EQMONOID] = ("GrB_LXNOR", Bool)

const BORMONOID = SuiteSparseGraphBLAS.Monoid(|, zero, typemax)
SuiteSparseGraphBLAS.defaultmonoid(::typeof(|), ::Type{<:Unsigned}) = BORMONOID
BUILTINMONOIDS[BORMONOID] = ("GrB_BOR", Itypes)

const BANDMONOID = SuiteSparseGraphBLAS.Monoid(&, typemax, zero)
SuiteSparseGraphBLAS.defaultmonoid(::typeof(&), ::Type{<:Unsigned}) = BANDMONOID
BUILTINMONOIDS[BANDMONOID] = ("GrB_BAND", Itypes)

const BXORMONOID = SuiteSparseGraphBLAS.Monoid(⊻, zero)
SuiteSparseGraphBLAS.defaultmonoid(::typeof(⊻), ::Type{<:Unsigned}) = BXORMONOID
BUILTINMONOIDS[BXORMONOID] = ("GrB_BXOR", Itypes)

const BXNORMONOID = SuiteSparseGraphBLAS.Monoid(bxnor, typemax)
SuiteSparseGraphBLAS.defaultmonoid(::typeof(bxnor), ::Type{<:Unsigned}) = BXNORMONOID
BUILTINMONOIDS[BXNORMONOID] = ("GrB_BXNOR", Itypes)

end
