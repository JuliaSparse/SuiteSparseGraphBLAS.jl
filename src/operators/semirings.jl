module Semirings
import ..SuiteSparseGraphBLAS
using ..SuiteSparseGraphBLAS: isGxB, isGrB, TypedSemiring, AbstractSemiring, GBType,
    valid_vec, juliaop, toGBType, symtotype, Itypes, Ftypes, Ztypes, FZtypes,
    Rtypes, Ntypes, Ttypes, suffix, BinaryOps.BinaryOp, Monoids.Monoid, BinaryOps.second, BinaryOps.rminus,
    BinaryOps.iseq, BinaryOps.isne, BinaryOps.isgt, BinaryOps.islt, BinaryOps.isge, BinaryOps.isle, BinaryOps.∨,
    BinaryOps.∧, BinaryOps.lxor, BinaryOps.xnor, BinaryOps.fmod, BinaryOps.bxnor, BinaryOps.bget, BinaryOps.bset,
    BinaryOps.bclr, BinaryOps.firsti0, BinaryOps.firsti, BinaryOps.firstj0, BinaryOps.firstj, BinaryOps.secondi0, 
    BinaryOps.secondi, BinaryOps.secondj0, BinaryOps.secondj
using ..libgb
export Semiring, @rig

struct Semiring{FM, FA} <: AbstractSemiring
    addop::Monoid{FA}
    mulop::BinaryOp{FM}
end
Semiring(addop::Function, mulop::Function) = Semiring(Monoid(addop),BinaryOp(mulop))
Semiring(tup::Tuple{Function, Function}) = Semiring(tup...)

function typedrigconstexpr(addfunc, mulfunc, builtin, namestr, xtype, ytype, outtype)
    # Complex ops must always be GxB prefixed
    if (xtype ∈ Ztypes || ytype ∈ Ztypes || outtype ∈ Ztypes) && isGrB(namestr)
        namestr = "GxB" * namestr[4:end]
    end
    namestr = isGrB(namestr) ? namestr * "_SEMIRING" : namestr
    if xtype === :Any && ytype === :Any && outtype ∈ Ntypes # POSITIONAL ops use the output type for suffix
        namestr = namestr * "_$(suffix(outtype))"
    elseif xtype === ytype
        namestr = namestr * "_$(suffix(xtype))"
    else
        namestr = namestr * "_$(suffix(xtype))_$(suffix(ytype))"
    end
    if builtin
        namesym = Symbol(namestr[5:end])
    else
        namesym = Symbol(namestr)
    end
    xsym = Symbol(xtype)
    ysym = Symbol(ytype)
    outsym = Symbol(outtype)
    dispatchquote = if xtype === :Any && ytype === :Any
        :((::$(esc(:Semiring)){$(esc(:typeof))($(esc(addfunc))), $(esc(:typeof))($(esc(mulfunc)))})(::Type, ::Type) = $(esc(namesym)))
    else
        :((::$(esc(:Semiring)){$(esc(:typeof))($(esc(addfunc))), $(esc(:typeof))($(esc(mulfunc)))})(::Type{$xsym}, ::Type{$ysym}) = $(esc(namesym)))
    end
    return quote
        const $(esc(namesym)) = TypedSemiring($builtin, false, $namestr, libgb.GrB_Semiring(), Monoid($(esc(addfunc)))($(esc(outsym))), BinaryOp($(esc(mulfunc)))($(esc(xsym)), $(esc(ysym))))
        $(dispatchquote)
    end
end
function typedrigexprs(addfunc, mulfunc, builtin, namestr, xtypes, ytypes, outtypes)
    if xtypes isa Symbol
        xtypes = [xtypes]
    end
    if ytypes isa Symbol
        ytypes = [ytypes]
    end
    if outtypes isa Symbol
        outtypes = [outtypes]
    end
    exprs = typedrigconstexpr.(Ref(addfunc), Ref(mulfunc), Ref(builtin), Ref(namestr), xtypes, ytypes, outtypes)
    if exprs isa Expr
        return exprs
    else
        return quote 
            $(exprs...)
        end
    end
end

macro rig(expr...)
    operands = first(expr)
    if operands.head === :tuple && operands.args[1] isa Symbol && operands.args[2] isa Symbol
        reducer = operands.args[1]
        binop = operands.args[2]
    else
        error("Semiring macro 1st argument must be of the form (<Symbol>,<Symbol>)")
    end
    if expr[2] isa Symbol
        name = string(expr[2])
        types = expr[3]
    else # if we aren't given a name then we'll assume it's just uppercased of the function.
        name = uppercase(string(jlfunc))
        types = expr[2]
    end
    builtin = isGxB(name) || isGrB(name)
    if types.head !== :call || types.args[1] !== :(=>)
        error("Type constraints should be in the form <Symbol>=><Symbol>")
    end
    intypes = types.args[2]
    if intypes isa Expr && intypes.head === :tuple
        xtypes = symtotype(intypes.args[1])
        ytypes = symtotype(intypes.args[2])
    else
        xtypes = symtotype(intypes)
        ytypes = xtypes
    end
    outtypes = symtotype(types.args[3])
    constquote = typedrigexprs(reducer, binop, builtin, name, xtypes, ytypes, outtypes)
    return constquote
end

# (MIN, MAX, PLUS, TIMES, ANY) × 
# (FIRST, SECOND, PAIR(ONEB), MIN, MAX, PLUS, MINUS, RMINUS, TIMES, DIV, RDIV, ISEQ, 
# ISNE, ISGT, ISLT, ISGE, ISLE, LOR, LAND, LXOR) ×
# (I..., F...)
@rig (min, first) GxB_MIN_FIRST IF=>IF
@rig (min, second) GxB_MIN_SECOND IF=>IF
@rig (min, one) GxB_MIN_PAIR IF=>IF
@rig (min, min) GxB_MIN_MIN IF=>IF
@rig (min, max) GxB_MIN_MAX IF=>IF
@rig (min, +) GxB_MIN_PLUS IF=>IF
@rig (min, -) GxB_MIN_MINUS IF=>IF
@rig (min, rminus) GxB_MIN_RMINUS IF=>IF
@rig (min, *) GxB_MIN_TIMES IF=>IF
@rig (min, /) GxB_MIN_DIV IF=>IF
@rig (min, \) GxB_MIN_RDIV IF=>IF
@rig (min, iseq) GxB_MIN_ISEQ IF=>IF
@rig (min, isne) GxB_MIN_ISNE IF=>IF
@rig (min, isgt) GxB_MIN_ISGT IF=>IF
@rig (min, islt) GxB_MIN_ISLT IF=>IF
@rig (min, isge) GxB_MIN_ISGE IF=>IF
@rig (min, isle) GxB_MIN_ISLE IF=>IF
@rig (min, ∨) GxB_MIN_LOR IF=>IF
@rig (min, ∧) GxB_MIN_LAND IF=>IF
@rig (min, lxor) GxB_MIN_LXOR IF=>IF

@rig (max, first) GxB_MAX_FIRST IF=>IF
@rig (max, second) GxB_MAX_SECOND IF=>IF
@rig (max, one) GxB_MAX_PAIR IF=>IF
@rig (max, min) GxB_MAX_MIN IF=>IF
@rig (max, max) GxB_MAX_MAX IF=>IF
@rig (max, +) GxB_MAX_PLUS IF=>IF
@rig (max, -) GxB_MAX_MINUS IF=>IF
@rig (max, rminus) GxB_MAX_RMINUS IF=>IF
@rig (max, *) GxB_MAX_TIMES IF=>IF
@rig (max, /) GxB_MAX_DIV IF=>IF
@rig (max, \) GxB_MAX_RDIV IF=>IF
@rig (max, iseq) GxB_MAX_ISEQ IF=>IF
@rig (max, isne) GxB_MAX_ISNE IF=>IF
@rig (max, isgt) GxB_MAX_ISGT IF=>IF
@rig (max, islt) GxB_MAX_ISLT IF=>IF
@rig (max, isge) GxB_MAX_ISGE IF=>IF
@rig (max, isle) GxB_MAX_ISLE IF=>IF
@rig (max, ∨) GxB_MAX_LOR IF=>IF
@rig (max, ∧) GxB_MAX_LAND IF=>IF
@rig (max, lxor) GxB_MAX_LXOR IF=>IF

@rig (+, first) GxB_PLUS_FIRST IF=>IF
@rig (+, second) GxB_PLUS_SECOND IF=>IF
@rig (+, one) GxB_PLUS_PAIR IF=>IF
@rig (+, min) GxB_PLUS_MIN IF=>IF
@rig (+, max) GxB_PLUS_MAX IF=>IF
@rig (+, +) GxB_PLUS_PLUS IF=>IF
@rig (+, -) GxB_PLUS_MINUS IF=>IF
@rig (+, rminus) GxB_PLUS_RMINUS IF=>IF
@rig (+, *) GxB_PLUS_TIMES IF=>IF
@rig (+, /) GxB_PLUS_DIV IF=>IF
@rig (+, \) GxB_PLUS_RDIV IF=>IF
@rig (+, iseq) GxB_PLUS_ISEQ IF=>IF
@rig (+, isne) GxB_PLUS_ISNE IF=>IF
@rig (+, isgt) GxB_PLUS_ISGT IF=>IF
@rig (+, islt) GxB_PLUS_ISLT IF=>IF
@rig (+, isge) GxB_PLUS_ISGE IF=>IF
@rig (+, isle) GxB_PLUS_ISLE IF=>IF
@rig (+, ∨) GxB_PLUS_LOR IF=>IF
@rig (+, ∧) GxB_PLUS_LAND IF=>IF
@rig (+, lxor) GxB_PLUS_LXOR IF=>IF

@rig (*, first) GxB_TIMES_FIRST IF=>IF
@rig (*, second) GxB_TIMES_SECOND IF=>IF
@rig (*, one) GxB_TIMES_PAIR IF=>IF
@rig (*, min) GxB_TIMES_MIN IF=>IF
@rig (*, max) GxB_TIMES_MAX IF=>IF
@rig (*, +) GxB_TIMES_PLUS IF=>IF
@rig (*, -) GxB_TIMES_MINUS IF=>IF
@rig (*, rminus) GxB_TIMES_RMINUS IF=>IF
@rig (*, *) GxB_TIMES_TIMES IF=>IF
@rig (*, /) GxB_TIMES_DIV IF=>IF
@rig (*, \) GxB_TIMES_RDIV IF=>IF
@rig (*, iseq) GxB_TIMES_ISEQ IF=>IF
@rig (*, isne) GxB_TIMES_ISNE IF=>IF
@rig (*, isgt) GxB_TIMES_ISGT IF=>IF
@rig (*, islt) GxB_TIMES_ISLT IF=>IF
@rig (*, isge) GxB_TIMES_ISGE IF=>IF
@rig (*, isle) GxB_TIMES_ISLE IF=>IF
@rig (*, ∨) GxB_TIMES_LOR IF=>IF
@rig (*, ∧) GxB_TIMES_LAND IF=>IF
@rig (*, lxor) GxB_TIMES_LXOR IF=>IF

@rig (any, first) GxB_ANY_FIRST IF=>IF
@rig (any, second) GxB_ANY_SECOND IF=>IF
@rig (any, one) GxB_ANY_PAIR IF=>IF
@rig (any, min) GxB_ANY_MIN IF=>IF
@rig (any, max) GxB_ANY_MAX IF=>IF
@rig (any, +) GxB_ANY_PLUS IF=>IF
@rig (any, -) GxB_ANY_MINUS IF=>IF
@rig (any, rminus) GxB_ANY_RMINUS IF=>IF
@rig (any, *) GxB_ANY_TIMES IF=>IF
@rig (any, /) GxB_ANY_DIV IF=>IF
@rig (any, \) GxB_ANY_RDIV IF=>IF
@rig (any, iseq) GxB_ANY_ISEQ IF=>IF
@rig (any, isne) GxB_ANY_ISNE IF=>IF
@rig (any, isgt) GxB_ANY_ISGT IF=>IF
@rig (any, islt) GxB_ANY_ISLT IF=>IF
@rig (any, isge) GxB_ANY_ISGE IF=>IF
@rig (any, isle) GxB_ANY_ISLE IF=>IF
@rig (any, ∨) GxB_ANY_LOR IF=>IF
@rig (any, ∧) GxB_ANY_LAND IF=>IF
@rig (any, lxor) GxB_ANY_LXOR IF=>IF

# (LAND, LOR, LXOR, EQ, ANY) × (EQ, NE, GT, LT, GE, LE) × (I..., F...)
@rig (∧, ==) GxB_LAND_EQ IF=>Bool
@rig (∧, !=) GxB_LAND_NE IF=>Bool
@rig (∧, >) GxB_LAND_GT IF=>Bool
@rig (∧, <) GxB_LAND_LT IF=>Bool
@rig (∧, >=) GxB_LAND_GE IF=>Bool
@rig (∧, <=) GxB_LAND_LE IF=>Bool

@rig (∨, ==) GxB_LOR_EQ IF=>Bool
@rig (∨, !=) GxB_LOR_NE IF=>Bool
@rig (∨, >) GxB_LOR_GT IF=>Bool
@rig (∨, <) GxB_LOR_LT IF=>Bool
@rig (∨, >=) GxB_LOR_GE IF=>Bool
@rig (∨, <=) GxB_LOR_LE IF=>Bool

@rig (lxor, ==) GxB_LXOR_EQ IF=>Bool
@rig (lxor, !=) GxB_LXOR_NE IF=>Bool
@rig (lxor, >) GxB_LXOR_GT IF=>Bool
@rig (lxor, <) GxB_LXOR_LT IF=>Bool
@rig (lxor, >=) GxB_LXOR_GE IF=>Bool
@rig (lxor, <=) GxB_LXOR_LE IF=>Bool

@rig (==, ==) GxB_EQ_EQ IF=>Bool
@rig (==, !=) GxB_EQ_NE IF=>Bool
@rig (==, >) GxB_EQ_GT IF=>Bool
@rig (==, <) GxB_EQ_LT IF=>Bool
@rig (==, >=) GxB_EQ_GE IF=>Bool
@rig (==, <=) GxB_EQ_LE IF=>Bool

@rig (any, ==) GxB_ANY_EQ IF=>Bool
@rig (any, !=) GxB_ANY_NE IF=>Bool
@rig (any, >) GxB_ANY_GT IF=>Bool
@rig (any, <) GxB_ANY_LT IF=>Bool
@rig (any, >=) GxB_ANY_GE IF=>Bool
@rig (any, <=) GxB_ANY_LE IF=>Bool

# (LAND, LOR, LXOR, EQ, ANY) × (FIRST, SECOND, PAIR(ONEB), LOR, LAND, LXOR, EQ, GT, LT, GE, LE) × Bool

@rig (∧, first) GxB_LAND_FIRST Bool=>Bool
@rig (∧, second) GxB_LAND_SECOND Bool=>Bool
@rig (∧, one) GxB_LAND_PAIR Bool=>Bool
@rig (∧, ∨) GxB_LAND_LOR Bool=>Bool
@rig (∧, ∧) GxB_LAND_LAND Bool=>Bool
@rig (∧, lxor) GxB_LAND_LXOR Bool=>Bool
@rig (∧, ==) GxB_LAND_EQ Bool=>Bool
@rig (∧, >) GxB_LAND_GT Bool=>Bool
@rig (∧, <) GxB_LAND_LT Bool=>Bool
@rig (∧, >=) GxB_LAND_GE Bool=>Bool
@rig (∧, <=) GxB_LAND_LE Bool=>Bool

@rig (∨, first) GxB_LOR_FIRST Bool=>Bool
@rig (∨, second) GxB_LOR_SECOND Bool=>Bool
@rig (∨, one) GxB_LOR_PAIR Bool=>Bool
@rig (∨, ∨) GxB_LOR_LOR Bool=>Bool
@rig (∨, ∧) GxB_LOR_LAND Bool=>Bool
@rig (∨, lxor) GxB_LOR_LXOR Bool=>Bool
@rig (∨, ==) GxB_LOR_EQ Bool=>Bool
@rig (∨, >) GxB_LOR_GT Bool=>Bool
@rig (∨, <) GxB_LOR_LT Bool=>Bool
@rig (∨, >=) GxB_LOR_GE Bool=>Bool
@rig (∨, <=) GxB_LOR_LE Bool=>Bool

@rig (lxor, first) GxB_LXOR_FIRST Bool=>Bool
@rig (lxor, second) GxB_LXOR_SECOND Bool=>Bool
@rig (lxor, one) GxB_LXOR_PAIR Bool=>Bool
@rig (lxor, ∨) GxB_LXOR_LOR Bool=>Bool
@rig (lxor, ∧) GxB_LXOR_LAND Bool=>Bool
@rig (lxor, lxor) GxB_LXOR_LXOR Bool=>Bool
@rig (lxor, ==) GxB_LXOR_EQ Bool=>Bool
@rig (lxor, >) GxB_LXOR_GT Bool=>Bool
@rig (lxor, <) GxB_LXOR_LT Bool=>Bool
@rig (lxor, >=) GxB_LXOR_GE Bool=>Bool
@rig (lxor, <=) GxB_LXOR_LE Bool=>Bool

@rig (==, first) GxB_EQ_FIRST Bool=>Bool
@rig (==, second) GxB_EQ_SECOND Bool=>Bool
@rig (==, one) GxB_EQ_PAIR Bool=>Bool
@rig (==, ∨) GxB_EQ_LOR Bool=>Bool
@rig (==, ∧) GxB_EQ_LAND Bool=>Bool
@rig (==, lxor) GxB_EQ_LXOR Bool=>Bool
@rig (==, ==) GxB_EQ_EQ Bool=>Bool
@rig (==, >) GxB_EQ_GT Bool=>Bool
@rig (==, <) GxB_EQ_LT Bool=>Bool
@rig (==, >=) GxB_EQ_GE Bool=>Bool
@rig (==, <=) GxB_EQ_LE Bool=>Bool

@rig (any, first) GxB_ANY_FIRST Bool=>Bool
@rig (any, second) GxB_ANY_SECOND Bool=>Bool
@rig (any, one) GxB_ANY_PAIR Bool=>Bool
@rig (any, ∨) GxB_ANY_LOR Bool=>Bool
@rig (any, ∧) GxB_ANY_LAND Bool=>Bool
@rig (any, lxor) GxB_ANY_LXOR Bool=>Bool
@rig (any, ==) GxB_ANY_EQ Bool=>Bool
@rig (any, >) GxB_ANY_GT Bool=>Bool
@rig (any, <) GxB_ANY_LT Bool=>Bool
@rig (any, >=) GxB_ANY_GE Bool=>Bool
@rig (any, <=) GxB_ANY_LE Bool=>Bool

# (PLUS, TIMES, ANY) × (FIRST, SECOND, PAIR(ONEB), PLUS, MINUS, RMINUS, TIMES, DIV, RDIV) × Z
@rig (+, first) GxB_PLUS_FIRST Z=>Z
@rig (+, second) GxB_PLUS_SECOND Z=>Z
@rig (+, one) GxB_PLUS_PAIR Z=>Z
@rig (+, +) GxB_PLUS_PLUS Z=>Z
@rig (+, -) GxB_PLUS_MINUS Z=>Z
@rig (+, rminus) GxB_PLUS_RMINUS Z=>Z
@rig (+, *) GxB_PLUS_TIMES Z=>Z
@rig (+, /) GxB_PLUS_DIV Z=>Z
@rig (+, \) GxB_PLUS_RDIV Z=>Z

@rig (*, first) GxB_TIMES_FIRST Z=>Z
@rig (*, second) GxB_TIMES_SECOND Z=>Z
@rig (*, one) GxB_TIMES_PAIR Z=>Z
@rig (*, +) GxB_TIMES_PLUS Z=>Z
@rig (*, -) GxB_TIMES_MINUS Z=>Z
@rig (*, rminus) GxB_TIMES_RMINUS Z=>Z
@rig (*, *) GxB_TIMES_TIMES Z=>Z
@rig (*, /) GxB_TIMES_DIV Z=>Z
@rig (*, \) GxB_TIMES_RDIV Z=>Z

@rig (any, first) GxB_ANY_FIRST Z=>Z
@rig (any, second) GxB_ANY_SECOND Z=>Z
@rig (any, one) GxB_ANY_PAIR Z=>Z
@rig (any, +) GxB_ANY_PLUS Z=>Z
@rig (any, -) GxB_ANY_MINUS Z=>Z
@rig (any, rminus) GxB_ANY_RMINUS Z=>Z
@rig (any, *) GxB_ANY_TIMES Z=>Z
@rig (any, /) GxB_ANY_DIV Z=>Z
@rig (any, \) GxB_ANY_RDIV Z=>Z

@rig (|, |) GxB_BOR_BOR U=>U
@rig (|, &) GxB_BOR_BAND U=>U
@rig (|, ⊻) GxB_BOR_BXOR U=>U
@rig (|, bxnor) GxB_BOR_BXNOR U=>U

@rig (&, |) GxB_BAND_BOR U=>U
@rig (&, &) GxB_BAND_BAND U=>U
@rig (&, ⊻) GxB_BAND_BXOR U=>U
@rig (&, bxnor) GxB_BAND_BXNOR U=>U

@rig (⊻, |) GxB_BXOR_BOR U=>U
@rig (⊻, &) GxB_BXOR_BAND U=>U
@rig (⊻, ⊻) GxB_BXOR_BXOR U=>U
@rig (⊻, bxnor) GxB_BXOR_BXNOR U=>U

@rig (bxnor, |) GxB_BXNOR_BOR U=>U
@rig (bxnor, &) GxB_BXNOR_BAND U=>U
@rig (bxnor, ⊻) GxB_BXNOR_BXOR U=>U
@rig (bxnor, bxnor) GxB_BXNOR_BXNOR U=>U

@rig (min, firsti) GxB_MIN_FIRSTI1 Any=>N
@rig (min, firsti0) GxB_MIN_FIRSTI Any=>N
@rig (min, firstj) GxB_MIN_FIRSTJ1 Any=>N
@rig (min, firstj0) GxB_MIN_FIRSTJ Any=>N
@rig (min, secondi) GxB_MIN_SECONDI1 Any=>N
@rig (min, secondi0) GxB_MIN_SECONDI Any=>N
@rig (min, secondj) GxB_MIN_SECONDJ1 Any=>N
@rig (min, secondj0) GxB_MIN_SECONDJ Any=>N

@rig (max, firsti) GxB_MAX_FIRSTI1 Any=>N
@rig (max, firsti0) GxB_MAX_FIRSTI Any=>N
@rig (max, firstj) GxB_MAX_FIRSTJ1 Any=>N
@rig (max, firstj0) GxB_MAX_FIRSTJ Any=>N
@rig (max, secondi) GxB_MAX_SECONDI1 Any=>N
@rig (max, secondi0) GxB_MAX_SECONDI Any=>N
@rig (max, secondj) GxB_MAX_SECONDJ1 Any=>N
@rig (max, secondj0) GxB_MAX_SECONDJ Any=>N

@rig (+, firsti) GxB_PLUS_FIRSTI1 Any=>N
@rig (+, firsti0) GxB_PLUS_FIRSTI Any=>N
@rig (+, firstj) GxB_PLUS_FIRSTJ1 Any=>N
@rig (+, firstj0) GxB_PLUS_FIRSTJ Any=>N
@rig (+, secondi) GxB_PLUS_SECONDI1 Any=>N
@rig (+, secondi0) GxB_PLUS_SECONDI Any=>N
@rig (+, secondj) GxB_PLUS_SECONDJ1 Any=>N
@rig (+, secondj0) GxB_PLUS_SECONDJ Any=>N

@rig (*, firsti) GxB_TIMES_FIRSTI1 Any=>N
@rig (*, firsti0) GxB_TIMES_FIRSTI Any=>N
@rig (*, firstj) GxB_TIMES_FIRSTJ1 Any=>N
@rig (*, firstj0) GxB_TIMES_FIRSTJ Any=>N
@rig (*, secondi) GxB_TIMES_SECONDI1 Any=>N
@rig (*, secondi0) GxB_TIMES_SECONDI Any=>N
@rig (*, secondj) GxB_TIMES_SECONDJ1 Any=>N
@rig (*, secondj0) GxB_TIMES_SECONDJ Any=>N

@rig (any, firsti) GxB_ANY_FIRSTI1 Any=>N
@rig (any, firsti0) GxB_ANY_FIRSTI Any=>N
@rig (any, firstj) GxB_ANY_FIRSTJ1 Any=>N
@rig (any, firstj0) GxB_ANY_FIRSTJ Any=>N
@rig (any, secondi) GxB_ANY_SECONDI1 Any=>N
@rig (any, secondi0) GxB_ANY_SECONDI Any=>N
@rig (any, secondj) GxB_ANY_SECONDJ1 Any=>N
@rig (any, secondj0) GxB_ANY_SECONDJ Any=>N
end

ztype(::TypedSemiring{X, Y, Z}) where {X, Y, Z} = Z
xtype(::TypedSemiring{X, Y, Z}) where {X, Y, Z} = X
ytype(::TypedSemiring{X, Y, Z}) where {X, Y, Z} = YTypedSemiring