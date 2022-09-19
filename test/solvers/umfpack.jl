# This file is a part of Julia. License is MIT: https://julialang.org/license

module UMFPACKTests

using Test
using Random
using SparseArrays
using Serialization
using LinearAlgebra:
    I, det, issuccess, ldiv!, lu, lu!, Adjoint, Transpose, SingularException, Diagonal, logabsdet
using SparseArrays: nnz, sparse, sprand, sprandn, SparseMatrixCSC, UMFPACK, increment!
if Base.USE_GPL_LIBS
function umfpack_report(l::UMFPACK.GBUmfpackLU)
    UMFPACK.umfpack_report_numeric(l, 0)
    UMFPACK.umfpack_report_symbolic(l, 0)
    return
end

for itype in UMFPACK.UmfpackIndexTypes
    sol_r = Symbol(UMFPACK.umf_nm("solve", :Float64, itype))
    sol_c = Symbol(UMFPACK.umf_nm("solve", :ComplexF64, itype))
    @eval begin
        function alloc_solve!(x::StridedVector{Float64}, lu::UMFPACK.UmfpackLU{Float64,$itype}, b::StridedVector{Float64}, typ::Integer)
            if x === b
                throw(ArgumentError("output array must not be aliased with input array"))
            end
            if stride(x, 1) != 1 || stride(b, 1) != 1
                throw(ArgumentError("in and output vectors must have unit strides"))
            end
            UMFPACK.umfpack_numeric!(lu)
            (size(b,1) == lu.m) && (size(b) == size(x)) || throw(DimensionMismatch())
            UMFPACK.@isok UMFPACK.$sol_r(typ, lu.colptr, lu.rowval, lu.nzval,
                        x, b, lu.numeric, lu.control,
                        lu.info)
            return x
        end
        function alloc_solve!(x::StridedVector{ComplexF64}, lu::UMFPACK.UmfpackLU{ComplexF64,$itype}, b::StridedVector{ComplexF64}, typ::Integer)
            if x === b
                throw(ArgumentError("output array must not be aliased with input array"))
            end
            if stride(x, 1) != 1 || stride(b, 1) != 1
                throw(ArgumentError("in and output vectors must have unit strides"))
            end
            UMFPACK.umfpack_numeric!(lu)
            (size(b, 1) == lu.m) && (size(b) == size(x)) || throw(DimensionMismatch())
            UMFPACK.@isok UMFPACK.$sol_c(typ, lu.colptr, lu.rowval, lu.nzval, C_NULL, x, C_NULL, b,
                        C_NULL, lu.numeric, lu.control, lu.info)
            return x
        end
    end
end

@testset "Workspace management" begin
    A0 = I + sprandn(100, 100, 0.01)
    b0 = randn(100)
    bn0 = rand(100, 20)
    @testset "Core functionality for $Tv elements" for Tv in (Float64, ComplexF64)
        for Ti in Base.uniontypes(UMFPACK.UMFITypes)
            A = convert(SparseMatrixCSC{Tv,Ti}, A0)
            Af = lu(A)
            umfpack_report(Af)
            b = convert(Vector{Tv}, b0)
            x = alloc_solve!(
                similar(b),
                Af, b,
                UMFPACK.UMFPACK_A)
            @test A \ b == x
            bn = convert(Matrix{Tv}, bn0)
            xn = similar(bn)
            for i in 1:20
                xn[:, i] .= alloc_solve!(
                    similar(bn[:, i]),
                    Af, bn[:, i],
                    UMFPACK.UMFPACK_A)
            end
            @test A \ bn == xn
            umfpack_report(Af)
        end
    end
    function f(Tv, Ti)
        A = convert(SparseMatrixCSC{Tv,Ti}, A0)
        Af = lu(A)
        umfpack_report(Af)
        b = convert(Vector{Tv}, b0)
        x = similar(b)
        ldiv!(x, Af, b)
        aloc1 = @allocated ldiv!(x, Af, b)
        bn = convert(Matrix{Tv}, bn0)
        xn = similar(bn)
        ldiv!(xn, Af, bn)
        aloc2 = @allocated ldiv!(xn, Af, bn)
        umfpack_report(Af)
        return aloc1 + aloc2
    end
    @testset "Allocations" begin
        for Tv in Base.uniontypes(UMFPACK.UMFVTypes),
            Ti in Base.uniontypes(UMFPACK.UMFITypes)
            f(Tv, Ti)
            f(Tv, Ti)
            @test f(Tv, Ti) == 0
        end
    end
    @testset "Thread safety" begin
        Af = lu(A0)
        umfpack_report(Af)
        x = similar(b0)
        ldiv!(x, Af, b0)
        n = 30
        acc = [similar(b0) for _ in 1:n]
        Threads.@threads for i in 1:n
            ldiv!(acc[i], Af, b0)
        end
        for i in acc
            @test i == x
        end
        umfpack_report(Af)
        Af1 = lu!(copy(Af))
        umfpack_report(Af1)
        @test trylock(Af)
        @test trylock(Af1)
    end

    @testset "test similar" begin
        Af = lu(A0)
        umfpack_report(Af)
        sim = similar(Af.workspace)
        for f in [typeof, length],
            p in [:Wi, :W]
            @test f(getproperty(sim, p)) == f(getproperty(Af.workspace, p))
            @test getproperty(sim, p) !== getproperty(Af.workspace, p)
        end
        umfpack_report(Af)
    end
    function test_ws_dup(Af, Af1)
        for i in [:colptr, :rowval, :nzval]
            @test getproperty(Af, i) === getproperty(Af1, i)
        end
        for i in [:n, :m]
            @test getproperty(Af, i) == getproperty(Af1, i)
        end
        for i in [:workspace, :control, :info, :lock]
            @test getproperty(Af, i) !== getproperty(Af1, i)
        end
    end
    @testset "test copy(UmfpackLU)" begin
        Af = lu(A0)
        umfpack_report(Af)
        test_ws_dup(Af, copy(Af))
        test_ws_dup(Af, copy(parent(transpose(Af))))
        test_ws_dup(Af, copy(parent(adjoint(Af))))
        umfpack_report(Af)

        Afcopy = copy(Af)
        @test Afcopy.numeric === Af.numeric
        @test Afcopy.symbolic === Af.symbolic

        Afcopy = copy(Af; safecopy = true)
        @test Afcopy.numeric !== Af.numeric
        @test Afcopy.symbolic !== Af.symbolic
    end
end

@testset "UMFPACK wrappers" begin
    se33 = sparse(1.0I, 3, 3)
    do33 = fill(1., 3)
    @test isequal(se33 \ do33, do33)

    # based on deps/Suitesparse-4.0.2/UMFPACK/Demo/umfpack_di_demo.c

    A0 = GBMatrix(increment!([0,4,1,1,2,2,0,1,2,3,4,4]),
                increment!([0,4,0,2,1,2,1,4,3,2,1,2]),
                [2.,1.,3.,4.,-1.,-3.,3.,6.,2.,1.,4.,2.], nrows = 5, ncols = 5)

    @testset "Core functionality for $Tv elements" for Tv in (Float64, ComplexF64)
        # We might be able to support two index sizes one day
            A = Tv.(A0)
            lua = lu(A)
            umfpack_report(lua)
            @test nnz(lua) == 18
            @test_throws ErrorException lua.Z
            L,U,p,q,Rs = lua.:(:)
            @test L == lua.L
            @test U == lua.U
            @test p == lua.p
            @test q == lua.q
            @test Rs == lua.Rs
            # TODO: Inquire with Tim Davis about this.
            @test (Diagonal(Rs) * A)[p,q] ≈ L * U

            @test det(lua) ≈ det(Array(A))
            logdet_lua, sign_lua = logabsdet(lua)
            logdet_A, sign_A = logabsdet(Array(A))
            @test logdet_lua ≈ logdet_A
            @test sign_lua ≈ sign_A

            b = [8., 45., -3., 3., 19.]
            x = lua\b
            @test x ≈ float([1:5;])

            @test A*x ≈ b
            z = complex.(b)
            x = ldiv!(lua, z)
            @test x ≈ float([1:5;])
            @test z === x
            y = similar(z)
            ldiv!(y, lua, complex.(b))
            @test y ≈ x

            @test A*x ≈ b

            b = [8., 20., 13., 6., 17.]
            x = lua'\b
            @test x ≈ float([1:5;])

            @test A'*x ≈ b
            z = complex.(b)
            x = ldiv!(adjoint(lua), z)
            @test x ≈ float([1:5;])
            @test x === z
            y = similar(x)
            ldiv!(y, adjoint(lua), complex.(b))
            @test y ≈ x

            @test A'*x ≈ b
            x = transpose(lua) \ b
            @test x ≈ float([1:5;])

            @test transpose(A) * x ≈ b
            x = ldiv!(transpose(lua), complex.(b))
            @test x ≈ float([1:5;])
            y = similar(x)
            ldiv!(y, transpose(lua), complex.(b))
            @test y ≈ x

            @test transpose(A) * x ≈ b

            lua = lu(A')
            x = lua \ b
            @test A'*x ≈ b

            lua = lu(transpose(A))
            x = lua \ b
            @test transpose(A)*x ≈ b

            # Element promotion and type inference
            @inferred lua\fill(1, size(A, 2))
            umfpack_report(lua)
        end
    end

    @testset "More tests for complex cases" begin
        Ac0 = complex.(A0,A0)
        for Ti in Base.uniontypes(UMFPACK.UMFITypes)
            Ac = convert(SparseMatrixCSC{ComplexF64,Ti}, Ac0)
            x  = fill(1.0 + im, size(Ac,1))
            lua = lu(Ac)
            umfpack_report(lua)
            L,U,p,q,Rs = lua.:(:)
            @test (Diagonal(Rs) * Ac)[p,q] ≈ L * U
            b  = Ac*x
            @test Ac\b ≈ x
            b  = Ac'*x
            @test Ac'\b ≈ x
            b  = transpose(Ac)*x
            @test transpose(Ac)\b ≈ x
            umfpack_report(lua)
        end
    end

    @testset "Rectangular cases. elty=$elty, m=$m, n=$n" for
        elty in (Float64, ComplexF64),
            (m, n) in ((10,5), (5, 10))

        Random.seed!(30072018)
        A = sparse([1:min(m,n); rand(1:m, 10)], [1:min(m,n); rand(1:n, 10)], elty == Float64 ? randn(min(m, n) + 10) : complex.(randn(min(m, n) + 10), randn(min(m, n) + 10)))
        F = lu(A)
        umfpack_report(F)
        L, U, p, q, Rs = F.:(:)
        @test (Diagonal(Rs) * A)[p,q] ≈ L * U
        umfpack_report(F)
    end

    @testset "Issue #4523 - complex sparse \\" begin
        A, b = sparse((1.0 + im)I, 2, 2), fill(1., 2)
        @test A * (lu(A)\b) ≈ b

        @test det(sparse([1,3,3,1], [1,1,3,3], [1,1,1,1])) == 0
    end

    @testset "UMFPACK_ERROR_n_nonpositive" begin
        @test_throws ArgumentError lu(sparse(Int[], Int[], Float64[], 5, 0))
    end

    @testset "Issue #15099" begin
        testtypes = [
            (ComplexF32, ComplexF64),
            (ComplexF64, ComplexF64),
            (Float32, Float64),
            (Float64, Float64),
            (Int, Float64),
            (ComplexF16, ComplexF64),
            (Float16, Float64),
        ]

        for (Tin, Tout) in testtypes
            F = lu(sparse(fill(Tin(1), 1, 1)))
            umfpack_report(F)
            L = sparse(fill(Tout(1), 1, 1))
            @test F.p == F.q == [1]
            @test F.Rs == [1.0]
            @test F.L == F.U == L
            @test F.:(:) == (L, L, [1], [1], [1.0])
            umfpack_report(F)
        end
    end

    @testset "BigFloat not supported" for T in (BigFloat, Complex{BigFloat})
        @test_throws ArgumentError lu(sparse(fill(T(1), 1, 1)))
    end

    @testset "size(::UmfpackLU)" begin
        m = n = 1
        F = lu(sparse(fill(1., m, n)))
        umfpack_report(F)
        @test size(F) == (m, n)
        @test size(F, 1) == m
        @test size(F, 2) == n
        @test size(F, 3) == 1
        @test_throws ArgumentError size(F,-1)
        umfpack_report(F)
    end

    @testset "Test aliasing" begin
        a = rand(5)
        @test_throws ArgumentError UMFPACK.solve!(a, lu(sparse(1.0I, 5, 5)), a, UMFPACK.UMFPACK_A)
        aa = complex(a)
        @test_throws ArgumentError UMFPACK.solve!(aa, lu(sparse((1.0im)I, 5, 5)), aa, UMFPACK.UMFPACK_A)
    end

    @testset "Issues #18246,18244 - lu sparse pivot" begin
        A = sparse(1.0I, 4, 4)
        A[1:2,1:2] = [-.01 -200; 200 .001]
        F = lu(A)
        umfpack_report(F)
        @test F.p == [3 ; 4 ; 2 ; 1]
    end

    @testset "Test that A[c|t]_ldiv_B!{T<:Complex}(X::StridedMatrix{T}, lu::UmfpackLU{Float64}, B::StridedMatrix{T}) works as expected." begin
        N = 10
        p = 0.5
        A = N*I + sprand(N, N, p)
        X = zeros(ComplexF64, N, N)
        B = complex.(rand(N, N), rand(N, N))
        luA, lufA = lu(A), lu(Array(A))
        umfpack_report(luA)
        @test ldiv!(copy(X), luA, B) ≈ ldiv!(copy(X), lufA, B)
        @test ldiv!(copy(X), adjoint(luA), B) ≈ ldiv!(copy(X), adjoint(lufA), B)
        @test ldiv!(copy(X), transpose(luA), B) ≈ ldiv!(copy(X), transpose(lufA), B)
        umfpack_report(luA)
    end

    @testset "singular matrix" begin
        for A in sparse.((Float64[1 2; 0 0], ComplexF64[1 2; 0 0]))
            @test_throws SingularException lu(A)
            @test !issuccess(lu(A; check = false))
        end
    end

    @testset "deserialization" begin
        A  = 10*I + sprandn(10, 10, 0.4)
        F1 = lu(A)
        for nm in (:W, :Wi)
            x = getfield(F1.workspace, nm)
            x .= rand(eltype(x), length(x))
        end

        umfpack_report(F1)
        b  = IOBuffer()
        serialize(b, F1)
        seekstart(b)
        F2 = deserialize(b)
        for nm in (:colptr, :m, :n, :nzval, :rowval, :status)
            @test getfield(F1, nm) == getfield(F2, nm)
        end
        for nm in (:W, :Wi)
            @test size(getfield(F1.workspace, nm)) == size(getfield(F2.workspace, nm))
        end
        b1 = IOBuffer()
        serialize(b1, (a=F1, b=F2))
        seekstart(b1)
        x = deserialize(b1)
        lu!(x.a)
        lu!(x.b)
        for nm in (:colptr, :m, :n, :nzval, :rowval, :status)
            @test getfield(F1, nm) == getfield(x.a, nm) == getfield(x.b, nm)
        end
        for nm in (:W, :Wi)
            @test size(getfield(x.a.workspace, nm)) == size(getfield(F1.workspace, nm))
            @test size(getfield(x.b.workspace, nm)) == size(getfield(F2.workspace, nm))
        end

        umfpack_report(F1)
        umfpack_report(F2)
        umfpack_report(x.a)
        umfpack_report(x.b)
    end

    @testset "Reuse symbolic LU factorization" begin
        A1 = sparse(increment!([0,4,1,1,2,2,0,1,2,3,4,4]),
                    increment!([0,4,0,2,1,2,1,4,3,2,1,2]),
                    [2.,1.,3.,4.,-1.,-3.,3.,9.,2.,1.,4.,2.], 5, 5)
        testtypes = [Float64, ComplexF64, Float32, ComplexF32, Float16, ComplexF16]
        for Tv in testtypes
            for Ti in Base.uniontypes(UMFPACK.UMFITypes)
                A = convert(SparseMatrixCSC{Tv,Ti}, A0)
                B = convert(SparseMatrixCSC{Tv,Ti}, A1)
                b = Tv[8., 45., -3., 3., 19.]
                F = lu(A)
                umfpack_report(F)
                lu!(F, B)
                umfpack_report(F)
                @test F\b ≈ B\b ≈ Matrix(B)\b

                # singular matrix
                C = copy(B)
                C[4, 3] = Tv(0)
                F = lu(A)
                umfpack_report(F)
                @test_throws SingularException lu!(F, C)
                # change of nonzero pattern
                D = copy(B)
                D[5, 1] = Tv(1.0)
                F = lu(A)
                umfpack_report(F)
                @test_throws ArgumentError lu!(F, D)
                umfpack_report(F)
            end
        end
    end
end

@testset "REPL printing of UmfpackLU" begin
    # regular matrix
    A = sparse([1, 2], [1, 2], Float64[1.0, 1.0])
    F = lu(A)
    facstring = sprint((t, s) -> show(t, "text/plain", s), F)
    lstring = sprint((t, s) -> show(t, "text/plain", s), F.L)
    ustring = sprint((t, s) -> show(t, "text/plain", s), F.U)
    @test facstring == "$(summary(F))\nL factor:\n$lstring\nU factor:\n$ustring"

    # singular matrix
    B = sparse(zeros(Float64, 2, 2))
    F = lu(B; check=false)
    umfpack_report(F)
    facstring = sprint((t, s) -> show(t, "text/plain", s), F)
    @test facstring == "Failed factorization of type $(summary(F))"
    umfpack_report(F)
end


@testset "UMFPACK's lu with custom permutation" begin
    A = sparse([1.0 0.0 0.9778920565882165 0.0 0.0 0.0 0.0 0.0 0.0 0.0;
    0.0 1.0 0.0 0.0 0.0 1.847311282254734 0.0 0.0 0.0 0.0;
    0.0 0.0 1.0 0.0 0.0 0.04863647201402087 0.0 0.0 0.0 -1.1593207405039443;
    0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0 0.5145863988424498;
    0.0421803353935357 0.0 -1.2818900361848549 0.0 1.0 0.0 0.1116124255865398 0.0 0.0 0.0;
    0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.5457237331767308;
    -0.4983003278517826 -0.9974658316950679 1.0734689365455168 -1.0511956770913033 0.0 -0.37409855916460416 1.999357231970987 0.0 0.0 -0.9620788056415616;
    -1.5784683379261246 0.0 0.0 0.0 -0.4147349268116999 0.0 0.8539293641597945 1.0 0.0 0.0;
    0.0 0.0 0.0 0.0 -0.039051958043171624 0.0 0.0 -0.3814599389272203 1.0 0.0;
    0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0])
    q1 = [9, 8, 5, 1, 7, 2, 3, 4, 6, 10]
    q0 = q1 .- 1
    for i in 1:10
        b = randn(10)
        x = lu(A) \ b
        x0 = lu(A; q=q0) \ b
        x1 = lu(A; q=q1) \ b
        @test x ≈ x0
        @test x ≈ x1
    end
end

@testset "changing refinement should resize workspace" begin
    A = lu(sprandn(100, 100, 0.1) + I)
    umfpack_report(A)
    b = randn(100)
    @test length(A.workspace.Wi) == 100
    @test length(A.workspace.W) == 100
    x = A \ b
    A.control[UMFPACK.JL_UMFPACK_IRSTEP] = 2
    y = A \ b
    @test x ≈ y
    @test length(A.workspace.Wi) == 100
    @test length(A.workspace.W) == 500
    umfpack_report(A)
end


for Ti in Base.uniontypes(UMFPACK.UMFITypes)
    A = I + sprandn(100, 100, 0.01)
    Af = lu(A)
    UMFPACK.umfpack_report_numeric(Af, 0)
    UMFPACK.umfpack_report_symbolic(Af, 0)
end

end # Base.USE_GPL_LIBS

end # module
