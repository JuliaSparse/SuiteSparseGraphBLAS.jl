module GBCHOLMOD
import Base: (\), getproperty, show, size
using LinearAlgebra
import LinearAlgebra: (\),
                 cholesky, cholesky!, det, diag, ishermitian, isposdef,
                 issuccess, issymmetric, ldlt, ldlt!, logdet, Symmetric, Hermitian, lu
using ..SuiteSparseGraphBLAS: AbstractGBMatrix, AbstractGBVector, unsafepack!, unsafeunpack!, GBMatrix, 
GBVector, AbstractGBArray, LibGraphBLAS, ColMajor, sparsitystatus,
_sizedjlmalloc, increment!, isshallow, nnz, tempunpack!, storedeltype
using SuiteSparseGraphBLAS
using SuiteSparseGraphBLAS: GBMatrixC, GBMatrixR, defaultfill

using StorageOrders

import ..increment, ..increment!, ..decrement, ..decrement!

using SuiteSparse.LibSuiteSparse
using SuiteSparse.CHOLMOD
using SuiteSparse.CHOLMOD: VTypes, cholesky, cholesky!, ldlt!, Factor, FactorComponent,
    spsolve, CHOLMOD_A, change_stype!

function CHOLMOD.Sparse(A::AbstractGBMatrix{T}, stype::Integer) where T
    colptr, rowval, nzval, repack! = tempunpack!(A, SuiteSparseGraphBLAS.Sparse(); order = ColMajor())
    nzval = !(T <: VTypes) ? promote_type(T, Float64).(nzval) : nzval
    copied = !(T <: VTypes)
    C = try
        if T <: Complex && stype != 0
            nzval = copied ? copy(nzval) : nzval
            for j ∈ 1:size(A, 2)
                for ip ∈ (colptr[j]:(colptr[j+1] - 1)) .+ 1
                    v = nzval[ip]
                    nzval[ip] = rowval[ip] == (j - 1) ? Complex(real(v)) : v
                end
            end
        end
        CHOLMOD.Sparse(size(A)..., colptr, rowval, nzval, stype)
    catch
        rethrow()
    finally
        repack!()
    end
    CHOLMOD.check_sparse(C)
    return C
end
function CHOLMOD.Sparse(A::AbstractGBMatrix)
    C = CHOLMOD.Sparse(A, 0)
    if ishermitian(C)
        change_stype!(C, -1)
    end
    return C
end
CHOLMOD.Sparse(A::Symmetric{Tv, <:AbstractGBMatrix{Tv}}) where {Tv<:Real} =
    CHOLMOD.Sparse(A.data, A.uplo == 'L' ? -1 : 1)
CHOLMOD.Sparse(A::Hermitian{Tv,<:AbstractGBMatrix{Tv}}) where {Tv} =
    CHOLMOD.Sparse(A.data, A.uplo == 'L' ? -1 : 1)
CHOLMOD.Sparse(v::AbstractGBVector) = CHOLMOD.Sparse(GBMatrix(v))

function CHOLMOD.Dense(A::AbstractGBMatrix)
    x, repack! = tempunpack!(A, SuiteSparseGraphBLAS.Dense(); order = ColMajor())
    return try
        CHOLMOD.Dense(x)
    catch
        rethrow()
    finally
        repack!()
    end
end

function _extract_args(s, ::Type{T}) where {T<:CHOLMOD.VTypes}
    ptr = SuiteSparseGraphBLAS._copytoraw(unsafe_wrap(Array, s.p, (s.ncol + 1,), own = false))
    l = ptr[end] - 1
    return s.nrow, s.ncol, ptr,
        SuiteSparseGraphBLAS._copytoraw(unsafe_wrap(Array, s.i, (l + 1,), own = false)), 
        SuiteSparseGraphBLAS._copytoraw(unsafe_wrap(Array, Ptr{T}(s.x), (l + 1,), own = false))
end

function GBVector{T, F}(D::CHOLMOD.Dense{T}; fill = defaultfill(F)) where {T, F}
    @assert size(D, 2) == 1
    M = SuiteSparseGraphBLAS._sizedjlmalloc(length(D), T)
    copyto!(M, D)
    A = GBVector{T}(size(D, 1); fill)
    SuiteSparseGraphBLAS.unsafepack!(A, D, false; order = ColMajor())
    return A
end
function GBVector{T, F}(S::CHOLMOD.Sparse{T}; fill = defaultfill(F)) where {T, F}
    @assert size(S, 2) == 1
    s = unsafe_load(pointer(S))
    if s.stype != 0
        throw(ArgumentError("matrix has stype != 0. Convert to matrix " *
            "with stype == 0 before converting to GBMatrix"))
    end
    nrow, ncol, ptr, idx, vals = _extract_args(s, T)
    A = GBVector{T}(nrow; fill)
    SuiteSparseGraphBLAS.unsafepack!(
        A, ptr, idx, vals, false; 
        order = ColMajor(), jumbled = s.sorted == 0)
    return A
end

GBVector{T}(D::Union{CHOLMOD.Sparse{T}, CHOLMOD.Dense{T}}; fill::F = defaultfill(T)) where {T, F} = 
    GBVector{T, F}(D; fill)
GBVector(D::Union{CHOLMOD.Sparse{T}, CHOLMOD.Dense{T}}; fill::F = defaultfill(T)) where {T, F} = 
    GBVector{T, F}(D; fill)

for Mat ∈ [:GBMatrix, :GBMatrixC, :GBMatrixR]
    @eval begin
        function $Mat{T, F}(D::CHOLMOD.Dense{T}; fill = defaultfill(F)) where {T, F}
            M = SuiteSparseGraphBLAS._sizedjlmalloc(length(D), T)
            copyto!(M, D)
            A = $Mat{T}(size(D); fill)
            SuiteSparseGraphBLAS.unsafepack!(A, D, false; order = ColMajor())
            return A
        end
        function $Mat{T, F}(S::CHOLMOD.Sparse{T}; fill = defaultfill(F)) where {T, F}
            s = unsafe_load(pointer(S))
            if s.stype != 0
                throw(ArgumentError("matrix has stype != 0. Convert to matrix " *
                    "with stype == 0 before converting to GBMatrix"))
            end
            nrow, ncol, ptr, idx, vals = _extract_args(s, T)
            A = $Mat{T}(nrow, ncol; fill)
            SuiteSparseGraphBLAS.unsafepack!(
                A, ptr, idx, vals, false; 
                order = ColMajor(), jumbled = s.sorted == 0)
            return A
        end

        $Mat{T}(D::Union{CHOLMOD.Sparse{T}, CHOLMOD.Dense{T}}; fill::F = defaultfill(T)) where {T, F} = 
            $Mat{T, F}(D; fill)
        $Mat(D::Union{CHOLMOD.Sparse{T}, CHOLMOD.Dense{T}}; fill::F = defaultfill(T)) where {T, F} = 
            $Mat{T, F}(D; fill)

        function LinearAlgebra.Symmetric{Float64,<:$Mat{Float64}}(S::Sparse{Float64})
            s = unsafe_load(pointer(S))
            issymmetric(A) || throw(ArgumentError("matrix is not symmetric"))
            A = $Mat(S)
            Symmetric(A, s.stype > 0 ? :U : :L)
        end
        convert(T::Type{Symmetric{Float64,<:$Mat{Float64}}}, A::Sparse{Float64}) = T(A)
        
        function LinearAlgebra.Hermitian{Tv,<:$Mat{Tv}}(A::Sparse{Tv}) where Tv<:VTypes
            s = unsafe_load(pointer(A))
            ishermitian(A) || throw(ArgumentError("matrix is not Hermitian"))
            A = $Mat(S)
            Hermitian(A, s.stype > 0 ? :U : :L)
        end
        convert(T::Type{Hermitian{Tv,<:$Mat{Tv}}}, A::Sparse{Tv}) where {Tv<:VTypes} = T(A)

        function $Mat(FC::CHOLMOD.FactorComponent{Tv, :L}) where Tv
            F = Factor(FC)
            s = unsafe_load(pointer(F))
            if s.is_ll == 0
                throw(CHOLMODException("sparse: supported only for :LD on LDLt factorizations"))
            end
            return $Mat(Sparse(F))
        end
        $Mat(FC::FactorComponent{Tv,:LD}) where {Tv} = $Mat(Sparse(Factor(FC)))
        function $Mat(F::Factor)
            s = unsafe_load(pointer(F))
            if s.is_ll != 0
                L = Sparse(F)
                A = $Mat(L*L')
            else
                LD = $Mat(F.LD)
                L, d = CHOLMOD.getLd!(LD)
                A = (L * Diagonal(d)) * L'
            end
            # no need to sort buffers here, as A isa SparseMatrixCSC
            # and it is taken care in sparse
            p = CHOLMOD.get_perm(F)
            if p != [1:s.n;]
                pinv = Vector{Int}(undef, length(p))
                for k = 1:length(p)
                    pinv[p[k]] = k
                end
                A = A[pinv,pinv]
            end
            A
        end
    end
end

function CHOLMOD.getLd!(S::AbstractGBMatrix)
    nz = nnz(S)
    colptr, rowvals, nonzeros, repack! = tempunpack!(
        S, SuiteSparseGraphBLAS.Sparse(); 
        order = ColMajor()
    )
    d = Vector{eltype(S)}(undef, size(S, 1))
    fill!(d, 0)
    col = 1
    for k = 1:nz
        while k >= (colptr[col+1] + 1)
            col += 1
        end
        if (rowvals[k] + 1) == col
            d[col] = nonzeros[k]
            nonzeros[k] = 1
        end
    end
    repack!()
    S, d
end

LinearAlgebra.cholesky!(F::Factor, A::Union{AbstractGBMatrix{T},
          AbstractGBMatrix{Complex{T}},
          Symmetric{T,AbstractGBMatrix{T}},
          Hermitian{Complex{T},AbstractGBMatrix{Complex{T}}},
          Hermitian{T,AbstractGBMatrix{T}}};
          shift = 0.0, check::Bool = true) where {T<:Real} =
    CHOLMOD.cholesky!(F, CHOLMOD.Sparse(A); shift = shift, check = check)

LinearAlgebra.cholesky(A::Union{<:AbstractGBMatrix{T}, <:AbstractGBMatrix{Complex{T}},
    Symmetric{T,<:AbstractGBMatrix{T}},
    Hermitian{Complex{T},<:AbstractGBMatrix{Complex{T}}},
    Hermitian{T,<:AbstractGBMatrix{T}}};
    kws...) where {T<:Real} = CHOLMOD.cholesky(CHOLMOD.Sparse(A); kws...)

LinearAlgebra.ldlt!(F::Factor, A::Union{<:AbstractGBMatrix{T},
    <:AbstractGBMatrix{Complex{T}},
    Symmetric{T,<:AbstractGBMatrix{T}},
    Hermitian{Complex{T},<:AbstractGBMatrix{Complex{T}}},
    Hermitian{T,<:AbstractGBMatrix{T}}};
    shift = 0.0, check::Bool = true) where {T<:Real} =
    CHOLMOD.ldlt!(F, CHOLMOD.Sparse(A), shift = shift, check = check)

LinearAlgebra.ldlt(A::Union{<:AbstractGBMatrix{T},<:AbstractGBMatrix{Complex{T}},
    Symmetric{T,<:AbstractGBMatrix{T}},
    Hermitian{Complex{T},<:AbstractGBMatrix{Complex{T}}},
    Hermitian{T,<:AbstractGBMatrix{T}}};
    kws...) where {T<:Real} = CHOLMOD.ldlt(CHOLMOD.Sparse(A); kws...)

function (\)(L::FactorComponent, B::G) where {G<:AbstractGBArray}
        SuiteSparseGraphBLAS.strip_parameters(G)(L\CHOLMOD.Sparse(B,0))
end

(\)(L::FactorComponent, B::Adjoint{<:Any,<:AbstractGBMatrix}) = L \ copy(B)
(\)(L::FactorComponent, B::Transpose{<:Any,<:AbstractGBMatrix}) = L \ copy(B)
\(adjL::Adjoint{<:Any,<:FactorComponent}, B::Union{VecOrMat,AbstractGBArray}) = (L = adjL.parent; adjoint(L)\B)
(\)(L::Factor, B::S) where {S<:AbstractGBMatrix} = S(spsolve(CHOLMOD_A, L, CHOLMOD.Sparse(B, 0)))
(\)(L::Factor, B::Adjoint{<:Any,<:AbstractGBMatrix}) = L \ copy(B)
(\)(L::Factor, B::Transpose{<:Any,<:AbstractGBMatrix}) = L \ copy(B)
(\)(L::Factor, B::V) where {V<:AbstractGBVector} = V(spsolve(CHOLMOD_A, L, CHOLMOD.Sparse(B)))
\(adjL::Adjoint{<:Any,<:Factor}, B::AbstractGBArray) = (L = adjL.parent; \(adjoint(L), CHOLMOD.Sparse(B)))

const GBRealHermSymComplexHermF64SSL = Union{
    Symmetric{Float64,<:AbstractGBArray{Float64}},
    Hermitian{Float64,<:AbstractGBArray{Float64}},
    Hermitian{ComplexF64,<:AbstractGBArray{ComplexF64}}}
function \(A::GBRealHermSymComplexHermF64SSL, B::CHOLMOD.StridedVecOrMatInclAdjAndTrans)
    F = cholesky(A; check = false)
    if issuccess(F)
        return \(F, B)
    else
        ldlt!(F, A; check = false)
        if issuccess(F)
            return \(F, B)
        else
            return \(lu(A), B)
        end
    end
end
function LinearAlgebra.lu(A::GBRealHermSymComplexHermF64SSL)
    return lu(copy(A))
end

# TODO: Improve these, to use better promotion: 
Base.:*(A::Symmetric{Float64,G},
    B::AbstractGBArray) where {G<:AbstractGBMatrix} = GBMatrix(Sparse(A)*Sparse(B))
Base.:*(A::Hermitian{ComplexF64,<:GBMatrix},
    B::AbstractGBArray{ComplexF64}) = GBMatrix(Sparse(A)*Sparse(B))
Base.:*(A::Hermitian{Float64,<:GBMatrix},
    B::AbstractGBArray{Float64}) = GBMatrix(Sparse(A)*Sparse(B))

Base.:*(A::AbstractGBArray{Float64},
    B::Symmetric{Float64,<:AbstractGBMatrix}) = GBMatrix(Sparse(A)*Sparse(B))
Base.:*(A::AbstractGBArray{ComplexF64},
    B::Hermitian{ComplexF64,<:AbstractGBMatrix}) = GBMatrix(Sparse(A)*Sparse(B))
Base.:*(A::AbstractGBArray{Float64},
    B::Hermitian{Float64,<:AbstractGBMatrix}) = GBMatrix(Sparse(A)*Sparse(B))
end