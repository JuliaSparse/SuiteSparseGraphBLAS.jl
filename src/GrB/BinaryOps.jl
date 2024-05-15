module BinaryOps
import ..GrB
import ..GrB:
    Itypes, Ftypes, Ztypes, FZtypes, Rtypes,
    Ntypes, Ttypes, suffix, load_global,
    set!, GB_promote,
    OperatorCompiler, LibGraphBLAS,
    firsti0, firsti, firstj0, firstj, secondi0, secondi, secondj0, 
    secondj, ispair, second, rminus, ∨, ∧, lxor, xnor, bxnor, 
    bget, bset, bclr, GxB_fprint, inputisany, gxbprint, domains,
    BinaryOp

import SparseBase: storedeltype

domains(::BinaryOp{F, F2, X, Y, Z}) where {F, F2, X, Y, Z} = (X, Y) => Z

"""
    cbinary(f::Function, ::Type{X}, ::Type{Y}, ::Type{Z}) -> Cvoid

Create a C function pointer for a binary function `f` with signature 
    `f(z::Ptr{Z}, x::Ptr{X}, y::Ptr{Y})::Nothing`.

This is used to supply a function pointer to a `GrB_BinaryOp` from Julia function `f`. 
On certain platforms closure functions are not supported (e.g. Aarch64), 
this function will throw an `ArgumentError` in those cases.
"""
@generated function cbinary(f::F, ::Type{X}, ::Type{Y}, ::Type{Z}) where {F, X, Y, Z}
    if Base.issingletontype(F)
        :(@cfunction($(F.instance), Cvoid, (Ptr{Z}, Ptr{X}, Ptr{Y})))
    else
        throw("Unsupported function $f.")
    end
end

function Base.unsafe_convert(::Type{LibGraphBLAS.GrB_BinaryOp}, op::BinaryOp{F, F2, X, Y, Z}) where {F, F2, X, Y, Z}
    if !op.loaded
        if op.builtin
            op.p = load_global(op.typestr, LibGraphBLAS.GrB_BinaryOp)
        else
            opref = Ref{LibGraphBLAS.GrB_BinaryOp}()
            z, x, y = GrB.Type(Z), GrB.Type(X), GrB.Type(Y)
            info = LibGraphBLAS.GxB_BinaryOp_new(
                opref, 
                cbinary(op.c_fn, X, Y, Z), 
                z, x, y, 
                op.maycompile ? op.typestr : C_NULL, 
                op.maycompile ? "GB_ISOBJ $(op.bitcodepath)" : C_NULL
            )
            if info != LibGraphBLAS.GrB_SUCCESS
                GrB.@uninitializedobject info z x y
                GrB.@fallbackerror info
            end
            op.p = opref[]
            op.compileset = op.maycompile
        end
        op.loaded = true
        !op.builtin && set!(op, :name, string(op.fn))
    end
    if !op.loaded
        error("This operator $(op.fn) could not be loaded, and is invalid.")
    else
        if op.maycompile && !op.compileset
            set!(op, :jit_cname, op.typestr)
            set!(op, :jit_cdef, "GB_ISOBJ $(op.bitcodepath)")
            op.compileset = true
        end
        return op.p
    end
end
function GrB.nothrow_wait!(op::BinaryOp, mode) 
    return LibGraphBLAS.GrB_BinaryOp_wait(op, mode)
end
function GrB.wait!(op::BinaryOp, mode) 
    info = GrB.nothrow_wait!(op, mode)
    if info != LibGraphBLAS.GrB_SUCCESS
        # Technically pending OOB can throw here, but I don't see how on a BinaryOp.
        GrB.@invalidvalue info mode
        GrB.@uninitializedobject info op
        GrB.@fallbackerror info
    end
end

const BINARYOPS = Dict()
const COMPILEDBINARYOPS = Dict()
const BUILTINBINARYOPS = IdDict{<:Any, <:Any}() # (f) -> (name, inputtype(s))

function linker(job, compiled)
    irpath, name = OperatorCompiler.writeir(compiled)
    (; fn, c_fn, intypes) = job.config.params
    return BinaryOp{
        typeof(fn), 
        storedeltype(intypes[2]), 
        storedeltype(intypes[3]), 
        storedeltype(intypes[1])
    }(
        false, false, name, fn, c_fn;
        maycompile = true, irpath
    )
end

function binarycachecompile(
    f, ptrfunction, ::Type{X}, ::Type{Y}, ::Type{Z}; 
    maycompile = true
) where {X, Y, Z}
    job = OperatorCompiler.operatorjob(f, ptrfunction, (Ptr{Z}, Ptr{X}, Ptr{Y}))
    op = OperatorCompiler.cached_compile(COMPILEDBINARYOPS, job, linker)
    op.maycompile = op.maycompile || maycompile
    return op
end

function binarybuiltin(f, X, Y, Z, builtin_name)
    namestr = string(builtin_name[1]) * 
        (Any ∈ builtin_name[2] ? "_$(suffix(Z))" : "_$(suffix(GB_promote(X, Y)))")
    namestr = (X <: Complex || Y <: Complex) ? "GxB" * namestr[4:end] : namestr
    return BinaryOp{typeof(f), X, Y, Z}(
        true, false, namestr, f
    )
end

"""
    BinaryOp(f::Function, ::Type{X}, ::Type{Y}, ::Type{Z}) -> UnaryOp{F, F2, X, Y, Z}

Create a `GrB_UnaryOp` from a Julia function `f` with signature `f(x::X, y::Y) -> z::Z`.

Most users should not call this function directly, 
    instead pass a function directly to a GraphBLAS operation.

# Arguments
- `f`: Julia function to wrap.
- `X::DataType`: Type of the first operand.
- `Y::DataType`: Type of the second operand.
- `Z::DataType`: Output type.
- `maycompile::Bool`: If `maycompile` is `true`, JIT compilation may be performed. 
If false, function pointers will be used. Note: this is currently a one way switch, 
it may be turned from `false` to `true`, but not back to `false`.

Function `f` must not allocate, yield or throw.
"""
function BinaryOp(
    f, ::Type{X}, ::Type{Y}, ::Type{Z}; maycompile = true
) where {X, Y, Z}
    # some binaryops take any types, including UDTs
    x, y, z = inputisany(f) ? (Any, Any, Int64) : (X, Y, Z)

    maybeop = Base.get!(BINARYOPS, (f, x, y, z)) do
        builtin_name = Base.get(BUILTINBINARYOPS, f, nothing)
        if builtin_name !== nothing && (
            (x ∈ builtin_name[2] && y ∈ builtin_name[2])
        )
            return binarybuiltin(f, x, y, z, builtin_name)
        else
            return nothing
        end
    end
    if maybeop isa BinaryOp
        return maybeop
    elseif maybeop === nothing
        function binaryopfn(z, x, y)
            Base.unsafe_store!(z, f(Base.unsafe_load(x), Base.unsafe_load(y)))
            return nothing
        end
        BINARYOPS[(f, x, y, z)] = binaryopfn
        return binarycachecompile(f, binaryopfn, X, Y, Z; maycompile)
    else
        return binarycachecompile(f, maybeop, X, Y, Z; maycompile)
    end
end

BinaryOp(f, X, Y, Z; maycompile = true) = 
    BinaryOp(f, storedeltype(X), storedeltype(Y), storedeltype(Z); maycompile)
BinaryOp(
    op::BinaryOp, ::Type{X}, ::Type{Y}, ::Type{Z}; kwargs...
) where {X, Y, Z} = op
BinaryOp(
    f, T; maycompile = true
) = BinaryOp(f, T, T, T; maycompile)

# TODO: this can and will throw INVALID_OBJECT instead of uninitializedobject
# We should then be able to capture it better? Still could be another pending object.
function GrB.GxB_fprint(x::BinaryOp, name, level, file)
    info = LibGraphBLAS.GxB_BinaryOp_fprint(x, name, level, file)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info x
        GrB.@fallbackerror info
    end
end
function Base.show(io::IO, ::MIME"text/plain", t::BinaryOp{F, F2, X, Y, Z}) where {F, F2, X, Y, Z}
    print(io, "GrB_BinaryOp{$(string(F))($X, $Y) -> $Z}: ")
    gxbprint(io, t)
end

# All types
BUILTINBINARYOPS[first] = :GrB_FIRST, Ttypes
BUILTINBINARYOPS[second] = :GrB_SECOND, Ttypes
BUILTINBINARYOPS[any] = :GxB_ANY, Ttypes # this doesn't match the semantics of Julia's any, but that may be 

BUILTINBINARYOPS[ispair] = :GrB_ONEB, Ttypes
BUILTINBINARYOPS[+] = :GrB_PLUS, Ttypes
BUILTINBINARYOPS[-] = :GrB_MINUS, Ttypes

BUILTINBINARYOPS[rminus] = :GxB_RMINUS, Ttypes

BUILTINBINARYOPS[*] = :GrB_TIMES, Ttypes
BUILTINBINARYOPS[/] = :GrB_DIV, Ttypes
BUILTINBINARYOPS[\] = :GxB_RDIV, Ttypes
BUILTINBINARYOPS[^] = :GxB_POW, Ttypes



# Real types
BUILTINBINARYOPS[min] = :GrB_MIN, Rtypes
BUILTINBINARYOPS[max] = :GrB_MAX, Rtypes

# These are not in top level namespace because they should
# only be accessible via GrB_BinaryOp construction of
# the operators.
iseq(x::T, y::U) where {T, U} = promote_type(T, U)(x == y)
isne(x::T, y::U) where {T, U} = promote_type(T, U)(x != y)
isgt(x::T, y::U) where {T, U} = promote_type(T, U)(x > y)
islt(x::T, y::U) where {T, U} = promote_type(T, U)(x < y)
isge(x::T, y::U) where {T, U} = promote_type(T, U)(x >= y)
isle(x::T, y::U) where {T, U} = promote_type(T, U)(x <= y)
BUILTINBINARYOPS[iseq] = :GxB_ISEQ, Ttypes
BUILTINBINARYOPS[isne] = :GxB_ISNE, Ttypes
BUILTINBINARYOPS[isgt] = :GxB_ISGT, Rtypes
BUILTINBINARYOPS[islt] = :GxB_ISLT, Rtypes
BUILTINBINARYOPS[isge] = :GxB_ISGE, Rtypes
BUILTINBINARYOPS[isle] = :GxB_ISLE, Rtypes

BUILTINBINARYOPS[(∨)] = :GxB_LOR, Rtypes

BUILTINBINARYOPS[(∧)] = :GxB_LAND, Rtypes

const LOR_BOOL = binarybuiltin(|, Bool, Bool, Bool, "GxB_LOR_BOOL")
const LAND_BOOL = binarybuiltin(&, Bool, Bool, Bool, "GxB_LAND_BOOL")

BinaryOp(::typeof(|), ::Type{Bool}, ::Type{Bool}, ::Type{Bool}) = LOR_BOOL
BinaryOp(::typeof(&), ::Type{Bool}, ::Type{Bool}, ::Type{Bool}) = LAND_BOOL

BUILTINBINARYOPS[lxor] = :GxB_LXOR, Rtypes

# T/R => Bool
BUILTINBINARYOPS[(==)] = :GrB_EQ, Ttypes
BUILTINBINARYOPS[(!=)] = :GrB_NE, Ttypes
BUILTINBINARYOPS[(>)] = :GrB_GT, Rtypes
BUILTINBINARYOPS[(<)] = :GrB_LT, Rtypes
BUILTINBINARYOPS[(>=)] = :GrB_GE, Rtypes
BUILTINBINARYOPS[(<=)] = :GrB_LE, Rtypes

# Bool=>Bool, most of which are covered above.
BUILTINBINARYOPS[xnor] = :GrB_LXNOR, (Bool,)


BUILTINBINARYOPS[atan] = :GxB_ATAN2, Ftypes
BUILTINBINARYOPS[hypot] = :GxB_HYPOT, Ftypes
BUILTINBINARYOPS[mod] = :GxB_FMOD, Ftypes
BUILTINBINARYOPS[rem] = :GxB_REMAINDER, Ftypes
BUILTINBINARYOPS[ldexp] = :GxB_LDEXP, Ftypes
BUILTINBINARYOPS[copysign] = :GxB_COPYSIGN, Ftypes
BUILTINBINARYOPS[complex] = :GxB_CMPLX, Ftypes

# bitwise
BUILTINBINARYOPS[(|)] = :GrB_BOR, Itypes
BUILTINBINARYOPS[(&)] = :GrB_BAND, Itypes
BUILTINBINARYOPS[⊻] = :GrB_BXOR, Itypes
BUILTINBINARYOPS[bxnor] = :GrB_BXNOR, Itypes
const LXOR_BOOL = binarybuiltin(⊻, Bool, Bool, Bool, "GxB_LXOR_BOOL")
BinaryOp(::typeof(⊻), ::Type{Bool}, ::Type{Bool}, ::Type{Bool}) = LXOR_BOOL

# leaving these without any equivalent Julia functions
# probably should only operate on Ints anyway.

BUILTINBINARYOPS[bget] = :GxB_BGET, Itypes
BUILTINBINARYOPS[bset] = :GxB_BSET, Itypes
BUILTINBINARYOPS[bclr] = :GxB_BCLR, Itypes

BUILTINBINARYOPS[(>>)] = :GxB_BSHIFT, (Itypes..., Int8)


# Positionals with dummy functions for output type inference purposes
BUILTINBINARYOPS[firsti0] = :GxB_FIRSTI, (Any,)
BUILTINBINARYOPS[firsti] =  :GxB_FIRSTI1, (Any,)

BUILTINBINARYOPS[firstj0] = :GxB_FIRSTJ, (Any,)
BUILTINBINARYOPS[firstj] = :GxB_FIRSTJ1, (Any,)

BUILTINBINARYOPS[secondi0] = :GxB_SECONDI, (Any,)
BUILTINBINARYOPS[secondi] = :GxB_SECONDI1, (Any,)

BUILTINBINARYOPS[secondj0] = :GxB_SECONDJ, (Any,)
BUILTINBINARYOPS[secondj] = :GxB_SECONDJ1, (Any,)

GrB.inputisany(::typeof(firsti0)) = true
GrB.inputisany(::typeof(firsti)) = true
GrB.inputisany(::typeof(firstj0)) = true
GrB.inputisany(::typeof(firstj)) = true
GrB.inputisany(::typeof(secondi0)) = true
GrB.inputisany(::typeof(secondi)) = true
GrB.inputisany(::typeof(secondj0)) = true
GrB.inputisany(::typeof(secondj)) = true

end
