module Consts
using ..SuiteSparseGraphBLAS: isGxB, isGrB, libgb, libgb.GrB_UnaryOp, libgb.GrB_BinaryOp, libgb.GrB_Monoid, suffix, AbstractTypedOp, load_global, AbstractUnaryOp
using SpecialFunctions
export @unop, @binop, @monoid, @rig
function juliaop end
function unaryop end
function binaryop end
function monoid end
# UnaryOps
# unaryop(<jlop>) = singletonOP
# singletonOP(T::Type{}) = <OP>_<T>
# const <OP>_<T> = (<OPSTRING>, Ref(false), TypedUnaryOperator2)
# const AINV_INT32 = (true, "GrB_AINV_INT32", [false], [0x000000...])
# @unop GrB_IDENTITY T=>T | F=>F | I=>I | A=>N | Z=>Z | Z=>F
const Itypes = (:Int8, :Int16, :Int32, :Int64, :UInt8, :UInt16, :UInt32, :UInt64)
const Ftypes = (:Float32, :Float64)
const Ztypes = (:ComplexF32, :ComplexF64)
const FZtypes = (Ftypes..., Ztypes...)
const Rtypes = (Itypes..., Ftypes..., :Bool)
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
    else
        return sym
    end
end

mutable struct TypedUnaryOperator{X, Z} <: AbstractTypedOp{Z}
    builtin::Bool
    loaded::Bool
    typestr::String # If a built-in this is something like GxB_AINV_FP64, if not it's just some user defined string.
    p::libgb.GrB_UnaryOp
    function TypedUnaryOperator{X, Z}(builtin, loaded, typestr, p) where {X, Z}
        unop = new(builtin, loaded, typestr, p)
        return finalizer(unop) do op
            libgb.GrB_UnaryOp_free(Ref(op.p))
        end
    end
end
function Base.unsafe_convert(::Type{libgb.GrB_UnaryOp}, op::TypedUnaryOperator) 
    if op.builtin && !op.loaded
        op.p = load_global(typestr, libgb.GrB_BinaryOp)
    end
    if !op.loaded
        error("This operator could not be loaded, and is invalid.")
    else
        return op.p
    end
end

function typedunopconstexpr(dispatchstruct, builtin, namestr, intype, outtype)
    # Complex ops must always be GxB prefixed
    if (intype ∈ Ztypes || outtype ∈ Ztypes) && isGrB(namestr)
        namestr = "GxB" * namestr[4:end]
    end
    if builtin
        if intype === :Any && outtype ∈ Ntypes # POSITIONAL ops use the output type for suffix
            namestr = namestr * "_$(suffix(outtype))"
        else
            namestr = namestr * "_$(suffix(intype))"
        end
        namesym = Symbol(namestr[5:end])
    else
        namesym = Symbol(namestr)
    end
    insym = Symbol(intype)
    outsym = Symbol(outtype)
    return quote
        const $(esc(namesym)) = TypedUnaryOperator{$(esc(insym)), $(esc(outsym))}($builtin, false, $namestr, libgb.GrB_UnaryOp(C_NULL))
        (::$(esc(dispatchstruct)))(::Type{$(esc(insym))}) = $(esc(namesym))
    end
end

function typedunopexprs(dispatchfunc, builtin, namestr, intypes, outtypes)
    if intypes isa Symbol
        intypes = [intypes]
    end
    if outtypes isa Symbol
        outtypes = [outtypes]
    end
    exprs = typedunopconstexpr.(Ref(dispatchfunc), Ref(builtin), Ref(namestr), intypes, outtypes)
    if exprs isa Expr
        return exprs
    else
        return quote 
            $(exprs...)
        end
    end
end

macro unop(expr...)
    if first(expr) === :new
        newfunc = :(function $(esc(expr[2])) end)
        expr = expr[2:end]
    else
        newfunc = :()
    end
    jlfunc = first(expr)
    #dispatchfunc = Symbol(uppercase(string(first(expr))))
    name = string(expr[2])
    if isGxB(name) || isGrB(name)
        builtin = true
    else
        builtin = false
    end
    dispatchstruct = Symbol((builtin ? name[5:end] : name) * "_T")
    dispatchfunc = Symbol(builtin ? name[5:end] : name)
    types = expr[3]
    if types.head !== :call || types.args[1] !== :(=>)
        error("Type constraints should be in the form <Symbol>=><Symbol>")
    end
    intypes = symtotype(types.args[2])
    outtypes = symtotype(types.args[3])
    constquote = typedunopexprs(dispatchstruct, builtin, name, intypes, outtypes)
    dispatchquote = quote
        struct $(esc(dispatchstruct)) <: AbstractUnaryOp end
        const $(esc(dispatchfunc)) = $(esc(dispatchstruct))()
        $newfunc
        Consts.unaryop(::$(esc(:typeof))($(esc(jlfunc)))) = $(esc(dispatchfunc))
        Consts.juliaop(::$(esc(:typeof))($(esc(dispatchfunc)))) = $(esc(jlfunc))
        $constquote
    end
    return dispatchquote
end

# all types
@unop identity GrB_IDENTITY Bool=>Bool
@unop (-) GrB_AINV T=>T
@unop inv GrB_MINV T=>T
@unop one GxB_ONE T=>T

# real and int
@unop (!) GxB_LNOT Bool=>Bool
@unop abs GrB_ABS R=>R Z=>F
@unop (~) GrB_BNOT I=>I

# positionals
@unop new positioni GxB_POSITIONI1 Any=>N
@unop new positionj GxB_POSITIONJ1 Any=>N

#floats and complexes
@unop sqrt GxB_SQRT FZ=>FZ
@unop log GxB_LOG FZ=>FZ
@unop exp GxB_EXP FZ=>FZ

@unop log10 GxB_LOG10 FZ=>FZ
@unop log2 GxB_LOG2 FZ=>FZ
@unop exp2 GxB_EXP2 FZ=>FZ
@unop expm1 GxB_EXPM1 FZ=>FZ
@unop log1p GxB_LOG1P FZ=>FZ

@unop sin GxB_SIN FZ=>FZ
@unop cos GxB_COS FZ=>FZ
@unop tan GxB_TAN FZ=>FZ
@unop asin GxB_ASIN FZ=>FZ
@unop acos GxB_ACOS FZ=>FZ
@unop atan GxB_ATAN FZ=>FZ
@unop sinh GxB_SINH FZ=>FZ
@unop cosh GxB_COSH FZ=>FZ
@unop tanh GxB_TANH FZ=>FZ
@unop asinh GxB_ASINH FZ=>FZ
@unop acosh GxB_ACOSH FZ=>FZ
@unop atanh GxB_ATANH FZ=>FZ

@unop sign GxB_SIGNUM FZ=>FZ
@unop ceil GxB_CEIL FZ=>FZ
@unop floor GxB_FLOOR FZ=>FZ
@unop round GxB_ROUND FZ=>FZ
@unop trunc GxB_TRUNC FZ=>FZ

@unop SpecialFunctions.lgamma GxB_LGAMMA FZ=>FZ
@unop SpecialFunctions.gamma GxB_TGAMMA FZ=>FZ
@unop erf GxB_ERF FZ=>FZ
@unop erfc GxB_ERFC FZ=>FZ
# julia has frexp which returns (x, exp). This is split in SS:GrB to frexpx = frexp[1]; frexpe = frexp[2];
@unop new frexpx GxB_FREXPX FZ=>FZ 
@unop new frexpe GxB_FREXPE FZ=>FZ
@unop isinf GxB_ISINF FZ=>Bool
@unop isnan GxB_ISNAN FZ=>Bool
@unop isfinite GxB_ISFINITE FZ=>Bool

# Complex functions
@unop conj GxB_CONJ Z=>Z
@unop real GxB_CREAL Z=>F
@unop imag GxB_CIMAG Z=>F
@unop angle GxB_CARG Z=>F

mutable struct TypedBinaryOperator{X, Y, Z} <: AbstractTypedOp{Z}
    builtin::Bool
    loaded::Bool
    typestr::String # If a built-in this is something like GrB_PLUS_FP64, if not it's just some user defined string.
    p::libgb.GrB_BinaryOp
    function TypedBinaryOperator{X, Y, Z}(builtin, loaded, typestr, p) where {X, Y, Z}
        binop = new(builtin, loaded, typestr, p)
        return finalizer(binop) do op
            libgb.GrB_BinaryOp_free(Ref(op.p))
        end
    end
end
function Base.unsafe_convert(::Type{libgb.GrB_BinaryOp}, op::TypedBinaryOperator) 
   if op.builtin && !op.loaded
       op.p = load_global(typestr, libgb.GrB_BinaryOp)
   end
   if !op.loaded
       error("This operator could not be loaded, and is invalid.")
   else
       return op.p
   end
end

function typedbinopconstexpr(dispatchfunc, builtin, namestr, xtype, ytype, outtype)
    # Complex ops must always be GxB prefixed
    if (xtype ∈ Ztypes || ytype ∈ Ztypes || outtype ∈ Ztypes) && isGrB(namestr)
        namestr = "GxB" * namestr[4:end]
    end
    if builtin
        if xtype === :Any && ytype === :Any && outtype ∈ Ntypes # POSITIONAL ops use the output type for suffix
            namestr = namestr * "_$(suffix(outtype))"
        else
            namestr = namestr * "_$(suffix(xtype))"
        end
        namesym = Symbol(namestr[5:end])
    else
        namesym = Symbol(namestr)
    end
    xsym = Symbol(xtype)
    ysym = Symbol(ytype)
    outsym = Symbol(outtype)
    return quote
        const $(esc(namesym)) = TypedBinaryOperator{$xsym, $ysym, $outsym}($builtin, false, $namestr, libgb.GrB_BinaryOp(C_NULL))
        $(esc(dispatchfunc))(::Type{$xsym}, ::Type{$ysym}) = $(esc(namesym))
    end
end
function typedbinopexprs(dispatchfunc, builtin, namestr, xtypes, ytypes, outtypes)
    if xtypes isa Symbol
        xtypes = [xtypes]
    end
    if ytypes isa Symbol
        ytypes = [ytypes]
    end
    if outtypes isa Symbol
        outtypes = [outtypes]
    end
    exprs = typedbinopconstexpr.(Ref(dispatchfunc), Ref(builtin), Ref(namestr), xtypes, ytypes, outtypes)
    if exprs isa Expr
        return exprs
    else
        return quote 
            $(exprs...)
        end
    end
end

macro binop(expr...)
    if first(expr) === :new
        newfunc = :(function $(esc(expr[2])) end)
        expr = expr[2:end]
    else
        newfunc = :()
    end
    jlfunc = first(expr)
    name = string(expr[2])
    if isGxB(name) || isGrB(name)
        builtin = true
    else
        builtin = false
    end
    dispatchfunc = Symbol(builtin ? name[5:end] : name)
    types = expr[3]
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
    constquote = typedbinopexprs(dispatchfunc, builtin, name, xtypes, ytypes, outtypes)
    dispatchquote = Base.remove_linenums!(quote
        function $(esc(dispatchfunc)) end
        $newfunc
        Consts.binaryop(::typeof($(esc(jlfunc)))) = $(esc(dispatchfunc))
        Consts.juliaop(::typeof($(esc(dispatchfunc)))) = $(esc(jlfunc))
        $constquote
    end)
    return dispatchquote
end
# All types
@binop first GrB_FIRST T=>T
@binop new second GrB_SECOND T=>T
@binop any GxB_ANY T=>T # this doesn't match the semantics of Julia's any, but that may be ok...
@binop one GrB_ONEB T=>T # I prefer pair, but to keep up with the spec I'll match...
@binop (+) GrB_PLUS T=>T
@binop (-) GrB_MINUS T=>T
@binop new rminus GxB_RMINUS T=>T
@binop (*) GrB_TIMES T=>T
@binop (/) GrB_DIV T=>T
@binop (\) GxB_RDIV T=>T
@binop (^) GxB_POW T=>T
@binop new iseq GxB_ISEQ T=>T
@binop new isne GxB_ISNE T=>T

# Real types
@binop min GrB_MIN R=>R
@binop max GrB_MAX R=>R
@binop new isgt GxB_ISGT R=>R
@binop new islt GxB_ISLT R=>R
@binop new isge GxB_ISGE R=>R
@binop new isle GxB_ISLE R=>R
@binop new (∨) GxB_LOR R=>R
@binop new (∧) GxB_LAND R=>R
@binop new lxor GxB_LXOR R=>R

# T/R => Bool
@binop (==) GrB_EQ T=>Bool
@binop (!=) GrB_NE T=>Bool
@binop (>) GrB_GT R=>Bool
@binop (<) GrB_LT R=>Bool
@binop (>=) GrB_GE R=>Bool
@binop (<=) GrB_LE R=>Bool

# Bool=>Bool, most of which are covered above.
@binop new xnor GrB_LXNOR Bool=>Bool


@binop atan GxB_ATAN2 F=>F
@binop hypot GxB_HYPOT F=>F
@binop new fmod GxB_FMOD F=>F
@binop rem GxB_REMAINDER F=>F
@binop ldexp GxB_LDEXP F=>F
@binop copysign GxB_COPYSIGN F=>F
@binop complex GxB_CMPLX F=>Z

# bitwise
@binop (|) GrB_BOR I=>I
@binop (&) GrB_BAND I=>I
@binop (⊻) GrB_BXOR I=>I
@binop new bxnor GrB_BXNOR I=>I
BXOR(::Type{Bool}, ::Type{Bool}) = LXOR_BOOL

@binop new bget GxB_BGET I=>I
@binop new bset GxB_BSET I=>I
@binop new bclr GxB_BCLR I=>I
@binop (>>) GxB_BSHIFT (I, Int8)=>I

# Positionals
@binop new firsti0 GxB_FIRSTI Any=>N
@binop new firsti GxB_FIRSTI1 Any=>N

@binop new firstj0 GxB_FIRSTJ Any=>N
@binop new firstj GxB_FIRSTJ1 Any=>N

@binop new secondi0 GxB_SECONDI Any=>N
@binop new secondi GxB_SECONDI1 Any=>N

@binop new secondj0 GxB_SECONDJ Any=>N
@binop new secondj GxB_SECONDJ1 Any=>N

mutable struct TypedMonoidOperator{X, Z} <: AbstractTypedOp{Z}
    builtin::Bool
    loaded::Bool
    typestr::String # If a built-in this is something like GrB_PLUS_FP64, if not it's just some user defined string.
    p::libgb.GrB_Monoid
    function TypedMonoidOperator{X, Z}(builtin, loaded, typestr, p) where {X, Z}
        monoid = new(builtin, loaded, typestr, p)
        return finalizer(monoid) do op
            libgb.GrB_Monoid_free(Ref(op.p))
        end
    end
end
function Base.unsafe_convert(::Type{libgb.GrB_Monoid}, op::TypedMonoidOperator) 
   if op.builtin && !op.loaded
       op.p = load_global(typestr, libgb.GrB_Monoid)
   end
   if !op.loaded
       error("This operator could not be loaded, and is invalid.")
   else
       return op.p
   end
end

function typedmonoidconstexpr(dispatchfunc, builtin, namestr, xtype, outtype)
    # Complex ops must always be GxB prefixed
    if (xtype ∈ Ztypes || outtype ∈ Ztypes) && isGrB(namestr)
        namestr = "GxB" * namestr[4:end]
    end
    if builtin
        namestr = namestr * "_$(suffix(xtype))"
        namesym = Symbol(namestr[5:end])
    else
        namesym = Symbol(namestr)
    end
    xsym = Symbol(xtype)
    outsym = Symbol(outtype)
    return quote
        const $(esc(namesym)) = TypedMonoidOperator{$xsym, $outsym}($builtin, false, $namestr, libgb.GrB_Monoid(C_NULL))
        $(esc(dispatchfunc))(::Type{$xsym}) = $(esc(namesym))
    end
end
function typedmonoidexprs(dispatchfunc, builtin, namestr, xtypes, outtypes)
    if xtypes isa Symbol
        xtypes = [xtypes]
    end
    if outtypes isa Symbol
        outtypes = [outtypes]
    end
    exprs = typedmonoidconstexpr.(Ref(dispatchfunc), Ref(builtin), Ref(namestr), xtypes, outtypes)
    if exprs isa Expr
        return exprs
    else
        return quote 
            $(exprs...)
        end
    end
end

macro monoid(expr...)
    if first(expr) === :new
        newfunc = :(function $(esc(expr[2])) end)
        expr = expr[2:end]
    else
        newfunc = :()
    end
    binop = first(expr)
    name = string(expr[2])
    if isGxB(name) || isGrB(name)
        builtin = true
    else
        builtin = false
    end
    dispatchfunc = Symbol(builtin ? name[5:end] : name)
    types = expr[3]
    if !(types isa Symbol)
        error("Monoid type constraints should be in the form <Symbol>")
    end
    intypes = symtotype(types)
    outtypes = intypes
    constquote = typedmonoidexprs(dispatchfunc, builtin, name, intypes, outtypes)
    dispatchquote = Base.remove_linenums!(quote
        function $(esc(dispatchfunc)) end
        $newfunc
        Consts.binaryop(::typeof($(esc(dispatchfunc)))) = $(esc(binop))
        Consts.monoid(::typeof($(esc(binop)))) = $(esc(dispatchfunc))
        $constquote
    end)
    return dispatchquote
end

# We use the BinaryOp name rather than the Julia name. 
@monoid PLUS GrB_PLUS_MONOID T
@monoid TIMES GrB_TIMES_MONOID T

@monoid ANY GxB_ANY_MONOID T
@monoid MIN GrB_MIN_MONOID T
@monoid MAX GrB_MAX_MONOID T

@monoid LOR GrB_LOR_MONOID Bool
@monoid LAND GrB_LAND_MONOID Bool
@monoid LXOR GrB_LXOR_MONOID Bool
@monoid LXNOR GrB_LXNOR_MONOID Bool
@monoid BOR GrB_BOR_MONOID I
@monoid BAND GrB_BAND_MONOID I
@monoid BXOR GrB_BXOR_MONOID I
@monoid BXNOR GrB_BXNOR_MONOID I

mutable struct TypedSemiringOperator{X, Y, Z} <: AbstractTypedOp{Z}
    builtin::Bool
    loaded::Bool
    typestr::String # If a built-in this is something like GrB_PLUS_FP64, if not it's just some user defined string.
    p::libgb.GrB_Semiring
    function TypedSemiringOperator{X, Y, Z}(builtin, loaded, typestr, p) where {X, Y, Z}
        binop = new(builtin, loaded, typestr, p)
        return finalizer(binop) do op
            libgb.GrB_Semiring_free(Ref(op.p))
        end
    end
end
function Base.unsafe_convert(::Type{libgb.GrB_Semiring}, op::TypedSemiringOperator) 
   if op.builtin && !op.loaded
       op.p = load_global(typestr, libgb.GrB_Semiring)
   end
   if !op.loaded
       error("This operator could not be loaded, and is invalid.")
   else
       return op.p
   end
end

function typedrigconstexpr(dispatchfunc, builtin, namestr, xtype, ytype, outtype)
    # Complex ops must always be GxB prefixed
    if (xtype ∈ Ztypes || ytype ∈ Ztypes || outtype ∈ Ztypes) && isGrB(namestr)
        namestr = "GxB" * namestr[4:end]
    end
    if builtin
        if xtype === :Any && ytype === :Any && outtype ∈ Ntypes # POSITIONAL ops use the output type for suffix
            namestr = namestr * "_$(suffix(outtype))"
        else
            namestr = namestr * "_$(suffix(xtype))"
        end
        namesym = Symbol(namestr[5:end])
    else
        namesym = Symbol(namestr)
    end
    xsym = Symbol(xtype)
    ysym = Symbol(ytype)
    outsym = Symbol(outtype)
    return quote
        const $(esc(namesym)) = TypedSemiringOperator{$xsym, $ysym, $outsym}($builtin, false, $namestr, libgb.GrB_Semiring(C_NULL))
        $(esc(dispatchfunc))(::Type{$xsym}, ::Type{$ysym}) = $(esc(namesym))
    end
end
function typedrigexprs(dispatchfunc, builtin, namestr, xtypes, ytypes, outtypes)
    if xtypes isa Symbol
        xtypes = [xtypes]
    end
    if ytypes isa Symbol
        ytypes = [ytypes]
    end
    if outtypes isa Symbol
        outtypes = [outtypes]
    end
    exprs = typedbinopconstexpr.(Ref(dispatchfunc), Ref(builtin), Ref(namestr), xtypes, ytypes, outtypes)
    if exprs isa Expr
        return exprs
    else
        return quote 
            $(exprs...)
        end
    end
end

macro rig(expr...)
    jlfuncs = first(expr)
    if jlfuncs.head === :tuple && jlfuncs.args[1] isa Symbol && jlfuncs.args[2] isa Symbol
        reducer = jlfuncs.args[1]
        binop = jlfuncs.args[2]
    else
        error("Semiring macro 1st argument must be of the form (<Symbol>,<Symbol>)")
    end

    name = string(expr[2])
    if isGxB(name) || isGrB(name)
        builtin = true
    else
        builtin = false
    end

    dispatchfunc = builtin ? name[5:end] : name
    dispatchfunc = Symbol(occursin("SEMIRING", dispatchfunc) ? dispatchfunc[begin:end-8] : dispatchfunc)

    types = expr[3]
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
    constquote = typedrigexprs(dispatchfunc, builtin, name, xtypes, ytypes, outtypes)
    dispatchquote = Base.remove_linenums!(quote
        function $(esc(dispatchfunc)) end
        Consts.binaryop(::typeof($(esc(dispatchfunc)))) = $(esc(binop))
        Consts.monoid(::typeof($(esc(dispatchfunc)))) = $(esc(reducer))
        Consts.semiring(::typeof($(esc(reducer))), ::typeof($(esc(binop))))
        $constquote
    end)
    return dispatchquote
end
end