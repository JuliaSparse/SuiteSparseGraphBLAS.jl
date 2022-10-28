# This file is a part of Julia. License is MIT: https://julialang.org/license

module CHOLMODTests

using Test
using SuiteSparse.CHOLMOD
using SuiteSparse.CHOLMOD: Sparse
using Random
using Serialization
using LinearAlgebra:
    I, cholesky, cholesky!, det, diag, eigmax, ishermitian, isposdef, issuccess,
    issymmetric, ldlt, ldlt!, logdet, norm, opnorm, Diagonal, Hermitian, Symmetric,
    PosDefException, ZeroPivotException
using SparseArrays
using SparseArrays: getcolptr
using SuiteSparse.LibSuiteSparse: SuiteSparse_long
using SuiteSparseGraphBLAS
using SuiteSparse.LibSuiteSparse
if Base.USE_GPL_LIBS

# CHOLMOD tests
Random.seed!(123)

@testset "Issue 9160" begin
    local A, B
    A = gbrand(Float64, 10, 10, 0.1)
    cmA = CHOLMOD.Sparse(A)

    B = gbrand(Float64, 10, 10, 0.1)
    cmB = CHOLMOD.Sparse(B)

    # Ac_mul_B
    @test GBMatrix(cmA'*cmB) ≈ A'*B

    # A_mul_Bc
    @test GBMatrix(cmA*cmB') ≈ A*B'

    # A_mul_Ac
    @test GBMatrix(cmA*cmA') ≈ A*A'

    # Ac_mul_A
    @test GBMatrix(cmA'*cmA) ≈ A'*A

    # A_mul_Ac for symmetric A
    A = 0.5*(A + copy(A'))
    cmA = CHOLMOD.Sparse(A)
    @test GBMatrix(cmA*cmA') ≈ A*A'
end

@testset "Issue #9915" begin
    sparseI = GBMatrix(1.0I, 2)
    @test sparseI \ sparseI == sparseI
end

@testset "test Sparse constructor Symmetric and Hermitian input (and issymmetric and ishermitian)" begin
    ACSC = gbrandn(Float64, 10, 10, 0.3) + I
    @test issymmetric(Sparse(Symmetric(ACSC, :L)))
    @test issymmetric(Sparse(Symmetric(ACSC, :U)))
    @test ishermitian(Sparse(Hermitian(complex(ACSC), :L)))
    @test ishermitian(Sparse(Hermitian(complex(ACSC), :U)))
end

# Test Dense wrappers (only Float64 supported a present)

@testset "High level interface" for elty in (Float64, ComplexF64)
    local A, b
    if elty == Float64
        A = gbrandn(Float64, 5, 5, 1.0)
        b = randn(Float64, 5)
    else
        A = gbrandn(ComplexF64, 5, 5, 1.0)
        b = randn(ComplexF64, 5)
    end
    ADense = CHOLMOD.Dense(A)
    bDense = CHOLMOD.Dense(b)

    @test_throws BoundsError ADense[6, 1]
    @test_throws BoundsError ADense[1, 6]
    @test copy(ADense) == ADense
    @test CHOLMOD.norm_dense(ADense, 1) ≈ opnorm(A, 1)
    @test CHOLMOD.norm_dense(ADense, 0) ≈ opnorm(A, Inf)
    @test_throws ArgumentError CHOLMOD.norm_dense(ADense, 2)
    @test_throws ArgumentError CHOLMOD.norm_dense(ADense, 3)

    @test CHOLMOD.norm_dense(bDense, 2) ≈ norm(b)
    @test CHOLMOD.check_dense(bDense)

    AA = CHOLMOD.eye(3)
    unsafe_store!(convert(Ptr{Csize_t}, pointer(AA)), 2, 1) # change size, but not stride, of Dense
    @test convert(Matrix, AA) == Matrix(I, 2, 3)
end


@testset "Core functionality" for elty in (Float64, ComplexF64)
    A1 = GBMatrix([1:5; 1], [1:5; 2], elty == Float64 ? randn(6) : randn(ComplexF64, 6))
    A2 = GBMatrixC([1:5; 1], [1:5; 2], elty == Float64 ? randn(6) : randn(ComplexF64, 6))
    A1pd = A1'A1
    A1Sparse = CHOLMOD.Sparse(A1)
    A2Sparse = CHOLMOD.Sparse(A2)
    A1pdSparse = CHOLMOD.Sparse(A1pd)

    ## High level interface
    @test isa(CHOLMOD.Sparse(3, 3, [0,1,3,4], [0,2,1,2], fill(1., 4)), CHOLMOD.Sparse) # Sparse doesn't require columns to be sorted
    @test_throws BoundsError A1Sparse[6, 1]
    @test_throws BoundsError A1Sparse[1, 6]
    @test sparse(A1Sparse) == A1
    for i = 1:size(A1, 1)
        A1[i, i] = real(A1[i, i])
    end #Construct Hermitian matrix properly
    @test CHOLMOD.sparse(CHOLMOD.Sparse(Hermitian(A1, :L))) == Hermitian(A1, :L)
    @test CHOLMOD.sparse(CHOLMOD.Sparse(Hermitian(A1, :U))) == Hermitian(A1, :U)    
    @test copy(A1Sparse) == A1Sparse
    @test size(A1Sparse, 3) == 1
    if elty <: Real # multiplication only defined for real matrices in CHOLMOD
        @test A1Sparse*A2Sparse ≈ A1*A2
        @test_throws DimensionMismatch CHOLMOD.Sparse(A1[:,1:4])*A2Sparse
        @test A1Sparse'A2Sparse ≈ A1'A2
        @test A1Sparse*A2Sparse' ≈ A1*A2'

        @test A1Sparse*A1Sparse ≈ A1*A1
        @test A1Sparse'A1Sparse ≈ A1'A1
        @test A1Sparse*A1Sparse' ≈ A1*A1'

        @test A1pdSparse*A1pdSparse ≈ A1pd*A1pd
        @test A1pdSparse'A1pdSparse ≈ A1pd'A1pd
        @test A1pdSparse*A1pdSparse' ≈ A1pd*A1pd'

        @test_throws DimensionMismatch A1Sparse*CHOLMOD.eye(4, 5, elty)
    end

    # Factor
    @test_throws ArgumentError cholesky(A1)
    @test_throws ArgumentError cholesky(A1)
    @test_throws ArgumentError cholesky(A1, shift=1.0)
    @test_throws ArgumentError ldlt(A1)
    @test_throws ArgumentError ldlt(A1, shift=1.0)
    C = A1 + copy(adjoint(A1))
    λmaxC = eigmax(Array(C))
    b = fill(1., size(A1, 1))
    @test_throws PosDefException cholesky(C - 2λmaxC*I)
    @test_throws PosDefException cholesky(C, shift=-2λmaxC)
    @test_throws ZeroPivotException ldlt(C - C[1,1]*I)
    @test_throws ZeroPivotException ldlt(C, shift=-real(C[1,1]))
    @test !isposdef(cholesky(C - 2λmaxC*I; check = false))
    @test !isposdef(cholesky(C, shift=-2λmaxC; check = false))
    @test !issuccess(ldlt(C - C[1,1]*I; check = false))
    @test !issuccess(ldlt(C, shift=-real(C[1,1]); check = false))
    F = cholesky(A1pd)
    tmp = IOBuffer()
    show(tmp, F)
    @test tmp.size > 0
    @test isa(CHOLMOD.Sparse(F), CHOLMOD.Sparse{elty})
    @test_throws DimensionMismatch F\CHOLMOD.Dense(fill(elty(1), 4))
    @test_throws DimensionMismatch F\CHOLMOD.Sparse(sparse(fill(elty(1), 4)))
    b = fill(1., 5)
    bT = fill(elty(1), 5)
    @test F'\bT ≈ Array(A1pd)'\b
    @test F'\sparse(bT) ≈ Array(A1pd)'\b
    @test transpose(F)\bT ≈ conj(A1pd)'\bT
    @test F\CHOLMOD.Sparse(sparse(bT)) ≈ A1pd\b
    @test logdet(F) ≈ logdet(Array(A1pd))
    @test det(F) == exp(logdet(F))
    let # to test supernodal, we must use a larger matrix
        Ftmp = sprandn(100, 100, 0.1)
        Ftmp = Ftmp'Ftmp + I
        @test logdet(cholesky(Ftmp)) ≈ logdet(Array(Ftmp))
    end
    @test logdet(ldlt(A1pd)) ≈ logdet(Array(A1pd))
    @test isposdef(A1pd)
    @test !isposdef(A1)
    @test !isposdef(A1 + copy(A1') |> t -> t - 2eigmax(Array(t))*I)

    if elty <: Real
        @test CHOLMOD.issymmetric(Sparse(A1pd, 0))
        @test CHOLMOD.Sparse(cholesky(Symmetric(A1pd, :L))) == CHOLMOD.Sparse(cholesky(A1pd))
        F1 = CHOLMOD.Sparse(cholesky(Symmetric(A1pd, :L), shift=2))
        F2 = CHOLMOD.Sparse(cholesky(A1pd, shift=2))
        @test F1 == F2
        @test CHOLMOD.Sparse(ldlt(Symmetric(A1pd, :L))) == CHOLMOD.Sparse(ldlt(A1pd))
        F1 = CHOLMOD.Sparse(ldlt(Symmetric(A1pd, :L), shift=2))
        F2 = CHOLMOD.Sparse(ldlt(A1pd, shift=2))
        @test F1 == F2
    else
        @test !CHOLMOD.issymmetric(Sparse(A1pd, 0))
        @test CHOLMOD.ishermitian(Sparse(A1pd, 0))
        @test CHOLMOD.Sparse(cholesky(Hermitian(A1pd, :L))) == CHOLMOD.Sparse(cholesky(A1pd))
        F1 = CHOLMOD.Sparse(cholesky(Hermitian(A1pd, :L), shift=2))
        F2 = CHOLMOD.Sparse(cholesky(A1pd, shift=2))
        @test F1 == F2
        @test CHOLMOD.Sparse(ldlt(Hermitian(A1pd, :L))) == CHOLMOD.Sparse(ldlt(A1pd))
        F1 = CHOLMOD.Sparse(ldlt(Hermitian(A1pd, :L), shift=2))
        F2 = CHOLMOD.Sparse(ldlt(A1pd, shift=2))
        @test F1 == F2
    end

    ### cholesky!/ldlt!
    F = cholesky(A1pd)
    CHOLMOD.change_factor!(F, false, false, true, true)
    @test unsafe_load(pointer(F)).is_ll == 0
    CHOLMOD.change_factor!(F, true, false, true, true)
    @test CHOLMOD.Sparse(cholesky!(copy(F), A1pd)) ≈ CHOLMOD.Sparse(F) # surprisingly, this can cause small ulp size changes so we cannot test exact equality
    @test size(F, 2) == 5
    @test size(F, 3) == 1
    @test_throws ArgumentError size(F, 0)

    F = cholesky(A1pdSparse, shift=2)
    @test isa(CHOLMOD.Sparse(F), CHOLMOD.Sparse{elty})
    @test CHOLMOD.Sparse(cholesky!(copy(F), A1pd, shift=2.0)) ≈ CHOLMOD.Sparse(F) # surprisingly, this can cause small ulp size changes so we cannot test exact equality

    F = ldlt(A1pd)
    @test isa(CHOLMOD.Sparse(F), CHOLMOD.Sparse{elty})
    @test CHOLMOD.Sparse(ldlt!(copy(F), A1pd)) ≈ CHOLMOD.Sparse(F) # surprisingly, this can cause small ulp size changes so we cannot test exact equality

    F = ldlt(A1pdSparse, shift=2)
    @test isa(CHOLMOD.Sparse(F), CHOLMOD.Sparse{elty})
    @test CHOLMOD.Sparse(ldlt!(copy(F), A1pd, shift=2.0)) ≈ CHOLMOD.Sparse(F) # surprisingly, this can cause small ulp size changes so we cannot test exact equality

    @test isa(CHOLMOD.factor_to_sparse!(F), CHOLMOD.Sparse)
    @test_throws CHOLMOD.CHOLMODException CHOLMOD.factor_to_sparse!(F)

    ## Low level interface
    @test CHOLMOD.nnz(A1Sparse) == nnz(A1)
    @test CHOLMOD.speye(5, 5, elty) == Matrix(I, 5, 5)
    @test CHOLMOD.spzeros(5, 5, 5, elty) == zeros(elty, 5, 5)
    if elty <: Real
        @test CHOLMOD.copy(A1Sparse, 0, 1) == A1Sparse
        @test CHOLMOD.horzcat(A1Sparse, A2Sparse, true) == [A1 A2]
        @test CHOLMOD.vertcat(A1Sparse, A2Sparse, true) == [A1; A2]
        svec = fill(elty(1), 1)
        @test CHOLMOD.scale!(CHOLMOD.Dense(svec), CHOLMOD_SCALAR, A1Sparse) == A1Sparse
        svec = fill(elty(1), 5)
        @test_throws DimensionMismatch CHOLMOD.scale!(CHOLMOD.Dense(svec), CHOLMOD_SCALAR, A1Sparse)
        @test CHOLMOD.scale!(CHOLMOD.Dense(svec), CHOLMOD_ROW, A1Sparse) == A1Sparse
        @test_throws DimensionMismatch CHOLMOD.scale!(CHOLMOD.Dense([svec; 1]), CHOLMOD_ROW, A1Sparse)
        @test CHOLMOD.scale!(CHOLMOD.Dense(svec), CHOLMOD_COL, A1Sparse) == A1Sparse
        @test_throws DimensionMismatch CHOLMOD.scale!(CHOLMOD.Dense([svec; 1]), CHOLMOD_COL, A1Sparse)
        @test CHOLMOD.scale!(CHOLMOD.Dense(svec), CHOLMOD_SYM, A1Sparse) == A1Sparse
        @test_throws DimensionMismatch CHOLMOD.scale!(CHOLMOD.Dense([svec; 1]), CHOLMOD_SYM, A1Sparse)
        @test_throws DimensionMismatch CHOLMOD.scale!(CHOLMOD.Dense(svec), CHOLMOD_SYM, CHOLMOD.Sparse(A1[:,1:4]))
    else
        @test_throws MethodError CHOLMOD.copy(A1Sparse, 0, 1) == A1Sparse
        @test_throws MethodError CHOLMOD.horzcat(A1Sparse, A2Sparse, true) == [A1 A2]
        @test_throws MethodError CHOLMOD.vertcat(A1Sparse, A2Sparse, true) == [A1; A2]
    end

    if elty <: Real
        @test CHOLMOD.ssmult(A1Sparse, A2Sparse, 0, true, true) ≈ A1*A2
        @test CHOLMOD.aat(A1Sparse, [0:size(A1,2)-1;], 1) ≈ A1*A1'
        @test CHOLMOD.aat(A1Sparse, [0:1;], 1) ≈ A1[:,1:2]*A1[:,1:2]'
        @test CHOLMOD.copy(A1Sparse, 0, 1) == A1Sparse
    end

    @test CHOLMOD.Sparse(CHOLMOD.Dense(A1Sparse)) == A1Sparse
end

@testset "extract factors" begin
    Af = float([4 12 -16; 12 37 -43; -16 -43 98])
    As = GBMatrix(Af)
    Lf = float([2 0 0; 6 1 0; -8 5 3])
    LDf = float([4 0 0; 3 1 0; -4 5 9])  # D is stored along the diagonal
    L_f = float([1 0 0; 3 1 0; -4 5 1])  # L by itself in LDLt of Af
    D_f = float([4 0 0; 0 1 0; 0 0 9])
    p = [2,3,1]
    p_inv = [3,1,2]

    @testset "cholesky, no permutation" begin
        Fs = cholesky(As, perm=[1:3;])
        @test Fs.p == [1:3;]
        @test sparse(Fs.L) ≈ Lf
        @test sparse(Fs) ≈ As
        b = rand(3)
        @test Fs\b ≈ Af\b
        @test Fs.UP\(Fs.PtL\b) ≈ Af\b
        @test Fs.L\b ≈ Lf\b
        @test Fs.U\b ≈ Lf'\b
        @test Fs.L'\b ≈ Lf'\b
        @test Fs.U'\b ≈ Lf\b
        @test Fs.PtL\b ≈ Lf\b
        @test Fs.UP\b ≈ Lf'\b
        @test Fs.PtL'\b ≈ Lf'\b
        @test Fs.UP'\b ≈ Lf\b
        @test_throws CHOLMOD.CHOLMODException Fs.D
        @test_throws CHOLMOD.CHOLMODException Fs.LD
        @test_throws CHOLMOD.CHOLMODException Fs.DU
        @test_throws CHOLMOD.CHOLMODException Fs.PLD
        @test_throws CHOLMOD.CHOLMODException Fs.DUPt
    end

    @testset "cholesky, with permutation" begin
        Fs = cholesky(As, perm=p)
        @test Fs.p == p
        Afp = Af[p,p]
        Lfp = cholesky(Afp).L
        Ls = sparse(Fs.L)
        @test Ls ≈ Lfp
        @test Ls * Ls' ≈ Afp
        P = sparse(1:3, Fs.p, ones(3))
        @test P' * Ls * Ls' * P ≈ As
        @test sparse(Fs) ≈ As
        b = rand(3)
        @test Fs\b ≈ Af\b
        @test Fs.UP\(Fs.PtL\b) ≈ Af\b
        @test Fs.L\b ≈ Lfp\b
        @test Fs.U'\b ≈ Lfp\b
        @test Fs.U\b ≈ Lfp'\b
        @test Fs.L'\b ≈ Lfp'\b
        @test Fs.PtL\b ≈ Lfp\b[p]
        @test Fs.UP\b ≈ (Lfp'\b)[p_inv]
        @test Fs.PtL'\b ≈ (Lfp'\b)[p_inv]
        @test Fs.UP'\b ≈ Lfp\b[p]
        @test_throws CHOLMOD.CHOLMODException Fs.PL
        @test_throws CHOLMOD.CHOLMODException Fs.UPt
        @test_throws CHOLMOD.CHOLMODException Fs.D
        @test_throws CHOLMOD.CHOLMODException Fs.LD
        @test_throws CHOLMOD.CHOLMODException Fs.DU
        @test_throws CHOLMOD.CHOLMODException Fs.PLD
        @test_throws CHOLMOD.CHOLMODException Fs.DUPt
    end

    @testset "ldlt, no permutation" begin
        Fs = ldlt(As, perm=[1:3;])
        @test Fs.p == [1:3;]
        @test GBMatrix(Fs.LD) ≈ LDf
        @test GBMatrix(Fs) ≈ As
        b = rand(3)
        @test Fs\b ≈ Af\b
        @test Fs.UP\(Fs.PtLD\b) ≈ Af\b
        @test Fs.DUP\(Fs.PtL\b) ≈ Af\b
        @test Fs.L\b ≈ L_f\b
        @test Fs.U\b ≈ L_f'\b
        @test Fs.L'\b ≈ L_f'\b
        @test Fs.U'\b ≈ L_f\b
        @test Fs.PtL\b ≈ L_f\b
        @test Fs.UP\b ≈ L_f'\b
        @test Fs.PtL'\b ≈ L_f'\b
        @test Fs.UP'\b ≈ L_f\b
        @test Fs.D\b ≈ D_f\b
        @test Fs.D'\b ≈ D_f\b
        @test Fs.LD\b ≈ D_f\(L_f\b)
        @test Fs.DU'\b ≈ D_f\(L_f\b)
        @test Fs.LD'\b ≈ L_f'\(D_f\b)
        @test Fs.DU\b ≈ L_f'\(D_f\b)
        @test Fs.PtLD\b ≈ D_f\(L_f\b)
        @test Fs.DUP'\b ≈ D_f\(L_f\b)
        @test Fs.PtLD'\b ≈ L_f'\(D_f\b)
        @test Fs.DUP\b ≈ L_f'\(D_f\b)
    end

    @testset "ldlt, with permutation" begin
        Fs = ldlt(As, perm=p)
        @test Fs.p == p
        @test GBMatrix(Fs) ≈ As
        b = rand(3)
        Asp = As[p,p]
        LDp = sparse(ldlt(Asp, perm=[1,2,3]).LD)
        # LDp = sparse(Fs.LD)
        Lp, dp = CHOLMOD.getLd!(copy(LDp))
        Dp = GBMatrix(Diagonal(dp))
        @test Fs\b ≈ Af\b
        @test Fs.UP\(Fs.PtLD\b) ≈ Af\b
        @test Fs.DUP\(Fs.PtL\b) ≈ Af\b
        @test Fs.L\b ≈ Lp\b
        @test Fs.U\b ≈ Lp'\b
        @test Fs.L'\b ≈ Lp'\b
        @test Fs.U'\b ≈ Lp\b
        @test Fs.PtL\b ≈ Lp\b[p]
        @test Fs.UP\b ≈ (Lp'\b)[p_inv]
        @test Fs.PtL'\b ≈ (Lp'\b)[p_inv]
        @test Fs.UP'\b ≈ Lp\b[p]
        @test Fs.LD\b ≈ Dp\(Lp\b)
        @test Fs.DU'\b ≈ Dp\(Lp\b)
        @test Fs.LD'\b ≈ Lp'\(Dp\b)
        @test Fs.DU\b ≈ Lp'\(Dp\b)
        @test Fs.PtLD\b ≈ Dp\(Lp\b[p])
        @test Fs.DUP'\b ≈ Dp\(Lp\b[p])
        @test Fs.PtLD'\b ≈ (Lp'\(Dp\b))[p_inv]
        @test Fs.DUP\b ≈ (Lp'\(Dp\b))[p_inv]
        @test_throws CHOLMOD.CHOLMODException Fs.DUPt
        @test_throws CHOLMOD.CHOLMODException Fs.PLD
    end

    @testset "Element promotion and type inference" begin
        @inferred cholesky(As)\fill(1, size(As, 1))
        @inferred ldlt(As)\fill(1, size(As, 1))
    end
end

@testset "Issue 11745 - row and column pointers were not sorted in sparse(Factor)" begin
    A = Float64[10 1 1 1; 1 10 0 0; 1 0 10 0; 1 0 0 10]
    @test GBMatrix(cholesky(GBMatrix(A))) ≈ A
end
GC.gc()

@testset "Issue 11747 - Wrong show method defined for FactorComponent" begin
    v = cholesky(GBMatrix(Float64[ 10 1 1 1; 1 10 0 0; 1 0 10 0; 1 0 0 10])).L
    for s in (sprint(show, MIME("text/plain"), v), sprint(show, v))
        @test occursin("method:  simplicial", s)
        @test !occursin("#undef", s)
    end
end

@testset "Issue 14076" begin
    @test cholesky(GBMatrix([1,2,3,4], [1,2,3,4], Float32[1,4,16,64]))\[1,4,16,64] == fill(1, 4)
end

@testset "Issue #28985" begin
    @test typeof(cholesky(GBMatrix(I, 4, 4))'\rand(4)) == Array{Float64, 1}
    @test typeof(cholesky(GBMatrix(I, 4, 4))'\rand(4,1)) == Array{Float64, 2}
end

@testset "Further issue with promotion #14894" begin
    x = fill(1., 5)
    @test cholesky(GBMatrix(Float16(1)I, 5, 5))\x == x
    @test cholesky(Symmetric(GBMatrix(Float16(1)I, 5, 5)))\x == x
    @test cholesky(Hermitian(GBMatrix(Complex{Float16}(1)I, 5, 5)))\x == x
end

@testset "test \\ for Factor and StridedVecOrMat" begin
    x = rand(5)
    A = cholesky(GBMatrix(Diagonal(x.\1)))
    @test A\view(fill(1.,10),1:2:10) ≈ x
    @test A\view(Matrix(1.0I, 5, 5), :, :) ≈ Matrix(Diagonal(x))
end

@testset "Test \\ for Factor and SparseVecOrMat" begin
    sparseI = GBMatrix(1.0I, 100, 100)
    sparseb = GBVector(sprandn(100, 0.5))
    sparseB = gbrandn(Float64, 100, 100, 0.5)
    chI = cholesky(sparseI)
    @test chI \ sparseb ≈ sparseb
    @test chI \ sparseB ≈ sparseB
    @test chI \ sparseI ≈ sparseI
end

@testset "Real factorization and complex rhs" begin
    A = gbrandn(Float64, 5, 5, 0.4) |> t -> t't + I
    B = complex.(randn(5, 2), randn(5, 2))
    @test cholesky(A)\B ≈ A\B
end

# TODO: BLOCK MATRIX CONCAT:

# @testset "Make sure that ldlt performs an LDLt (Issue #19032)" begin
#     m, n = 400, 500
#     A = gbrandn(Float64, m, n, .2)
#     M = [GBMatrix(I(n)) copy(A'); A GBMatrix(-I(n))] # TODO. Can we do this?!
#     b = M * fill(1., m+n)
#     F = ldlt(M)
#     s = unsafe_load(pointer(F))
#     @test s.is_super == 0
#     @test F\b ≈ fill(1., m+n)
#     F2 = cholesky(M; check = false)
#     @test !issuccess(F2)
#     ldlt!(F2, M)
#     @test issuccess(F2)
#     @test F2\b ≈ fill(1., m+n)
# end

# TODO: BETTER WRAPPER SUPPORT

# @testset "Test that imaginary parts in Hermitian{T,SparseMatrixCSC{T}} are ignored" begin
#     A = GBMatrix([1,2,3,4,1], [1,2,3,4,2], [complex(2.0,1),2,2,2,1])
#     Fs = cholesky(Hermitian(A))
#     Fd = cholesky(Hermitian(Array(A)))
#     @test GBMatrix(Fs) ≈ Hermitian(A)
#     @test Fs\fill(1., 4) ≈ Fd\fill(1., 4)
# end

# @testset "\\ '\\ and transpose(...)\\" begin
#     # Test that \ and '\ and transpose(...)\ work for Symmetric and Hermitian. This is just
#     # a dispatch exercise so it doesn't matter that the complex matrix has
#     # zero imaginary parts
#     Apre = gbrandn(Float64, 10, 10, 0.2) - I
#     for A in (Symmetric(Apre), Hermitian(Apre),
#               Symmetric(Apre + 10I), Hermitian(Apre + 10I),
#               Hermitian(complex(Apre)), Hermitian(complex(Apre) + 10I))
#         local A, x, b
#         x = fill(1., 10)
#         b = A*x
#         @test x ≈ A\b
#         @test transpose(A)\b ≈ A'\b
#     end
# end

# @testset "Check that Symmetric{SparseMatrixCSC} can be constructed from CHOLMOD.Sparse" begin
#     Int === Int32 && Random.seed!(124)
#     A = gbrandn(10, 10, 0.1)
#     B = CHOLMOD.Sparse(A)
#     C = B'B
#     # Change internal representation to symmetric (upper/lower)
#     o = fieldoffset(cholmod_sparse, findall(fieldnames(cholmod_sparse) .== :stype)[1])
#     for uplo in (1, -1)
#         unsafe_store!(Ptr{Int8}(pointer(C)), uplo, Int(o) + 1)
#         @test convert(Symmetric{Float64,SparseMatrixCSC{Float64,Int}}, C) ≈ Symmetric(A'A)
#     end
# end

# ??
# @testset "Check inputs to Sparse. Related to #20024" for t_ in (
#     ([1, 2], SuiteSparse_long[], Float64[], 2, 2),
#     ([1, 2, 3], SuiteSparse_long[1], Float64[], 2, 2),
#     ([1, 2, 3], SuiteSparse_long[], Float64[1.0], 2, 2),
#     ([1, 2, 3], SuiteSparse_long[1], Float64[1.0], 2, 2))
#     @test_throws ArgumentError GBMatrix(t_...)
#     @test_throws ArgumentError CHOLMOD.Sparse(t_[1], t_[2], t_[3] .- 1, t_[4] .- 1, t_[5])
# end

# @testset "sparse right multiplication of Symmetric and Hermitian matrices #21431" begin
#     S = sparse(1.0I, 2, 2)
#     @test issparse(S*S*S)
#     for T in (Symmetric, Hermitian)
#         @test issparse(S*T(S)*S)
#         @test issparse(S*(T(S)*S))
#         @test issparse((S*T(S))*S)
#     end
# end
# 
# @testset "Test sparse low rank update for cholesky decomposion" begin
#     A = SparseMatrixCSC{Float64,SuiteSparse_long}(10, 5, [1,3,6,8,10,13], [6,7,1,2,9,3,5,1,7,6,7,9],
#         [-0.138843, 2.99571, -0.556814, 0.669704, -1.39252, 1.33814,
#         1.02371, -0.502384, 1.10686, 0.262229, -1.6935, 0.525239])
#     AtA = A'*A
#     C0 = [1., 2., 0, 0, 0]
#     # Test both cholesky and LDLt with and without automatic permutations
#     for F in (cholesky(AtA), cholesky(AtA, perm=1:5), ldlt(AtA), ldlt(AtA, perm=1:5))
#         local F
#         x0 = F\(b = fill(1., 5))
#         #Test both sparse/dense and vectors/matrices
#         for Ctest in (C0, sparse(C0), [C0 2*C0], sparse([C0 2*C0]))
#             local x, C, F1
#             C = copy(Ctest)
#             F1 = copy(F)
#             x = (AtA+C*C')\b
# 
#             #Test update
#             F11 = CHOLMOD.lowrankupdate(F1, C)
#             @test Array(sparse(F11)) ≈ AtA+C*C'
#             @test F11\b ≈ x
#             #Make sure we get back the same factor again
#             F10 = CHOLMOD.lowrankdowndate(F11, C)
#             @test Array(sparse(F10)) ≈ AtA
#             @test F10\b ≈ x0
# 
#             #Test in-place update
#             CHOLMOD.lowrankupdate!(F1, C)
#             @test Array(sparse(F1)) ≈ AtA+C*C'
#             @test F1\b ≈ x
#             #Test in-place downdate
#             CHOLMOD.lowrankdowndate!(F1, C)
#             @test Array(sparse(F1)) ≈ AtA
#             @test F1\b ≈ x0
# 
#             @test C == Ctest    #Make sure C didn't change
#         end
#     end
# end
# 
# @testset "Issue #22335" begin
#     local A, F
#     A = sparse(1.0I, 3, 3)
#     @test issuccess(cholesky(A))
#     A[3, 3] = -1
#     F = cholesky(A; check = false)
#     @test !issuccess(F)
#     @test issuccess(ldlt!(F, A))
#     A[3, 3] = 1
#     @test A[:, 3:-1:1]\fill(1., 3) == [1, 1, 1]
# end
# 
# @testset "Non-positive definite matrices" begin
#     A = sparse(Float64[1 2; 2 1])
#     B = sparse(ComplexF64[1 2; 2 1])
#     for M in (A, B, Symmetric(A), Hermitian(B))
#         F = cholesky(M; check = false)
#         @test_throws PosDefException cholesky(M)
#         @test_throws PosDefException cholesky!(F, M)
#         @test !issuccess(cholesky(M; check = false))
#         @test !issuccess(cholesky!(F, M; check = false))
#     end
#     A = sparse(Float64[0 0; 0 0])
#     B = sparse(ComplexF64[0 0; 0 0])
#     for M in (A, B, Symmetric(A), Hermitian(B))
#         F = ldlt(M; check = false)
#         @test_throws ZeroPivotException ldlt(M)
#         @test_throws ZeroPivotException ldlt!(F, M)
#         @test !issuccess(ldlt(M; check = false))
#         @test !issuccess(ldlt!(F, M; check = false))
#     end
# end
# 
# @testset "Issues #27860 & #28363" begin
#     for typeA in (Float64, ComplexF64), typeB in (Float64, ComplexF64), transform in (identity, adjoint, transpose)
#         A = sparse(typeA[2.0 0.1; 0.1 2.0])
#         B = randn(typeB, 2, 2)
#         @test A \ transform(B) ≈ cholesky(A) \ transform(B) ≈ Matrix(A) \ transform(B)
#         C = randn(typeA, 2, 2)
#         sC = sparse(C)
#         sF = typeA <: Real ? cholesky(Symmetric(A)) : cholesky(Hermitian(A))
#         @test cholesky(A) \ transform(sC) ≈ Matrix(A) \ transform(C)
#         @test sF.PtL \ transform(A) ≈ sF.PtL \ Matrix(transform(A))
#     end
# end
# 
# @testset "Issue #33365" begin
#     A = Sparse(spzeros(0, 0))
#     @test A * A' == A
#     @test A' * A == A
#     B = Sparse(spzeros(0, 4))
#     @test B * B' == Sparse(spzeros(0, 0))
#     @test B' * B == Sparse(spzeros(4, 4))
#     C = Sparse(spzeros(3, 0))
#     @test C * C' == Sparse(spzeros(3, 3))
#     @test C' * C == Sparse(spzeros(0, 0))
# end
# 
# @testset "permutation handling" begin
#     @testset "default permutation" begin
#         # Assemble arrow matrix
#         A = sparse(5I,3,3)
#         A[:,1] .= 1; A[1,:] .= A[:,1]
# 
#         # Ensure cholesky eliminates the fill-in
#         @test cholesky(A).p[1] != 1
#     end
# 
#     @testset "user-specified permutation" begin
#         n = 100
#         A = sprand(n,n,5/n) |> t -> t't + I
#         @test cholesky(A, perm=1:n).p == 1:n
#     end
# end
# 
# @testset "Check common is still in default state" begin
#     # This test intentially depends on all the above tests!
#     current_common = CHOLMOD.getcommon()
#     default_common = Ref(cholmod_common())
#     result = cholmod_l_start(default_common)
#     @test result == CHOLMOD.TRUE
#     @test current_common[].print == 0
#     for name in (
#         :nmethods,
#         :postorder,
#         :final_ll,
#         :supernodal,
#     )
#         @test getproperty(current_common[], name) == getproperty(default_common[], name)
#     end
# end

end # Base.USE_GPL_LIBS

end # module
