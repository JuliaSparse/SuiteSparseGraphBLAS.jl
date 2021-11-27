mutable struct SelectOp <: AbstractSelectOp
    name::String
    p::libgb.GxB_SelectOp
    juliaop::Union{Function, Nothing}
    function SelectOp(name, p::libgb.GxB_SelectOp, juliaop)
        d = new(name, p, juliaop)
        function f(selectop)
            libgb.GxB_SelectOp_free(Ref(selectop.p))
        end
        return finalizer(f, d)
    end
end

const SelectUnion = Union{AbstractSelectOp, libgb.GxB_SelectOp}

Base.unsafe_convert(::Type{libgb.GxB_SelectOp}, selectop::SelectOp) = selectop.p

const TRIL = SelectOp("GxB_TRIL", libgb.GxB_SelectOp(C_NULL), LinearAlgebra.tril)
const TRIU = SelectOp("GxB_TRIU", libgb.GxB_SelectOp(C_NULL), LinearAlgebra.triu)
const DIAG = SelectOp("GxB_DIAG", libgb.GxB_SelectOp(C_NULL), LinearAlgebra.diag)

"""
    offdiag(A::GBArray, k=0)

Select the entries **not** on the `k`th diagonal of A.
"""
function offdiag end #I don't know of a function which does this already.
const OFFDIAG = SelectOp("GxB_OFFDIAG", libgb.GxB_SelectOp(C_NULL), offdiag)
offdiag(A::GBArray, k=0) = select(offdiag, A, k)

const NONZERO = SelectOp("GxB_NONZERO", libgb.GxB_SelectOp(C_NULL), nonzeros)
const EQ_ZERO = SelectOp("GxB_EQ_ZERO", libgb.GxB_SelectOp(C_NULL), nothing)
const GT_ZERO = SelectOp("GxB_GT_ZERO", libgb.GxB_SelectOp(C_NULL), nothing)
const GE_ZERO = SelectOp("GxB_GE_ZERO", libgb.GxB_SelectOp(C_NULL), nothing)
const LT_ZERO = SelectOp("GxB_LT_ZERO", libgb.GxB_SelectOp(C_NULL), nothing)
const LE_ZERO = SelectOp("GxB_LE_ZERO", libgb.GxB_SelectOp(C_NULL), nothing)
const NE = SelectOp("GxB_NE_THUNK", libgb.GxB_SelectOp(C_NULL), !=)
const EQ = SelectOp("GxB_EQ_THUNK", libgb.GxB_SelectOp(C_NULL), ==)
const GT = SelectOp("GxB_GT_THUNK", libgb.GxB_SelectOp(C_NULL), >)
const GE = SelectOp("GxB_GE_THUNK", libgb.GxB_SelectOp(C_NULL), >=)
const LT = SelectOp("GxB_LT_THUNK", libgb.GxB_SelectOp(C_NULL), <)
const LE = SelectOp("GxB_LE_THUNK", libgb.GxB_SelectOp(C_NULL), <=)

function SelectOp(name)
    simple = Symbol(replace(string(name[5:end]), "_THUNK" => ""))
    constquote = quote
        const $simple = SelectOp($name, libgb.GxB_SelectOp(C_NULL))
    end
    @eval($constquote)
end

function _loadselectops()
    TRIL.p = load_global("GxB_TRIL", libgb.GxB_SelectOp)
    TRIU.p = load_global("GxB_TRIU", libgb.GxB_SelectOp)
    DIAG.p = load_global("GxB_DIAG", libgb.GxB_SelectOp)
    OFFDIAG.p = load_global("GxB_OFFDIAG", libgb.GxB_SelectOp)
    NONZERO.p = load_global("GxB_NONZERO", libgb.GxB_SelectOp)
    EQ_ZERO.p = load_global("GxB_EQ_ZERO", libgb.GxB_SelectOp)
    GT_ZERO.p = load_global("GxB_GT_ZERO", libgb.GxB_SelectOp)
    GE_ZERO.p = load_global("GxB_GE_ZERO", libgb.GxB_SelectOp)
    LT_ZERO.p = load_global("GxB_LT_ZERO", libgb.GxB_SelectOp)
    LE_ZERO.p = load_global("GxB_LE_ZERO", libgb.GxB_SelectOp)
    NE.p = load_global("GxB_NE_THUNK", libgb.GxB_SelectOp)
    EQ.p = load_global("GxB_EQ_THUNK", libgb.GxB_SelectOp)
    GT.p = load_global("GxB_GT_THUNK", libgb.GxB_SelectOp)
    GE.p = load_global("GxB_GE_THUNK", libgb.GxB_SelectOp)
    LT.p = load_global("GxB_LT_THUNK", libgb.GxB_SelectOp)
    LE.p = load_global("GxB_LE_THUNK", libgb.GxB_SelectOp)
end


Base.getindex(::AbstractSelectOp, ::DataType) = nothing

function validtypes(::AbstractSelectOp)
    return Any
end

Base.show(io::IO, ::MIME"text/plain", s::SelectUnion) = gxbprint(io, s)
juliaop(op::AbstractSelectOp) = op.juliaop
