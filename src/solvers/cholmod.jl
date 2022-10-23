module GBCHOLMOD
import Base: (\), getproperty, show, size
using LinearAlgebra
import LinearAlgebra: (\),
                 cholesky, cholesky!, det, diag, ishermitian, isposdef,
                 issuccess, issymmetric, ldlt, ldlt!, logdet
using ..SuiteSparseGraphBLAS: AbstractGBMatrix, AbstractGBVector, unsafepack!, unsafeunpack!, GBMatrix, 
GBVector, AbstractGBArray, LibGraphBLAS, ColMajor, sparsitystatus,
_sizedjlmalloc, increment!, isshallow, nnz, tempunpack!, storedeltype
using SuiteSparseGraphBLAS

using StorageOrders

import ..increment, ..increment!, ..decrement, ..decrement!

using SuiteSparse.LibSuiteSparse
using SuiteSparse.CHOLMOD
using SuiteSparse.CHOLMOD: VTypes, cholesky, cholesky!, ldlt!, Factor, FactorComponent,
    spsolve, CHOLMOD_A, change_stype!

function CHOLMOD.Sparse(A::AbstractGBMatrix{T}, stype::Integer) where T
    colptr, rowval, nzval, repack! = tempunpack!(A, SuiteSparseGraphBLAS.Sparse(); order = ColMajor())
    nzval = !(T <: VTypes) ? promote_type(T, Float64).(nzval) : nzval
    C = try
        CHOLMOD.Sparse(size(A)..., colptr, rowval, nzval, stype)
    catch
        rethrow()
    finally
        repack!()
    end
    if ishermitian(C)
        change_stype!(C, -1)
    end
    return C
end
CHOLMOD.Sparse(A::AbstractGBMatrix) = CHOLMOD.Sparse(A, 0)
CHOLMOD.Sparse(A::Symmetric{Tv, AbstractGBMatrix{Tv}}) where {Tv<:Real} =
    CHOLMOD.Sparse(A.data, A.uplo == 'L' ? -1 : 1)
CHOLMOD.Sparse(A::Hermitian{Tv,AbstractGBMatrix{Tv}}) where {Tv} =
    CHOLMOD.Sparse(A.data, A.uplo == 'L' ? -1 : 1)

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

# TODO: Dense -> GBMatrix

LinearAlgebra.cholesky!(F::Factor, A::Union{AbstractGBMatrix{T},
          AbstractGBMatrix{Complex{T}},
          Symmetric{T,AbstractGBMatrix{T}},
          Hermitian{Complex{T},AbstractGBMatrix{Complex{T}}},
          Hermitian{T,AbstractGBMatrix{T}}};
          shift = 0.0, check::Bool = true) where {T<:Real} =
    CHOLMOD.cholesky!(F, CHOLMOD.Sparse(A); shift = shift, check = check)

LinearAlgebra.cholesky(A::Union{AbstractGBMatrix{T}, AbstractGBMatrix{Complex{T}},
    Symmetric{T,AbstractGBMatrix{T}},
    Hermitian{Complex{T},AbstractGBMatrix{Complex{T}}},
    Hermitian{T,AbstractGBMatrix{T}}};
    kws...) where {T<:Real} = CHOLMOD.cholesky(CHOLMOD.Sparse(A); kws...)

LinearAlgebra.ldlt!(F::Factor, A::Union{AbstractGBMatrix{T},
    AbstractGBMatrix{Complex{T}},
    Symmetric{T,AbstractGBMatrix{T}},
    Hermitian{Complex{T},AbstractGBMatrix{Complex{T}}},
    Hermitian{T,AbstractGBMatrix{T}}};
    shift = 0.0, check::Bool = true) where {T<:Real} =
    CHOLMOD.ldlt!(F, CHOLMOD.Sparse(A), shift = shift, check = check)

LinearAlgebra.ldlt(A::Union{AbstractGBMatrix{T},AbstractGBMatrix{Complex{T}},
    Symmetric{T,AbstractGBMatrix{T}},
    Hermitian{Complex{T},AbstractGBMatrix{Complex{T}}},
    Hermitian{T,AbstractGBMatrix{T}}};
    kws...) where {T<:Real} = CHOLMOD.ldlt(CHOLMOD.Sparse(A); kws...)

function (\)(L::FactorComponent, B::AbstractGBArray)
        sparse(L\CHOLMOD.Sparse(B,0))
end

(\)(L::FactorComponent, B::Adjoint{<:Any,<:AbstractGBMatrix}) = L \ copy(B)
(\)(L::FactorComponent, B::Transpose{<:Any,<:AbstractGBMatrix}) = L \ copy(B)
\(adjL::Adjoint{<:Any,<:FactorComponent}, B::Union{VecOrMat,AbstractGBArray}) = (L = adjL.parent; adjoint(L)\B)
(\)(L::Factor, B::S) where {S<:AbstractGBMatrix} = S(spsolve(CHOLMOD_A, L, CHOLMOD.Sparse(B, 0)))
(\)(L::Factor, B::Adjoint{<:Any,<:AbstractGBMatrix}) = L \ copy(B)
(\)(L::Factor, B::Transpose{<:Any,<:AbstractGBMatrix}) = L \ copy(B)
(\)(L::Factor, B::V) where {V<:AbstractGBVector} = V(spsolve(CHOLMOD_A, L, CHOLMOD.Sparse(B)))
\(adjL::Adjoint{<:Any,<:Factor}, B::AbstractGBArray) = (L = adjL.parent; \(adjoint(L), CHOLMOD.Sparse(B)))

# TODO: 1681 -> 1693
# TODO: Correct Adjoint copy for GBMatrices
# Dense -> GBMatrix
# Sparse -> GBMatrix
end