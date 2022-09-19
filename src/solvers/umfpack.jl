# This file was a part of Julia. License is MIT: https://julialang.org/license

# Unfortunately it's not currently possible to make this work generically.
# In the future I hope to make this work in a more generic fashion.

module GBUMFPACK

export GBUmfpackLU

import Base: (\), getproperty, show, size
using LinearAlgebra
import LinearAlgebra: Factorization, checksquare, det, logabsdet, lu, lu!, ldiv!

import Serialization: AbstractSerializer, deserialize, serialize
using Serialization
using SparseArrays
using ..SuiteSparseGraphBLAS: AbstractGBMatrix, unsafepack!, unsafeunpack!, GBMatrix, 
GBVector, AbstractGBArray, LibGraphBLAS, Sparse, Dense, ColMajor, sparsitystatus,
_sizedjlmalloc, increment!, isshallow, nnz, tempunpack!

using StorageOrders

import ..increment, ..increment!, ..decrement, ..decrement!

using SuiteSparse.UMFPACK
using SuiteSparse.UMFPACK: umferror, @isok, 
UMFVTypes,
show_umf_ctrl, show_umf_info
using SuiteSparse.LibSuiteSparse
import SuiteSparse.LibSuiteSparse:
    SuiteSparse_long,
    umfpack_dl_defaults,
    umfpack_dl_report_control,
    umfpack_dl_report_info,
    ## Type of solve
    UMFPACK_A,        # Ax=b
    UMFPACK_At,       # adjoint(A)x=b
    UMFPACK_Aat,      # transpose(A)x=b
    UMFPACK_Pt_L,     # adjoint(P)Lx=b
    UMFPACK_L,        # Lx=b
    UMFPACK_Lt_P,     # adjoint(L)Px=b
    UMFPACK_Lat_P,    # transpose(L)Px=b
    UMFPACK_Lt,       # adjoint(L)x=b
    UMFPACK_Lat,      # transpose(L)x=b
    UMFPACK_U_Qt,     # U*adjoint(Q)x=b
    UMFPACK_U,        # Ux=b
    UMFPACK_Q_Ut,     # Q*adjoint(U)x=b
    UMFPACK_Q_Uat,    # Q*transpose(U)x=b
    UMFPACK_Ut,       # adjoint(U)x=b
    UMFPACK_Uat,      # transpose(U)x=b
    ## Sizes of Control and Info arrays for returning information from solver
    UMFPACK_INFO,
    UMFPACK_CONTROL,
    # index of the control arrays in ZERO BASED indexing
    UMFPACK_PRL,
    UMFPACK_DENSE_ROW,
    UMFPACK_DENSE_COL,
    UMFPACK_BLOCK_SIZE,
    UMFPACK_ORDERING,
    UMFPACK_FIXQ,
    UMFPACK_AMD_DENSE,
    UMFPACK_AGGRESSIVE,
    UMFPACK_SINGLETONS,
    UMFPACK_ALLOC_INIT,
    UMFPACK_SYM_PIVOT_TOLERANCE,
    UMFPACK_SCALE,
    UMFPACK_FRONT_ALLOC_INIT,
    UMFPACK_DROPTOL,
    UMFPACK_IRSTEP,
    ## Status codes
    UMFPACK_OK,
    UMFPACK_WARNING_singular_matrix,
    UMFPACK_WARNING_determinant_underflow,
    UMFPACK_WARNING_determinant_overflow,
    UMFPACK_ERROR_out_of_memory,
    UMFPACK_ERROR_invalid_Numeric_object,
    UMFPACK_ERROR_invalid_Symbolic_object,
    UMFPACK_ERROR_argument_missing,
    UMFPACK_ERROR_n_nonpositive,
    UMFPACK_ERROR_invalid_matrix,
    UMFPACK_ERROR_different_pattern,
    UMFPACK_ERROR_invalid_system,
    UMFPACK_ERROR_invalid_permutation,
    UMFPACK_ERROR_internal_error,
    UMFPACK_ERROR_file_IO,
    UMFPACK_ERROR_ordering_failed


const JL_UMFPACK_PRL = UMFPACK_PRL + 1
const JL_UMFPACK_DENSE_ROW = UMFPACK_DENSE_ROW + 1
const JL_UMFPACK_DENSE_COL = UMFPACK_DENSE_COL + 1
const JL_UMFPACK_BLOCK_SIZE = UMFPACK_BLOCK_SIZE + 1
const JL_UMFPACK_ORDERING = UMFPACK_ORDERING + 1
const JL_UMFPACK_FIXQ = UMFPACK_FIXQ + 1
const JL_UMFPACK_AMD_DENSE = UMFPACK_AMD_DENSE + 1
const JL_UMFPACK_AGGRESSIVE = UMFPACK_AGGRESSIVE + 1
const JL_UMFPACK_SINGLETONS = UMFPACK_SINGLETONS + 1
const JL_UMFPACK_ALLOC_INIT = UMFPACK_ALLOC_INIT + 1
const JL_UMFPACK_SYM_PIVOT_TOLERANCE = UMFPACK_SYM_PIVOT_TOLERANCE + 1
const JL_UMFPACK_SCALE = UMFPACK_SCALE + 1
const JL_UMFPACK_FRONT_ALLOC_INIT = UMFPACK_FRONT_ALLOC_INIT + 1
const JL_UMFPACK_DROPTOL = UMFPACK_DROPTOL + 1
const JL_UMFPACK_IRSTEP = UMFPACK_IRSTEP + 1

## UMFPACK

# there might be quite a bit of duplication here.
# This is mostly to ensure that we work in 1.6, since there have been significant
# changes since then.
mutable struct Numeric{Tv}
    p::Ptr{Cvoid}
    function Numeric{Tv}(p) where {Tv<:UMFVTypes}
        return finalizer(new{Tv}(p)) do num
            umfpack_free_numeric(num, Tv, Int64)
            num.p = C_NULL
        end
    end
end
Base.unsafe_convert(::Type{Ptr{Cvoid}}, num::Numeric) = num.p

mutable struct Symbolic{Tv}
    p::Ptr{Cvoid}
    function Symbolic{Tv}(p) where {Tv<:UMFVTypes}
        return finalizer(new{Tv}(p)) do sym
            umfpack_free_symbolic(sym, Tv, Int64)
            sym.p = C_NULL
        end
    end
end
Base.unsafe_convert(::Type{Ptr{Cvoid}}, num::Symbolic) = num.p

_isnull(x::Union{Symbolic, Numeric}) = x.p == C_NULL
_isnotnull(x::Union{Symbolic, Numeric}) = x.p != C_NULL
"""
Working space for Umfpack so `ldiv!` doesn't allocate.

To use multiple threads, each thread should have their own workspace that can be allocated using `Base.similar(::UmfpackWS)`
and passed as a kwarg to `ldiv!`. Alternativly see `copy(::UmfpackLU)`. The constructor is overloaded so to create appropriate
sized working space given the lu factorization or the sparse matrix and if refinement is on.
"""
struct UmfpackWS
    Wi::Vector{Int64}
    W::Vector{Float64}
end

UmfpackWS(Wisize::Integer, Wsize::Integer)  =
    UmfpackWS(Vector{T}(undef, Wisize), Vector{Float64}(undef, Wsize))

UmfpackWS(S::AbstractGBMatrix{Tv}, refinement::Bool) where {Tv} = UmfpackWS(
    Vector{Int64}(undef, size(S, 2)),
    Vector{Float64}(undef, workspace_W_size(S, refinement)))

function Base.resize!(W::UmfpackWS, S, refinement::Bool; expand_only=false)
    (!expand_only || length(W.Wi) < size(S, 2)) && resize!(W.Wi, size(S, 2))
    ws = workspace_W_size(S, refinement)
    (!expand_only || length(W.W) < ws) && resize!(W.W, ws)
    return W
end

Base.similar(w::UmfpackWS) = UmfpackWS(similar(w.Wi), similar(w.W))

## Should this type be immutable?
mutable struct GBUmfpackLU{Tv<:UMFVTypes, M} <: Factorization{Tv}
    symbolic::Symbolic{Tv}
    numeric::Numeric{Tv}
    m::Int
    n::Int
    A::M
    status::Int
    workspace::UmfpackWS
    control::Vector{Float64}
    info::Vector{Float64}
    lock::ReentrantLock
end

workspace_W_size(F::GBUmfpackLU) = workspace_W_size(F, has_refinement(F))
workspace_W_size(S::Union{GBUmfpackLU{<:AbstractFloat}, AbstractGBMatrix{<:AbstractFloat}}, refinement::Bool) = refinement ? 5 * size(S, 2) : size(S, 2)
workspace_W_size(S::Union{GBUmfpackLU{<:Complex}, AbstractGBMatrix{<:Complex}}, refinement::Bool) = refinement ? 10 * size(S, 2) : 4 * size(S, 2)

const ATLU = Union{Transpose{<:Any, <:GBUmfpackLU}, Adjoint{<:Any, <:GBUmfpackLU}}
has_refinement(F::ATLU) = has_refinement(F.parent)
has_refinement(F::GBUmfpackLU) = has_refinement(F.control)
has_refinement(control::AbstractVector) = control[JL_UMFPACK_IRSTEP] > 0

# auto magick resize, should this only expand and not shrink?
getworkspace(F::GBUmfpackLU) = @lock F.lock begin
    return resize!(F.workspace, F, has_refinement(F); expand_only=true)
end

UmfpackWS(F::GBUmfpackLU{Tv, Ti}, refinement::Bool=has_refinement(F)) where {Tv, Ti} = UmfpackWS(
        Vector{Ti}(undef, size(F, 2)),
        Vector{Float64}(undef, workspace_W_size(F, refinement)))
UmfpackWS(F::ATLU, refinement::Bool=has_refinement(F)) = UmfpackWS(F.parent, refinement)

# Not using simlar helps if the actual needed size has changed as it would need to be resized again
"""
    copy(F::UmfpackLU, [ws::UmfpackWS]; safecopy = false) -> UmfpackLU
A shallow copy of UmfpackLU to use in multithreaded solve applications.
This function duplicates the working space, control, info and lock fields.

If `safecopy = true` is passed, then the internal Symbolic and Numeric
factorization objects will be duplicated as well. This must be done if
multiple threads may call factorization or refactorization functions
on the copy and original simultaneously.
"""
Base.copy(F::GBUmfpackLU{Tv}, ws=UmfpackWS(F); safecopy = false) where {Tv} =
    GBUmfpackLU(
        safecopy ? Symbolic{Tv}(C_NULL) : F.symbolic,
        safecopy ? Numeric{Tv}(C_NULL) : F.numeric,
        F.m, F.n,
        F.A,
        F.status,
        ws,
        copy(F.control),
        copy(F.info),
        ReentrantLock()
    )
Base.copy(F::T, ws=UmfpackWS(F)) where {T <: ATLU} =
    T(copy(parent(F), ws))

Base.adjoint(F::GBUmfpackLU) = Adjoint(F)
Base.transpose(F::GBUmfpackLU) = Transpose(F)

function Base.lock(f::Function, F::GBUmfpackLU)
    lock(F)
    try
        f()
    finally
        unlock(F)
    end
end
Base.lock(F::GBUmfpackLU) = if !trylock(F.lock)
    @info """waiting for UmfpackLU's lock, it's safe to ignore this message.
    see the documentation for Umfpack""" maxlog = 1
    lock(F.lock)
end

@inline Base.trylock(F::GBUmfpackLU) = trylock(F.lock)
@inline Base.unlock(F::GBUmfpackLU) = unlock(F.lock)

UMFPACK.show_umf_ctrl(F::GBUmfpackLU, level::Real=2.0) =
    @lock F UMFPACK.show_umf_ctrl(F.control, level)


UMFPACK.show_umf_info(F::GBUmfpackLU, level::Real=2.0) =
    @lock F UMFPACK.show_umf_info(F.control, F.info, level)


"""
    lu(A::AbstractGBMatrix; check = true, q = nothing, control = get_umfpack_control()) -> F::UmfpackLU

Compute the LU factorization of a sparse matrix `A`.

For sparse `A` with real or complex element type, the return type of `F` is
`UmfpackLU{Tv, Ti}`, with `Tv` = [`Float64`](@ref) or `ComplexF64` respectively and
`Ti` is an integer type ([`Int32`](@ref) or [`Int64`](@ref)).

When `check = true`, an error is thrown if the decomposition fails.
When `check = false`, responsibility for checking the decomposition's
validity (via [`issuccess`](@ref)) lies with the user.

The permutation `q` can either be a permutation vector or `nothing`. If no permutation vector
is proveded or `q` is `nothing`, UMFPACK's default is used. If the permutation is not zero based, a
zero based copy is made.

The `control` vector default to the package's default configs for umfpacks but can be changed passing a
vector of length `UMFPACK_CONTROL`. See the UMFPACK manual for possible configurations. The corresponding
variables are named `JL_UMFPACK_` since julia uses one based indexing.


The individual components of the factorization `F` can be accessed by indexing:

| Component | Description                         |
|:----------|:------------------------------------|
| `L`       | `L` (lower triangular) part of `LU` |
| `U`       | `U` (upper triangular) part of `LU` |
| `p`       | right permutation `Vector`          |
| `q`       | left permutation `Vector`           |
| `Rs`      | `Vector` of scaling factors         |
| `:`       | `(L,U,p,q,Rs)` components           |

The relation between `F` and `A` is

`F.L*F.U == (F.Rs .* A)[F.p, F.q]`

`F` further supports the following functions:

- [`\\`](@ref)
- [`det`](@ref)

See also [`lu!`](@ref)

!!! note
    `lu(A::AbstractGBMatrix)` uses the UMFPACK[^ACM832] library that is part of
    [SuiteSparse](https://github.com/DrTimothyAldenDavis/SuiteSparse).
    As this library only supports sparse matrices with [`Float64`](@ref) or
    `ComplexF64` elements, `lu` converts `A` into a copy that is of type
    `SparseMatrixCSC{Float64}` or `SparseMatrixCSC{ComplexF64}` as appropriate.

[^ACM832]: Davis, Timothy A. (2004b). Algorithm 832: UMFPACK V4.3---an Unsymmetric-Pattern Multifrontal Method. ACM Trans. Math. Softw., 30(2), 196–199. [doi:10.1145/992200.992206](https://doi.org/10.1145/992200.992206)
"""
function lu(S::AbstractGBMatrix{Tv};
    check::Bool = true, q=nothing, control=get_umfpack_control(Tv, Int64)) where
    {Tv<:UMFVTypes}
    res = GBUmfpackLU(Symbolic{Tv}(C_NULL), Numeric{Tv}(C_NULL),
                    size(S, 1), size(S, 2),
                    S, 0, UmfpackWS(S, has_refinement(control)),
                    copy(control), Vector{Float64}(undef, UMFPACK_INFO),
                    ReentrantLock()
    )
    umfpack_numeric!(res; q)
    check && (issuccess(res) || throw(LinearAlgebra.SingularException(0)))
    return res
end
lu(A::AbstractGBMatrix{<:Union{Float16,Float32}};
   check::Bool = true) = lu(Float64.(A); check = check)
lu(A::AbstractGBMatrix{<:Union{ComplexF16,ComplexF32}};
   check::Bool = true) = lu(ComplexF64.(A); check = check)
lu(A::Union{AbstractGBMatrix{T},AbstractGBMatrix{Complex{T}}};
   check::Bool = true) where {T<:AbstractFloat} =
    throw(ArgumentError(string("matrix type ", typeof(A), "not supported. ",
    "Try lu(convert(SparseMatrixCSC{Float64/ComplexF64,Int}, A)) for ",
    "sparse floating point LU using UMFPACK or lu(Array(A)) for generic ",
    "dense LU.")))
lu(A::AbstractGBMatrix; check::Bool = true) = lu(float.(A); check = check)

# We could do this as lu(A') = lu(A)' with UMFPACK, but the user could want to do one over the other
lu(A::Union{Adjoint{T, S}, Transpose{T, S}}; check::Bool = true) where {T<:UMFVTypes, S<:AbstractGBMatrix{T}} =
lu(copy(A); check)

"""
    lu!(F::UmfpackLU, A::AbstractGBMatrix; check=true, reuse_symbolic=true, q=nothing) -> F::UmfpackLU

Compute the LU factorization of a sparse matrix `A`, reusing the symbolic
factorization of an already existing LU factorization stored in `F`.
Unless `reuse_symbolic` is set to false, the sparse matrix `A` must have an
identical nonzero pattern as the matrix used to create the LU factorization `F`,
otherwise an error is thrown. If the size of `A` and `F` differ, all vectors will
be resized accordingly.

When `check = true`, an error is thrown if the decomposition fails.
When `check = false`, responsibility for checking the decomposition's
validity (via [`issuccess`](@ref)) lies with the user.

The permutation `q` can either be a permutation vector or `nothing`. If no permutation vector
is proveded or `q` is `nothing`, UMFPACK's default is used. If the permutation is not zero based, a
zero based copy is made.

See also [`lu`](@ref)

!!! note
    `lu!(F::UmfpackLU, A::AbstractGBMatrix)` uses the UMFPACK library that is part of
    SuiteSparse. As this library only supports sparse matrices with [`Float64`](@ref) or
    `ComplexF64` elements, `lu!` will automatically convert the types to those set by the LU
    factorization or `SparseMatrixCSC{ComplexF64}` as appropriate.

!!! compat "Julia 1.5"
    `lu!` for `UmfpackLU` requires at least Julia 1.5.
"""
function lu!(F::GBUmfpackLU{Tv}, S::AbstractGBMatrix;
  check::Bool=true, reuse_symbolic::Bool=true, q=nothing) where {Tv}

    F.m = size(S, 1)
    F.n = size(S, 2)

    # resize workspace if needed
    resize!(F.workspace, S, has_refinement(F))
    F.A = S

    if !reuse_symbolic && _isnotnull(F.symbolic)
        F.symbolic = Symbolic{Tv, Ti}(C_NULL)
    end

    umfpack_numeric!(F; reuse_numeric=false, q)

    check && (issuccess(F) || throw(LinearAlgebra.SingularException(0)))
    return F
end

function lu!(F::GBUmfpackLU; check::Bool=true, q=nothing)
    umfpack_numeric!(F; q)
    check && (issuccess(F) || throw(LinearAlgebra.SingularException(0)))
    return F
end

size(F::GBUmfpackLU) = (F.m, F.n)
function size(F::GBUmfpackLU, dim::Integer)
    if dim < 1
        throw(ArgumentError("size: dimension $dim out of range"))
    elseif dim == 1
        return Int(F.m)
    elseif dim == 2
        return Int(F.n)
    else
        return 1
    end
end

function show(io::IO, mime::MIME{Symbol("text/plain")}, F::GBUmfpackLU)
    if _isnotnull(F.numeric)
        if issuccess(F)
            summary(io, F); println(io)
            println(io, "L factor:")
            show(io, mime, F.L)
            println(io, "\nU factor:")
            show(io, mime, F.U)
        else
            print(io, "Failed factorization of type $(typeof(F))")
        end
    end
end

function serialize(s::AbstractSerializer, L::GBUmfpackLU{Tv}) where {Tv}
    # TODO: If we can get a C FILE handle we can serialize umfpack_numeric and
    # umfpack_symbolic. using the save_{numeric | symbolic} functions.
    Serialization.serialize_type(s, typeof(L))
    serialize(s, L.m)
    serialize(s, L.n)
    serialize(s, L.A)
    serialize(s, length(L.workspace.Wi))
    serialize(s, length(L.workspace.W))
    serialize(s, L.control)
    serialize(s, L.info)
end
function deserialize(s::AbstractSerializer, ::Type{GBUmfpackLU{Tv}}) where {Tv}
    # TODO: If we can get a C FILE handle we can deserialize umfpack_numeric and
    # umfpack_symbolic. using the load_{numeric | symbolic} functions.
    m        = deserialize(s)
    n        = deserialize(s)
    A        = deserialize(s)
    Wisize   = deserialize(s)
    Wsize    = deserialize(s)
    control  = deserialize(s)
    info     = deserialize(s)
    return GBUmfpackLU{Tv}(Symbolic{Tv}(C_NULL), Numeric{Tv}(C_NULL),
        m, n, A, 0,
        UmfpackWS(Wisize, Wsize), control, info, ReentrantLock())
end

## Wrappers for UMFPACK functions
umf_name(nm,Tv) = "umfpack_" * (Tv === :Float64 ? "d" : "z") * "l_" * nm

# generate the name of the C function according to the value and integer types
sym_r = Symbol(umf_name("symbolic", :Float64))
symq_r = Symbol(umf_name("qsymbolic", :Float64))
sym_c = Symbol(umf_name("symbolic", :ComplexF64))
symq_c = Symbol(umf_name("qsymbolic", :ComplexF64))
num_r = Symbol(umf_name("numeric", :Float64))
num_c = Symbol(umf_name("numeric", :ComplexF64))
sol_r = Symbol(umf_name("solve", :Float64))
sol_c = Symbol(umf_name("solve", :ComplexF64))
wsol_r = Symbol(umf_name("wsolve", :Float64))
wsol_c = Symbol(umf_name("wsolve", :ComplexF64))
det_r = Symbol(umf_name("get_determinant", :Float64))
det_z = Symbol(umf_name("get_determinant", :ComplexF64))
lunz_r = Symbol(umf_name("get_lunz", :Float64))
lunz_z = Symbol(umf_name("get_lunz", :ComplexF64))
get_num_r = Symbol(umf_name("get_numeric", :Float64))
get_num_z = Symbol(umf_name("get_numeric", :ComplexF64))
@eval begin
    function umfpack_symbolic!(U::GBUmfpackLU{Float64}, q::Union{Nothing, StridedVector{Int64}})
        _isnotnull(U.symbolic) && return U
        @lock U begin
            tmp = Ref{Ptr{Cvoid}}(C_NULL)
            # TODO: Relax ColMajor restriction, and enable transpose tricks
            colptr, rowval, nzval, repack! = tempunpack!(U.A, Sparse(); order = ColMajor())
            if q === nothing
                m = U.m
                n = U.n
                ctrl = U.control
                info = U.info
                res = $sym_r(m, n, colptr, rowval, nzval, tmp, ctrl, info)
            else
                qq = minimum(q) == 1 ? q .- one(eltype(q)) : q
                res = $symq_r(U.m, U.n, colptr, rowval, nzval, qq, tmp, U.control, U.info)
            end
            repack!(colptr, rowval, nzval)
            @isok res
            if _isnull(U.symbolic)
                U.symbolic.p = tmp[]
            else
                U.symbolic = Symbolic{Float64}(tmp[])
            end
        end
        return U
    end
    function umfpack_symbolic!(U::GBUmfpackLU{ComplexF64}, q::Union{Nothing, StridedVector{Int64}})
        _isnotnull(U.symbolic) && return U
        @lock U begin
            tmp = Ref{Ptr{Cvoid}}(C_NULL)
            # TODO: Relax ColMajor restriction, and enable transpose tricks
            colptr, rowval, nzval, repack! = tempunpack!(U.A, Sparse(); order = ColMajor())
            if q === nothing
                res = $sym_c(U.m, U.n, colptr, rowval, real(nzval), imag(nzval), tmp,
                             U.control, U.info)
            else
                qq = minimum(q) == 1 ? q .- one(eltype(q)) : q
                res = $symq_c(U.m, U.n, colptr, rowval, real(nzval), imag(nzval), qq, tmp, U.control, U.info)
            end
            repack!(colptr, rowval, nzval)
            @isok res
            if _isnull(U.symbolic)
                U.symbolic.p = tmp[]
            else
                U.symbolic = Symbolic{ComplexF64}(tmp[])
            end
        end
        return U
    end
    function umfpack_numeric!(U::GBUmfpackLU{Float64}; reuse_numeric=true, q=nothing)
        @lock U begin
            (reuse_numeric && _isnotnull(U.numeric)) && return U
            if _isnull(U.symbolic)
                umfpack_symbolic!(U, q)
            end
            tmp = Ref{Ptr{Cvoid}}(C_NULL)
            # TODO: Relax ColMajor restriction, and enable transpose tricks
            colptr, rowval, nzval, repack! = tempunpack!(U.A, Sparse(); order = ColMajor())
            status = $num_r(colptr, rowval, nzval, U.symbolic, tmp, U.control, U.info)
            repack!(colptr, rowval, nzval)
            U.status = status
            if status != UMFPACK_WARNING_singular_matrix
                umferror(status)
            end
            if _isnull(U.numeric)
                U.numeric.p = tmp[]
            else
                U.numeric = Numeric{Float64}(tmp[])
            end
        end
        return U
    end
    function umfpack_numeric!(U::GBUmfpackLU{ComplexF64}; reuse_numeric=true, q=nothing)
        @lock U begin
            (reuse_numeric && _isnotnull(U.numeric)) && return U
            _isnull(U.symbolic) && umfpack_symbolic!(U, q)
            tmp = Ref{Ptr{Cvoid}}(C_NULL)
            # TODO: Relax ColMajor restriction, and enable transpose tricks
            colptr, rowval, nzval, repack! = tempunpack!(U.A, Sparse(); order = ColMajor())
            status = $num_c(colptr, rowval, real(nzval), imag(nzval), U.symbolic, tmp,
                U.control, U.info)
            repack!(colptr, rowval, nzval)
            U.status = status
            if status != UMFPACK_WARNING_singular_matrix
                umferror(status)
            end
            U.numeric.p = tmp[]
        end
        return U
    end
    function solve!(x::StridedVector{Float64},
        lu::GBUmfpackLU{Float64}, b::StridedVector{Float64},
        typ::Integer; workspace = getworkspace(lu))
        if x === b
            throw(ArgumentError("output array must not be aliased with input array"))
        end
        if stride(x, 1) != 1 || stride(b, 1) != 1
            throw(ArgumentError("in and output vectors must have unit strides"))
        end
        if size(lu, 2) > length(workspace.Wi)
            throw(ArgumentError("Wi should be larger than `size(Af, 2)`"))
        end
        if workspace_W_size(lu) > length(workspace.W)
            throw(ArguementError("W should be larger than `workspace_W_size(Af)`"))
        end
        @lock lu begin
            umfpack_numeric!(lu)
            (size(b, 1) == lu.m) && (size(b) == size(x)) || throw(DimensionMismatch())
            colptr, rowval, nzval, repack! = tempunpack!(U.A, Sparse(); order = storageorder(U.A))
            res = $wsol_r(typ, colptr, rowval, nzval,
                x, b, lu.numeric, lu.control,
                lu.info, workspace.Wi, workspace.W)
            repack!(colptr, rowval, nzval)
            @isok res
        end
        return x
    end
    function solve!(x::StridedVector{ComplexF64},
        lu::GBUmfpackLU{ComplexF64}, b::StridedVector{ComplexF64},
        typ::Integer; workspace = getworkspace(lu))
        if x === b
            throw(ArgumentError("output array must not be aliased with input array"))
        end
        if stride(x, 1) != 1 || stride(b, 1) != 1
            throw(ArgumentError("in and output vectors must have unit strides"))
        end
        if size(lu, 2) > length(workspace.Wi)
            throw(ArgumentError("Wi should be at least larger than `size(Af, 2)`"))
        end
        if workspace_W_size(lu) > length(workspace.W)
            throw(ArgumentError("W should be larger than `workspace_W_size(Af)`"))
        end
        @lock lu begin
            umfpack_numeric!(lu)
            (size(b, 1) == lu.m) && (size(b) == size(x)) || throw(DimensionMismatch())
            colptr, rowval, nzval, repack! = tempunpack!(U.A, Sparse(); order = storageorder(U.A))
            res = $wsol_c(typ, colptr, rowval, nzval, C_NULL, x, C_NULL, b,
                C_NULL, lu.numeric, lu.control, lu.info, workspace.Wi, workspace.W)
            repack!(colptr, rowval, nzval)
            @isok res
        end
        return x
    end
    function det(lu::GBUmfpackLU{Float64})
        mx = Ref{Float64}(zero(Float64))
        @lock lu @isok($det_r(mx, C_NULL, lu.numeric, lu.info))
        mx[]
    end
    function det(lu::GBUmfpackLU{ComplexF64})
        mx = Ref{Float64}(zero(Float64))
        mz = Ref{Float64}(zero(Float64))
        @lock lu @isok($det_z(mx, mz, C_NULL, lu.numeric, lu.info))
        complex(mx[], mz[])
    end
    # function logabsdet(F::GBUmfpackLU{T}) where {T<:Union{Float64,ComplexF64}} # return log(abs(det)) and sign(det)
    #     n = checksquare(F)
    #     issuccess(F) || return log(zero(real(T))), zero(T)
    #     U = F.U
    #     Rs = F.Rs
    #     p = F.p
    #     q = F.q
    #     s = _signperm(p)*_signperm(q)*one(real(T))
    #     P = one(T)
    #     abs_det = zero(real(T))
    #     @inbounds for i in 1:n
    #         dg_ii = U[i, i] / Rs[i]
    #         P *= sign(dg_ii)
    #         abs_det += log(abs(dg_ii))
    #     end
    #     return abs_det, s * P
    # end
    function umf_lunz(lu::GBUmfpackLU{Float64})
        lnz = Ref{Int64}(zero(Int64))
        unz = Ref{Int64}(zero(Int64))
        n_row = Ref{Int64}(zero(Int64))
        n_col = Ref{Int64}(zero(Int64))
        nz_diag = Ref{Int64}(zero(Int64))
        @isok $lunz_r(lnz, unz, n_row, n_col, nz_diag, lu.numeric)
        (lnz[], unz[], n_row[], n_col[], nz_diag[])
    end
    function umf_lunz(lu::GBUmfpackLU{ComplexF64})
        lnz = Ref{Int64}(zero(Int64))
        unz = Ref{Int64}(zero(Int64))
        n_row = Ref{Int64}(zero(Int64))
        n_col = Ref{Int64}(zero(Int64))
        nz_diag = Ref{Int64}(zero(Int64))
        @isok $lunz_z(lnz, unz, n_row, n_col, nz_diag, lu.numeric)
        (lnz[], unz[], n_row[], n_col[], nz_diag[])
    end
    function getproperty(lu::GBUmfpackLU{Float64}, d::Symbol)
        if d === :L
            umfpack_numeric!(lu)        # ensure the numeric decomposition exists
            (lnz, unz, n_row, n_col, nz_diag) = umf_lunz(lu)
            Lp = unsafe_wrap(Array, _sizedjlmalloc(n_row + 1, Int64), n_row + 1)
            Lj = unsafe_wrap(Array, _sizedjlmalloc(lnz, Int64), lnz)
            Lx = unsafe_wrap(Array, _sizedjlmalloc(lnz, Float64), lnz)
            # L is returned in CSR (compressed sparse row) format
            @isok $get_num_r(
                        Lp, Lj, Lx,
                        C_NULL, C_NULL, C_NULL,
                        C_NULL, C_NULL, C_NULL,
                        C_NULL, C_NULL, lu.numeric)
            out = similar(lu.A, Float64, size(lu.A)...)
            return unsafepack!(out, Lp, Lj, Lx, false; order = RowMajor())
        elseif d === :U
            umfpack_numeric!(lu)        # ensure the numeric decomposition exists
            (lnz, unz, n_row, n_col, nz_diag) = umf_lunz(lu)
            Up = unsafe_wrap(Array, _sizedjlmalloc(n_col + 1, Int64), n_col + 1)
            Ui = unsafe_wrap(Array, _sizedjlmalloc(lnz, Int64), unz)
            Ux = unsafe_wrap(Array, _sizedjlmalloc(lnz, Float64), unz)
            @isok $get_num_r(
                        C_NULL, C_NULL, C_NULL,
                        Up, Ui, Ux,
                        C_NULL, C_NULL, C_NULL,
                        C_NULL, C_NULL, lu.numeric)
            out = similar(lu.A, Float64, size(lu.A)...)
            return unsafepack!(out, Up, Ui, Ux, false)
        elseif d === :p
            umfpack_numeric!(lu)        # ensure the numeric decomposition exists
            (lnz, unz, n_row, n_col, nz_diag) = umf_lunz(lu)
            P = unsafe_wrap(Array, _sizedjlmalloc(n_row, Int64), n_row)
            @isok $get_num_r(
                        C_NULL, C_NULL, C_NULL,
                        C_NULL, C_NULL, C_NULL,
                        P, C_NULL, C_NULL,
                        C_NULL, C_NULL, lu.numeric)
            out = similar(lu.A, Int64, n_row)
            return unsafepack!(out, increment!(P), false)
        elseif d === :q
            umfpack_numeric!(lu)        # ensure the numeric decomposition exists
            (lnz, unz, n_row, n_col, nz_diag) = umf_lunz(lu)
            Q = unsafe_wrap(Array, _sizedjlmalloc(n_col, Int64), n_col)
            @isok $get_num_r(
                        C_NULL, C_NULL, C_NULL,
                        C_NULL, C_NULL, C_NULL,
                        C_NULL, Q, C_NULL,
                        C_NULL, C_NULL, lu.numeric)
            out = similar(lu.A, Int64, n_col)
            return unsafepack!(out, increment!(Q), false)
        elseif d === :Rs
            umfpack_numeric!(lu)        # ensure the numeric decomposition exists
            (lnz, unz, n_row, n_col, nz_diag) = umf_lunz(lu)
            Rs = unsafe_wrap(Array, _sizedjlmalloc(n_row, Float64), n_row)
            @isok $get_num_r(
                        C_NULL, C_NULL, C_NULL,
                        C_NULL, C_NULL, C_NULL,
                        C_NULL, C_NULL, C_NULL,
                        C_NULL, Rs, lu.numeric)
            out = similar(lu.A, Float64, n_row)
            return unsafepack!(out, Rs, false)
        elseif d === :(:)
            return (lu.L, lu.U, lu.p, lu.q, lu.Rs)
        else
            return getfield(lu, d)
        end
    end
    function getproperty(lu::GBUmfpackLU{ComplexF64}, d::Symbol)
        if d === :L
            umfpack_numeric!(lu)        # ensure the numeric decomposition exists
            (lnz, unz, n_row, n_col, nz_diag) = umf_lunz(lu)
            Lp = unsafe_wrap(Array, _sizedjlmalloc(n_row + 1, Int64), n_row + 1)
            Lj = unsafe_wrap(Array, _sizedjlmalloc(lnz, Int64), lnz)
            Lx = Vector{Float64}(undef, lnz)
            Lz = Vector{Float64}(undef, lnz)
            @isok $get_num_z(
                        Lp, Lj, Lx, Lz,
                        C_NULL, C_NULL, C_NULL, C_NULL,
                        C_NULL, C_NULL, C_NULL, C_NULL,
                        C_NULL, C_NULL, lu.numeric)
            out = similar(lu.A, ComplexF64, size(lu.A)...)
            return unsafepack!(out, Lp, Lj, 
                SuiteSparseGraphBLAS._copytoraw(Complex.(Lx, Lz)), false; order = RowMajor()
            )
        elseif d === :U
            umfpack_numeric!(lu)        # ensure the numeric decomposition exists
            (lnz, unz, n_row, n_col, nz_diag) = umf_lunz(lu)
            Up = unsafe_wrap(Array, _sizedjlmalloc(n_col + 1, Int64), n_col + 1)
            Ui = unsafe_wrap(Array, _sizedjlmalloc(unz, Int64), unz)
            Ux = Vector{Float64}(undef, unz)
            Uz = Vector{Float64}(undef, unz)
            @isok $get_num_z(
                        C_NULL, C_NULL, C_NULL, C_NULL,
                        Up, Ui, Ux, Uz,
                        C_NULL, C_NULL, C_NULL, C_NULL,
                        C_NULL, C_NULL, lu.numeric)
            out = similar(lu.A, ComplexF64, size(lu.A)...)
            return unsafepack!(
                out, Lp, Lj, 
                SuiteSparseGraphBLAS._copytoraw(Complex.(Lx, Lz)), false
            )
        elseif d === :p
            umfpack_numeric!(lu)        # ensure the numeric decomposition exists
            (lnz, unz, n_row, n_col, nz_diag) = umf_lunz(lu)
            P = unsafe_wrap(Array, _sizedjlmalloc(n_row, Int64), n_row)
            @isok $get_num_r(
                        C_NULL, C_NULL, C_NULL,
                        C_NULL, C_NULL, C_NULL,
                        P, C_NULL, C_NULL,
                        C_NULL, C_NULL, lu.numeric)
            out = similar(lu.A, Int64, n_row)
            return unsafepack!(out, increment!(P), false)
        elseif d === :q
            umfpack_numeric!(lu)        # ensure the numeric decomposition exists
            (lnz, unz, n_row, n_col, nz_diag) = umf_lunz(lu)
            Q = unsafe_wrap(Array, _sizedjlmalloc(n_col, Int64), n_col)
            @isok $get_num_r(
                        C_NULL, C_NULL, C_NULL,
                        C_NULL, C_NULL, C_NULL,
                        C_NULL, Q, C_NULL,
                        C_NULL, C_NULL, lu.numeric)
            out = similar(lu.A, Int64, n_col)
            return unsafepack!(out, increment!(Q), false)
        elseif d === :Rs
            umfpack_numeric!(lu)        # ensure the numeric decomposition exists
            (lnz, unz, n_row, n_col, nz_diag) = umf_lunz(lu)
            Rs = unsafe_wrap(Array, _sizedjlmalloc(n_row, Float64), n_row)
            @isok $get_num_r(
                        C_NULL, C_NULL, C_NULL,
                        C_NULL, C_NULL, C_NULL,
                        C_NULL, C_NULL, C_NULL,
                        C_NULL, Rs, lu.numeric)
            out = similar(lu.A, Float64, n_row)
            return unsafepack!(out, Rs, false)
        elseif d === :(:)
            return (lu.L, lu.U, lu.p, lu.q, lu.Rs)
        else
            return getfield(lu, d)
        end
    end
end

# backward compatibility
umfpack_extract(lu::GBUmfpackLU) = getproperty(lu, :(:))

function SparseArrays.nnz(lu::GBUmfpackLU)
    lnz, unz, = umf_lunz(lu)
    return Int(lnz + unz)
end

LinearAlgebra.issuccess(lu::GBUmfpackLU) = lu.status == UMFPACK_OK

### Solve with Factorization

import LinearAlgebra.ldiv!

ldiv!(lu::GBUmfpackLU{T}, B::StridedVecOrMat{T}) where {T<:UMFVTypes} =
    ldiv!(B, lu, copy(B))
ldiv!(translu::Transpose{T,<:GBUmfpackLU{T}}, B::StridedVecOrMat{T}) where {T<:UMFVTypes} =
    (lu = translu.parent; ldiv!(B, transpose(lu), copy(B)))
ldiv!(adjlu::Adjoint{T,<:GBUmfpackLU{T}}, B::StridedVecOrMat{T}) where {T<:UMFVTypes} =
    (lu = adjlu.parent; ldiv!(B, adjoint(lu), copy(B)))
ldiv!(lu::GBUmfpackLU{Float64}, B::StridedVecOrMat{<:Complex}) =
    ldiv!(B, lu, copy(B))
ldiv!(translu::Transpose{Float64,<:GBUmfpackLU{Float64}}, B::StridedVecOrMat{<:Complex}) =
    (lu = translu.parent; ldiv!(B, transpose(lu), copy(B)))
ldiv!(adjlu::Adjoint{Float64,<:GBUmfpackLU{Float64}}, B::StridedVecOrMat{<:Complex}) =
    (lu = adjlu.parent; ldiv!(B, adjoint(lu), copy(B)))

ldiv!(X::StridedVecOrMat{T}, lu::GBUmfpackLU{T}, B::StridedVecOrMat{T}) where {T<:UMFVTypes} =
    _Aq_ldiv_B!(X, lu, B, UMFPACK_A)
ldiv!(X::StridedVecOrMat{T}, translu::Transpose{T,<:GBUmfpackLU{T}}, B::StridedVecOrMat{T}) where {T<:UMFVTypes} =
    (lu = translu.parent; _Aq_ldiv_B!(X, lu, B, UMFPACK_Aat))
ldiv!(X::StridedVecOrMat{T}, adjlu::Adjoint{T,<:GBUmfpackLU{T}}, B::StridedVecOrMat{T}) where {T<:UMFVTypes} =
    (lu = adjlu.parent; _Aq_ldiv_B!(X, lu, B, UMFPACK_At))
ldiv!(X::StridedVecOrMat{Tb}, lu::GBUmfpackLU{Float64}, B::StridedVecOrMat{Tb}) where {Tb<:Complex} =
    _Aq_ldiv_B!(X, lu, B, UMFPACK_A)
ldiv!(X::StridedVecOrMat{Tb}, translu::Transpose{Float64,<:GBUmfpackLU{Float64}}, B::StridedVecOrMat{Tb}) where {Tb<:Complex} =
    (lu = translu.parent; _Aq_ldiv_B!(X, lu, B, UMFPACK_Aat))
ldiv!(X::StridedVecOrMat{Tb}, adjlu::Adjoint{Float64,<:GBUmfpackLU{Float64}}, B::StridedVecOrMat{Tb}) where {Tb<:Complex} =
    (lu = adjlu.parent; _Aq_ldiv_B!(X, lu, B, UMFPACK_At))

function _Aq_ldiv_B!(X::StridedVecOrMat, lu::GBUmfpackLU, B::StridedVecOrMat, transposeoptype)
    if size(X, 2) != size(B, 2)
        throw(DimensionMismatch("input and output arrays must have same number of columns"))
    end
    _AqldivB_kernel!(X, lu, B, transposeoptype)
    return X
end
function _AqldivB_kernel!(x::StridedVector{T}, lu::GBUmfpackLU{T},
                          b::StridedVector{T}, transposeoptype) where {T<:UMFVTypes}
    solve!(x, lu, b, transposeoptype)
end
function _AqldivB_kernel!(X::StridedMatrix{T}, lu::GBUmfpackLU{T},
                          B::StridedMatrix{T}, transposeoptype) where {T<:UMFVTypes}
    for col in 1:size(X, 2)
        solve!(view(X, :, col), lu, view(B, :, col), transposeoptype)
    end
end
function _AqldivB_kernel!(x::StridedVector{Tb}, lu::GBUmfpackLU{Float64},
                          b::StridedVector{Tb}, transposeoptype) where Tb<:Complex
    r = similar(b, Float64)
    i = similar(b, Float64)
    c = real.(b)
    solve!(r, lu, c, transposeoptype)
    c .= imag.(b)
    solve!(i, lu, c, transposeoptype)
    map!(complex, x, r, i)
end
function _AqldivB_kernel!(X::StridedMatrix{Tb}, lu::GBUmfpackLU{Float64},
                          B::StridedMatrix{Tb}, transposeoptype) where Tb<:Complex
    r = similar(B, Float64, size(B, 1))
    i = similar(B, Float64, size(B, 1))
    c = similar(B, Float64, size(B, 1))
    for j in 1:size(B, 2)
        c .= real.(view(B, :, j))
        solve!(r, lu, c, transposeoptype)
        c .= imag.(view(B, :, j))
        solve!(i, lu, c, transposeoptype)
        map!(complex, view(X, :, j), r, i)
    end
end

for Tv in (:Float64, :ComplexF64)
    # no lock version for the finalizer
    _free_symbolic = Symbol(umf_name("free_symbolic", Tv))
    @eval function umfpack_free_symbolic(symbolic::Symbolic, ::Type{$Tv}, ::Type{Int64})
        if _isnotnull(symbolic)
            r = Ref(symbolic.p)
            $_free_symbolic(r)
        end
    end
    _free_numeric = Symbol(umf_name("free_numeric", Tv))
    @eval function umfpack_free_numeric(numeric::Numeric, ::Type{$Tv}, ::Type{Int64})
        if _isnotnull(numeric)
            r = Ref(numeric.p)
            $_free_numeric(r)
        end
    end

    _report_symbolic = Symbol(umf_name("report_symbolic", Tv))
    @eval umfpack_report_symbolic(lu::GBUmfpackLU{$Tv}, level::Real=4; q=nothing) =
        @lock lu begin
            umfpack_symbolic!(lu, q)
            old_prl = lu.control[JL_UMFPACK_PRL]
            lu.control[JL_UMFPACK_PRL] = level
            @isok $_report_symbolic(lu.symbolic, lu.control)
            lu.control[JL_UMFPACK_PRL] = old_prl
            lu
        end
    _report_numeric = Symbol(umf_name("report_numeric", Tv))
    @eval umfpack_report_numeric(lu::GBUmfpackLU{$Tv}, level::Real=4; q=nothing) =
        @lock lu begin
            umfpack_numeric!(lu; q)
            old_prl = lu.control[JL_UMFPACK_PRL]
            lu.control[JL_UMFPACK_PRL] = level
            @isok $_report_numeric(lu.numeric, lu.control)
            lu.control[JL_UMFPACK_PRL] = old_prl
            lu
        end
    # the control and info arrays
    _defaults = Symbol(umf_name("defaults", Tv))
    @eval function get_umfpack_control(::Type{$Tv}, ::Type{Int64})
        control = Vector{Float64}(undef, UMFPACK_CONTROL)
        $_defaults(control)
        # Put julia's config here
        # disable iterative refinement by default Issue #122
        control[JL_UMFPACK_IRSTEP] = 0

        return control
    end
end
end # UMFPACK module
