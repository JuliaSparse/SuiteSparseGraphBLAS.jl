using KLU
using KLU: increment!, KLUITypes, decrement, klu!, KLUFactorization,
klu_analyze!, klu_factor!
using LinearAlgebra
using SuiteSparseGraphBLAS.GB_KLU
using SuiteSparseGraphBLAS.GB_KLU: GB_KLUFactorization, unsafepack!, unsafeunpack!
using SparseArrays

@testset "KLU Wrappers" begin
    Ap = increment!([0,4,1,1,2,2,0,1,2,3,4,4])
    Ai = increment!([0,4,0,2,1,2,1,4,3,2,1,2])
    Ax = [2.,1.,3.,4.,-1.,-3.,3.,6.,2.,1.,4.,2.]
    A0 = GBMatrix(Ap, Ai, Ax)
    A1 = GBMatrix(increment!([0,4,1,1,2,2,0,1,2,3,4,4]),
                increment!([0,4,0,2,1,2,1,4,3,2,1,2]),
                [2.,1.,3.,4.,-1.,-3.,3.,9.,2.,1.,4.,2.], 5, 5)
    @testset "Core functionality for $Tv elements" for Tv in (Float64, ComplexF64)
            A = Tv.(A0)
            # test the raw vector construction method.
            klua = klu(A)
            @test nnz(klua) == 18
            R = Diagonal(Tv == ComplexF64 ? complex.(klua.Rs) : klua.Rs)
            @test A[klua.p, klua.q] ≈ R * (klua.L * klua.U + klua.F)

            b = [8., 45., -3., 3., 19.]
            x = klua \ b
            @test x ≈ float([1:5;])
            @test A*x ≈ b

            z = complex.(b)
            x = ldiv!(klua, z)
            @test x ≈ float([1:5;])
            @test z === x
            # Can't match UMFPACK's ldiv!(<OUTPUT>, <KLU>, <INPUT>)
            # since klu_solve(<KLU>, <INPUT>) modifies <INPUT>, and has no field for <OUTPUT>.
            @test A*x ≈ b

            b = [8., 20., 13., 6., 17.]
            x = klua'\b
            @test x ≈ float([1:5;])

            @test A'*x ≈ b
            z = complex.(b)
            x = ldiv!(adjoint(klua), z)
            @test x ≈ float([1:5;])
            @test x === z

            @test A'*x ≈ b
            x = transpose(klua) \ b
            @test x ≈ float([1:5;])
            @test transpose(A) * x ≈ b

            x = ldiv!(transpose(klua), complex.(b))
            @test x ≈ float([1:5;])
            @test transpose(A) * x ≈ b

            @inferred klua\fill(1, size(A, 2))

            @testset "Permutation vectors" begin
                #Just to test this works, we'll use the existing permutation vectors.
                @test klu_analyze!(klua, klua.p, klua.q).common.status == 0
                klu_factor!(klua)
                x = klua \ b
                @test A*x ≈ b
            end
            @testset "Utility functions" begin
                K = GB_KLUFactorization(A);
                @test size(K) == (5, 5)
                @test size(K, 3) == 1
                @test_throws ArgumentError K.symbolic
                @test_throws ArgumentError K.numeric
                klu_analyze!(K);
                @test K.symbolic.nz == 12
                @test K.symbolic.nzoff == 4
                klu_factor!(K)
                @test K.numeric.lnz == 7 == K.numeric.unz
                @test K.nblocks == 3
                @test propertynames(K) == (:lnz, :unz, :nzoff, :L, :U, :F, :q, :p, :Rs, :symbolic, :numeric,)
                @test_throws ArgumentError size(K, -1)
                @test size(K, 3) == 1
            end
            @testset "Refactorization" begin
                B = Tv.(A1)
                b = Tv[8., 45., -3., 3., 19.]
                F = klu(A)
                klu!(F, B)
                @test F\b ≈ Matrix(B)\b
                @test klu!(F, nonzeros(B))\b ≈ Matrix(B)\b #test just supplying nzval for recompute
            end

            @testset "Singular matrix" begin
                S = sparse(Tv[1 2; 0 0])
                S = GBMatrix(S)
                @test_throws SingularException klu(S)
            end
        end
    end
@testset "REPL printing of KLU" begin
    A = sparse([1, 2], [1, 2], Float64[1.0, 1.0])
    F = klu(A)
    facstring = sprint((t, s) -> show(t, "text/plain", s), F)
    lstring = sprint((t, s) -> show(t, "text/plain", s), F.L)
    ustring = sprint((t, s) -> show(t, "text/plain", s), F.U)
    fstring = sprint((t, s) -> show(t, "text/plain", s), F.F)
    @test facstring == "$(summary(F))\nL factor:\n$lstring\nU factor:\n$ustring\nF factor:\n$fstring"
end

@testset "Issue #4" begin
    A = GBMatrix{Float64}(15, 15)
    ptr = [1, 8, 12, 16, 21, 22, 27, 34, 37, 39, 41, 44, 47, 50, 55, 58]
    idx = [3, 4, 6, 8, 11, 13, 15, 2, 6, 8, 15, 1, 2, 5, 12, 3, 5, 6, 7, 9, 14, 7, 10, 11, 13, 15, 4, 5, 6, 8, 10, 12, 13, 8, 12, 15, 2, 13, 1, 7, 3, 4, 14, 2, 4, 5, 1, 5, 9, 4, 7, 9, 11, 14, 13, 14, 15]
    vals = [0.2775474841561938, 0.19549953706849155, 0.7221976371086005, 0.4339373082200655, 0.983079431343046, 0.10918778088879799, 0.3728676112188065, 0.9134045061777432, 0.14560891622463457, 0.7715210431553383, 0.2945501295372417, 0.6134722502122134, 0.8777181195348973, 0.6995382425541914, 0.9562490972786235, 0.27001502642215325, 0.8573661029146233, 0.13020432565448115, 0.9221068910751316, 0.17087414970038983, 0.7062975193151109, 0.7668596005709167, 0.46967704631299334, 0.31764226298560083, 0.39054386892157833, 0.36610203401046015, 0.16689896372140534, 0.9624322297755521, 0.1478381603984824, 0.45423514524961806, 0.5564610482579242, 0.1844671322175948, 0.0823893170743808, 0.25409993152712307, 0.10475245199943273, 0.5863595004922162, 0.14733912690513562, 0.6504152422320895, 0.4339054908933866, 0.27614384058497166, 0.4019619228414033, 0.8631491210976487, 0.20159747073826084, 0.3273367915690062, 0.23866880928640288, 0.9557759456784265, 0.016351125161178537, 0.5320355909884844, 0.9010930260468242, 0.3780686420068593, 0.6375477164214856, 0.9850645305956225, 0.5366242762582065, 0.08835652070698918, 0.9877090693717305, 0.9775298646022268, 0.9759511830494418]
    A = SuiteSparseGraphBLAS.unsafepack!(A,
        ptr,
        idx,
        vals,
        true;
        decrementindices = true)
    @test nonzeros(klu(A).F) ≈ [0.20623152093700403, 0.09038754099133628, 1.0]
    @test nonzeros(A) == vals
    klua = klu(A);
    F = klua.F
    @test !SuiteSparseGraphBLAS.isshallow(F)
    unsafeunpack!(A, SuiteSparseGraphBLAS.Sparse())
end