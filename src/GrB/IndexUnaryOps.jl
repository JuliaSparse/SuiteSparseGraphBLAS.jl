module IndexUnaryOps
import ..GrB
import ..GrB:
    Itypes, Ftypes, Ztypes, FZtypes, Rtypes,
    Ntypes, Ttypes, suffix, load_global,
    set!,
    LibGraphBLAS, OperatorCompiler, colindex0, rowindex0,
    GxB_fprint, inputisany, gxbprint, domains, IndexUnaryOp

import SparseBase: storedeltype
using LinearAlgebra

domains(::IndexUnaryOp{F, F2, X, T, Z}) where {F, F2, X, T, Z} = (X, Int64, Int64, T) => Z

"""
    cindexunary(f::Function, ::Type{X}, ::Type{T}, ::Type{Z}) -> Cvoid

Create a C function pointer for an index-unary function `f` with signature 
    `f(z::Ptr{Z}, x::Ptr{X}, i::Int64, j::Int64, thunk::Ptr{T})::Nothing`.

Used to supply a function pointer to a `GrB_IndexUnaryOp` from Julia function `f`. 
On certain platforms closure functions are not supported (e.g. Aarch64), 
this function will throw an `ArgumentError` in those cases.
"""
@generated function cindexunary(f::F, ::Type{X}, ::Type{T}, ::Type{Z}) where {F, X, T, Z}
    if Base.issingletontype(F)
        :(@cfunction($(F.instance), Cvoid, (Ptr{Z}, Ptr{X}, Int64, Int64, Ptr{T})))
    else
        throw("Unsupported function $f.")
    end
end

function Base.unsafe_convert(
    ::Type{LibGraphBLAS.GrB_IndexUnaryOp}, 
    op::IndexUnaryOp{F, F2, X, T, Z}
) where {F, F2, X, T, Z}
    if !op.loaded
        if op.builtin
            op.p = load_global(op.typestr, LibGraphBLAS.GrB_IndexUnaryOp)
        else
            opref = Ref{LibGraphBLAS.GrB_IndexUnaryOp}()
            z, x, t = GrB.Type(Z), GrB.Type(X), GrB.Type(T)
            info = LibGraphBLAS.GxB_IndexUnaryOp_new(
                opref, 
                cindexunary(op.c_fn, X, T, Z), 
                z, x, t, 
                op.maycompile ? op.typestr : C_NULL, 
                op.maycompile ? "GB_ISOBJ $(op.bitcodepath)" : C_NULL
            )
            if info != LibGraphBLAS.GrB_SUCCESS
                GrB.@uninitializedobject info z x t
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

function GrB.nothrow_wait!(op::IndexUnaryOp, mode) 
    return LibGraphBLAS.GrB_IndexUnaryOp_wait(op, mode)
end
function GrB.wait!(op::IndexUnaryOp, mode) 
    info = GrB.nothrow_wait!(op, mode)
    if info != LibGraphBLAS.GrB_SUCCESS
        # Technically pending OOB can throw here, but I don't see how on a IndexUnaryOp.
        GrB.@invalidvalue info mode
        GrB.@uninitializedobject info op
        GrB.@fallbackerror info
    end
end

"""
    INDEXUNARYOPS::Dict{Any, Any}

Cache keyed on tuples of the form (f, x, t, z) where `f` is a function, `x, t` are the input types
    and `z` is the output type. Returns a [`IndexUnaryOp`](@ref)
"""
const INDEXUNARYOPS = Dict()
"""
    COMPILEDINDEXUNARYOPS::Dict{Any, Any}

Internal compiler cache for GPUCompiler.cached_compile.
"""
const COMPILEDINDEXUNARYOPS = Dict() 
"""
    BUILTININDEXUNARYOPS::Dict{Any, Any}

List of indexunaryops built into SuiteSparseGraphBLAS.jl.
Keyed on functions `f` and returns (name_symbol, inputtypes)
"""
const BUILTININDEXUNARYOPS = IdDict{<:Any, <:Any}() # (f) -> (name, inputtype(s))

function linker(job, compiled)
    irpath, name = OperatorCompiler.writeir(compiled)
    (; fn, c_fn, intypes) = job.config.params
    return IndexUnaryOp{
        typeof(fn), 
        storedeltype(intypes[2]), 
        storedeltype(intypes[end]), 
        storedeltype(intypes[1])
    }(
        false, false, name, fn, c_fn;
        maycompile = true, irpath
    )
end

function indexunarycachecompile(
    f, ptrfunction, ::Type{X}, ::Type{T}, ::Type{Z}; 
    maycompile = true
) where {X, T, Z}
    job = OperatorCompiler.operatorjob(f, ptrfunction, (Ptr{Z}, Ptr{X}, Int64, Int64, Ptr{T}))
    op = OperatorCompiler.cached_compile(COMPILEDINDEXUNARYOPS, job, linker)
    op.maycompile = op.maycompile || maycompile
    return op
end

function indexunarybuiltin(f, X, T, Z, builtin_name)
    if f ∈ (rowindex, rowindex32, colindex, colindex32, diagindex, diagindex32)
        namestr = string(builtin_name[1]) * "_$(suffix(Z))"
    elseif f ∈ (tril, triu, diag, offdiag, colle, colgt, rowle, rowgt)
        namestr = string(builtin_name[1])
    else
        namestr = string(builtin_name[1]) * "_$(suffix(X))"
    end
    namestr = (X <: Complex || T <: Complex) ? "GxB" * namestr[4:end] : namestr
    return IndexUnaryOp{typeof(f), X, T, Z}(
        true, false, namestr, f
    )
end

"""
    IndexUnaryOp(f::Function, ::Type{X}, ::Type{T}, ::Type{Z}) -> UnaryOp{F, F2, X, T, Z}

Create a `GrB_IndexUnaryOp` from a Julia function `f` with signature 
    `f(x::X, i::Int64, j::Int64, thunk::T) -> z::Z`.

Most users should not call this function directly.
Instead pass a normal Julia function to a GraphBLAS operation.

# Arguments
- `f`: Julia function to wrap.
- `X::DataType`: Primary input type.
- `T::DataType`: Thunk input type.
- `Z::DataType`: Output type.
- `maycompile::Bool`: If `maycompile` is `true`, JIT compilation may be performed. 
If false, function pointers will be used. Note: this is currently a one way switch, 
it may be turned from `false` to `true`, but not back to `false`.

Function `f` must not allocate, yield, or throw.
"""
function IndexUnaryOp(
    f, ::Type{X}, ::Type{T}, ::Type{Z}; maycompile = true
) where {X, T, Z}
    # some binaryops take any types, including UDTs
    x, t, z = inputisany(f) ? (Any, Int64, Bool) : (X, T, Z)

    maybeop = Base.get!(INDEXUNARYOPS, (f, x, t, z)) do
        builtin_name = Base.get(BUILTININDEXUNARYOPS, f, nothing)
        if builtin_name !== nothing && (
            (x ∈ builtin_name[2] && (
                inputisany(f) || 
                (length(builtin_name) == 4 ? t == builtin_name[3] : t ∈ builtin_name[2])))
        )
            return indexunarybuiltin(f, x, t, z, builtin_name)
        else
            return nothing
        end
    end
    if maybeop isa IndexUnaryOp
        return maybeop
    elseif maybeop === nothing
        function GrB_IndexUnaryOpfn(z, x, i, j, t)
            Base.unsafe_store!(z, f(Base.unsafe_load(x), i, j, Base.unsafe_load(t)))
            return nothing
        end
        INDEXUNARYOPS[(f, x, t, z)] = GrB_IndexUnaryOpfn
        return indexunarycachecompile(f, GrB_IndexUnaryOpfn, X, T, Z; maycompile)
    else
        return indexunarycachecompile(f, maybeop, X, T, Z; maycompile)
    end
end

IndexUnaryOp(f, X, T, Z; maycompile = true) = 
    IndexUnaryOp(f, storedeltype(X), storedeltype(T), storedeltype(Z); maycompile)
IndexUnaryOp(op::IndexUnaryOp, ::Type{X}, ::Type{T}, ::Type{Z}; kwargs...) where {X, T, Z} = op

function GrB.GxB_fprint(x::IndexUnaryOp, name, level, file)
    info = LibGraphBLAS.GxB_IndexUnaryOp_fprint(x, name, level, file)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info x
        GrB.@fallbackerror info
    end
end
function Base.show(io::IO, ::MIME"text/plain", t::IndexUnaryOp{F, F2, X, T, Z}) where {F, F2, X, T, Z}
    print(io, "GrB_IndexUnaryOp{$(string(F))($X, $T) -> $Z}: ")
    gxbprint(io, t)
end

"""
    defaultthunk(op, ::Type{T}) = ...

The default value provided for the `thunk` argument of a
function with the signature `f(xᵢⱼ, i, j, thunk)`.

Overload this for new functions to provide a default value for `thunk` arguments of `apply` and `select`.
"""
defaultthunk(op, T) = nothing

# All types:
rowindex(xᵢⱼ, y::Int64) = 1::Int64 # i + y
rowindex32(xᵢⱼ, y::Int64) = 1::Int32 # i + y
colindex(xᵢⱼ, y::Int64) = 1::Int64 # j + y
colindex32(xᵢⱼ, y::Int64) = 1::Int32 # j + y
diagindex(xᵢⱼ, y::Int64)  = 1::Int64 # j - (i + y)
diagindex32(xᵢⱼ, y::Int64)  = 1::Int32 # j - (i + y)

BUILTININDEXUNARYOPS[rowindex] = :GrB_ROWINDEX, (Any,), (Int64,), Int64
BUILTININDEXUNARYOPS[colindex] = :GrB_COLINDEX, (Any,), (Int64,), Int64
BUILTININDEXUNARYOPS[diagindex] = :GrB_DIAGINDEX, (Any,), (Int64,), Int64
BUILTININDEXUNARYOPS[rowindex32] = :GrB_ROWINDEX, (Any,), (Int64,), Int32
BUILTININDEXUNARYOPS[colindex32] = :GrB_COLINDEX, (Any,), (Int64,), Int32
BUILTININDEXUNARYOPS[diagindex32] = :GrB_DIAGINDEX, (Any,), (Int64,), Int32

offdiag(xᵢⱼ, y::Int64) = true # j - (i + y)
BUILTININDEXUNARYOPS[tril] = :GrB_TRIL, (Any,), (Int64,), Bool
BUILTININDEXUNARYOPS[triu] = :GrB_TRIU, (Any,), (Int64,), Bool
BUILTININDEXUNARYOPS[diag] = :GrB_DIAG, (Any,), (Int64,), Bool
BUILTININDEXUNARYOPS[offdiag] = :GrB_OFFDIAG, (Any,), (Int64,), Bool

colle(xᵢⱼ, y::Int64) = 1::Bool # j <= y
colgt(xᵢⱼ, y::Int64) = 1::Bool # j > y
rowle(xᵢⱼ, y::Int64) = 1::Bool # i <= y
rowgt(xᵢⱼ, y::Int64) = 1::Bool # i > y
BUILTININDEXUNARYOPS[colle] = :GrB_COLLE, (Any,), (Int64,), Bool
BUILTININDEXUNARYOPS[colgt] = :GrB_COLGT, (Any,), (Int64,), Bool
BUILTININDEXUNARYOPS[rowle] = :GrB_ROWLE, (Any,), (Int64,), Bool
BUILTININDEXUNARYOPS[rowgt] = :GrB_ROWGT, (Any,), (Int64,), Bool

BUILTININDEXUNARYOPS[==] = :GrB_VALUEEQ, Ttypes
BUILTININDEXUNARYOPS[!=] = :GrB_VALUENE, Ttypes
BUILTININDEXUNARYOPS[<] = :GrB_VALUELT, Rtypes
BUILTININDEXUNARYOPS[>] = :GrB_VALUEGT, Rtypes
BUILTININDEXUNARYOPS[<=] = :GrB_VALUELE, Rtypes
BUILTININDEXUNARYOPS[>=] = :GrB_VALUEGE, Rtypes

for f ∈ (
    rowindex, colindex, diagindex, rowindex32, colindex32, diagindex32, 
    offdiag, tril, triu, diag
)
    @eval defaultthunk(::typeof($f), _) = zero(Int64)
end

GrB.inputisany(::typeof(rowindex)) = true
GrB.inputisany(::typeof(colindex)) = true
GrB.inputisany(::typeof(diagindex)) = true
GrB.inputisany(::typeof(offdiag)) = true
GrB.inputisany(::typeof(tril)) = true
GrB.inputisany(::typeof(triu)) = true
GrB.inputisany(::typeof(diag)) = true
GrB.inputisany(::typeof(colle)) = true
GrB.inputisany(::typeof(colgt)) = true
GrB.inputisany(::typeof(rowle)) = true
GrB.inputisany(::typeof(rowgt)) = true

for F ∈ [
    rowindex, colindex,
    diagindex, rowindex32,
    colindex32, diagindex32,
    offdiag, colle,
    colgt, rowle,
    rowgt,
    tril,
    triu,
    diag,
]
    @eval isindexop(::typeof($F)) = true
end
# for F ∈ [
#     tril,
#     triu,
#     diag,
# ]
#     @eval SuiteSparseGraphBLAS.inferbinarytype(::Any, ::Integer, ::typeof($F)) = Bool
# end
isindexop(::IndexUnaryOp) = true
isindexop(_) = false
end
