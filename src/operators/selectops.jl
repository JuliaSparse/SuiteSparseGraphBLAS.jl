mutable struct SelectOp <: AbstractSelectOp
    p::libgb.GxB_SelectOp
    function SelectOp(p::libgb.GxB_SelectOp)
        d = new(p)
        function f(selectop)
            libgb.GxB_SelectOp_free(Ref(selectop.p))
        end
        return finalizer(f, d)
    end
end

const SelectUnion = Union{AbstractSelectOp, libgb.GxB_SelectOp}

function SelectOp()
    return SelectOp(libgb.GxB_SelectOp_new())
end

Base.unsafe_convert(::Type{libgb.GxB_SelectOp}, selectop::SelectOp) = selectop.p


baremodule SelectOps
import ..SuiteSparseGraphBLAS: load_global, SelectOp
import ..Types
import ..libgb: GB_SelectOp_opaque
end

function _loadselectops()
    builtins = ["GxB_TRIL",
    "GxB_TRIU",
    "GxB_DIAG",
    "GxB_OFFDIAG",
    "GxB_NONZERO",
    "GxB_EQ_ZERO",
    "GxB_GT_ZERO",
    "GxB_GE_ZERO",
    "GxB_LT_ZERO",
    "GxB_LE_ZERO",
    "GxB_NE_THUNK",
    "GxB_EQ_THUNK",
    "GxB_GT_THUNK",
    "GxB_GE_THUNK",
    "GxB_LT_THUNK",
    "GxB_LE_THUNK"]
    for name ∈ builtins
        simple = Symbol(replace(string(name[5:end]), "_THUNK" => ""))
        constquote = quote
            const $simple = SelectOp(load_global($name, GB_SelectOp_opaque))
        end
        @eval(SelectOps, $constquote)
    end
end

isloaded(d::AbstractSelectOp) = d.p !== C_NULL
function Base.getindex(o::AbstractSelectOp)
    o.p
end

function validtypes(::AbstractSelectOp)
    return Any
end

Base.show(io::IO, ::MIME"text/plain", s::SelectUnion) = gxbprint(io, s)

"""
    select(SelectOps.TRIL, A, k=0)

Select the entries on or below the `k`th diagonal of A.
"""
SelectOps.TRIL
"""
    select(SelectOps.TRIU, A, k=0)

Select the entries on or above the `k`th diagonal of A.
"""
SelectOps.TRIU
"""
    select(SelectOps.DIAG, A, k=0)

Select the entries on the `k`th diagonal of A.
"""
SelectOps.DIAG
"""
    select(SelectOps.OFFDIAG, A, k=0)

Select the entries **not** on the `k`th diagonal of A.
"""
SelectOps.OFFDIAG
"""
    select(SelectOps.NONZERO, A)

Select all entries in A with nonzero value.
"""
SelectOps.NONZERO
"""
    select(SelectOps.NONZERO, A)

Select all entries in A equal to zero.
"""
SelectOps.EQ_ZERO
"""
    select(SelectOps.EQ_ZERO, A)

Select all entries in A greater than zero.
"""
SelectOps.GT_ZERO
"""
    select(SelectOps.GT_ZERO, A)

Select all entries in A greater than or equal to zero.
"""
SelectOps.GE_ZERO
"""
    select(SelectOps.GE_ZERO, A)

Select all entries in A less than zero.
"""
SelectOps.LT_ZERO
"""
    select(SelectOps.LE_ZERO, A)

Select all entries in A less than or equal to zero.
"""
SelectOps.LE_ZERO
"""
    select(SelectOps.NE, A, k)

Select all entries not equal to `k`.
"""
SelectOps.NE
"""
    select(SelectOps.EQ, A, k)

Select all entries equal to `k`.
"""
SelectOps.EQ
"""
    select(SelectOps.GT, A, k)

Select all entries greater than `k`.
"""
SelectOps.GT
"""
    select(SelectOps.GE, A, k)

Select all entries greater than or equal to `k`.
"""
SelectOps.GE
"""
    select(SelectOps.LT, A, k)

Select all entries less than `k`.
"""
SelectOps.LT
"""
    select(SelectOps.LE, A, k)

Select all entries less than or equal to `k`.
"""
SelectOps.LE
