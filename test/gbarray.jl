@testset "gbarray.jl" begin
    @testset "construction and getindex" begin
        @testset "dense" begin
            #Construction and indexing correct for dense matrices.
            x = rand(Float64, 100, 100)
            m = GBMatrix(x)
            @test m[50, 64] == x[50, 64]
            @test Matrix(m) == x
            #Construction and indexing correct for dense vectors
            x = rand(Bool, 10000)
            v = GBVector(x)
            m = GBMatrix(x)
            @test m[20] == x[20] == v[20]
            @test v == x

            #Indexing tests
            x = sprand(Int64, 100, 100, 0.05)
            m = GBMatrix(x)
            deleteat!(m, 1, 2)
            @test m[1, 2] === getfill(m)
            @test m[:, 3] == GBVector(x[:, 3])
            @test m[2, :] == GBVector(x[2, :])
            @test m[:, :] == m
            @test m[1:2:5, 3:5] == GBMatrix(x[1:2:5, 3:5])
            @test m[3:2:9, :] == GBMatrix(x[3:2:9, :])

            A = GBMatrix([[1,2] [3,4]])
            @test A[[1,2], [1,1]] == [[1,2] [1,2]]

            A = GBMatrix(Int128[[1,2] [3,4]])
            @test A[1, 1] == Int128(1)
            @test (A[1, 1] = 10) == 10
            @test A[1, 1] == Int128(10)
            @test A[1, 1] isa Int128
            @test A'[1, 2] == 2
            deleteat!(A, 1, 1)
            @test A[1, 1] == getfill(A)
            # #104: non-default fill shows up in show
            @test !occursin("fill value", sprint(show, MIME"text/plain"(), A))
            @test occursin("fill value:  17", sprint(show, MIME"text/plain"(), setfill(A, 17)))
            A = GBMatrix(sprand(ComplexF64, 5, 4, 0.5))
            @test Matrix(A') == Matrix(A)'
            @test Matrix(transpose(A)) == transpose(Matrix(A))
        end
        @testset "sparse" begin
            #Construction and indexing correct for sparse matrices
            x = sprand(Int32, 1000, 1000, 0.001)
            m = GBMatrix(x)
            @test nnz(x) == nnz(m)
            mnz = findnz(m)
            xnz = findnz(x)
            # Broken by switching to csr on import. Look into fixing this TODO.
            #@test mnz == xnz

            x = sprand(UInt8, 1000, 0.05)
            v = GBVector(x)
            @test nnz(v) == nnz(x)
            vnz = findnz(v)
            xnz = findnz(x)
            @test vnz == xnz

            # narrower indices and eltype conversion (#144)
            S = SparseMatrixCSC{Float64, Int32}(sparse([1, 3], [1, 2], [1.0, 2.0], 3, 3))
            @test SparseMatrixCSC(GBMatrix(S)) == S
            @test eltype(GBMatrix{Float32}(S)) == Float32 && SparseMatrixCSC(GBMatrix{Float32}(S)) == S
            s = SparseVector{Float64, Int32}(5, Int32[2, 4], [1.0, 2.0])
            @test SparseVector(GBVector(s)) == s
            @test_throws ArgumentError SuiteSparseGraphBLAS.unsafepack!(GBMatrix{Float64}(3, 3), S)

            # scalar-valued constructors
            @test Vector(GBVector([1, 3], 2.0, 4)) == [2.0, 0, 2, 0]
            @test Vector(GBVector((3,), 1.0)) == ones(3)
            @test Matrix(GBMatrix((2, 2), 1.0)) == ones(2, 2)
            @test SuiteSparseGraphBLAS.pack([1.0, 2.0, 3.0])[2] == 2.0 # scalar index on a shallow vector
            w = GBVector([1.0, 0, 3])
            @test Vector(w[[true, false, true]]) == [1.0, 3.0] # logical indexing
            sh = SuiteSparseGraphBLAS.pack([1.0, 2.0])
            @test_throws SuiteSparseGraphBLAS.ShallowException resize!(sh, 3)
            @test_throws SuiteSparseGraphBLAS.ShallowException resize!(SuiteSparseGraphBLAS.pack([1.0 2; 3 4]), 3, 3)
            @test_throws ArgumentError convert(typeof(sh), w)
            b = SuiteSparseGraphBLAS.build!(GBVector{Float64}(3), [1, 3], [1.0, 2.0])
            @test Vector(b) == [1.0, 0, 2.0]
            @test size(reshape(GBMatrix([1.0 2; 3 4]), (Int32(4), Int32(1)))) == (4, 1)
            mon = SuiteSparseGraphBLAS.Monoids.typedmonoid(+, Float64)
            @test SuiteSparseGraphBLAS.Monoids.typedmonoid(mon, Float64) === mon
            @test SuiteSparseGraphBLAS.IndexUnaryOps.indexunaryop(SuiteSparseGraphBLAS.IndexUnaryOps.colleq, Float64, Float64) isa SuiteSparseGraphBLAS.TypedIndexUnaryOperator
        end
    end

    @testset "setindex and empty!" begin
        x = sprand(UInt16, 10, 10, 0.1)
        m = GBMatrix(x)
        empty!(m)
        @test nnz(m) == 0
        #steprange and scalar
        m[1:2:10, 1] = [1, 2, 3, 4, 5]
        @test m[1:2:10, 1] == GBMatrix([1,2,3,4,5])

        #range and range
        m[8:10, 8:10] = GBMatrix([[1,2,3] [4,5,6] [7,8,9]])
        @test Matrix(m[8:10, 8:10]) == [[1,2,3] [4,5,6] [7,8,9]]

        #range, range, accum, and mask
        mask = GBMatrix([[true, true, false] [false, true, true] [true, false,true]])
        m[8:10, 8:10, mask = mask, accum = *, desc = Descriptor(replace_output=true)] =
            fill(10, 3, 3)
        @test m[9, 10] == zero(eltype(m))
        n = setfill(m, nothing)
        @test n[9, 10] === nothing
        @test m[10, 10] == 90

        #vectors
        x = sprand(Float32, 100, 0.35)
        v = GBVector(x)
        empty!(v)
        @test nnz(v) == 0

        #steprange
        v[10:10:100] = collect(1:10)
        @test v[100] == 10

        #steprange, mask, accum
        v[10:10:100, mask = GBVector([true, true, true, false, false,false, true, false, true, true]), accum = SuiteSparseGraphBLAS.iseq] =
        collect(1:10)
        @test v[10] == 1 && v[60] == 6 && v[100] == 1

        ##### UDT:
        x = sprand(Int128, 10, 10, 0.1)
        m = GBMatrix(x)
        empty!(m)
        @test nnz(m) == 0
        #steprange and scalar
        m[1:2:10, 1] = [1, 2, 3, 4, 5]
        @test m[1:2:10, 1] == GBMatrix([1,2,3,4,5])

        #range and range
        m[8:10, 8:10] = GBMatrix([[1,2,3] [4,5,6] [7,8,9]])
        @test Matrix(m[8:10, 8:10]) == [[1,2,3] [4,5,6] [7,8,9]]

        #range, range, accum, and mask
        mask = GBMatrix([[true, true, false] [false, true, true] [true, false,true]])
        m[8:10, 8:10, mask = mask, accum = *, desc = Descriptor(replace_output=true)] =
            fill(10, 3, 3)
        @test m[9, 10] == zero(eltype(m))
        n = setfill(m, nothing)
        @test n[9, 10] === nothing
        @test m[10, 10] == 90

        #vectors
        x = sprand(ComplexF16, 100, 0.35)
        v = GBVector(x)
        empty!(v)
        @test nnz(v) == 0

        #steprange
        v[10:10:100] = collect(1:10)
        @test v[100] == 10

        #steprange, mask, accum
        v[10:10:100, mask = GBVector([true, true, true, false, false,false, true, false, true, true]), accum = SuiteSparseGraphBLAS.iseq] =
        collect(1:10)
        @test v[10] == 1 && v[60] == 6 && v[100] == 1
    end
    @testset "iterators" begin
        gather(it) = (v = []; for x in it; push!(v, x); end; v)
        H = GBMatrix(sparse([1, 7, 3], [2, 2, 900], [1.0, 2.0, 3.0], 1000, 1000)) # hypersparse
        @test gather(SuiteSparseGraphBLAS.iteratecols(H, 2)) == [(1, 1.0), (7, 2.0)]
        @test isempty(gather(SuiteSparseGraphBLAS.iteratecols(H, 5)))
        @test gather(SuiteSparseGraphBLAS.iteratecols(H, 2:900, SuiteSparseGraphBLAS.IndicesIterator())) ==
            [((1, 2), 1.0), ((7, 2), 2.0), ((3, 900), 3.0)]
        Hs = H[1:10, 1:3]; D = Matrix(Hs); vals = []
        for it in SuiteSparseGraphBLAS.iteratecols(Hs, 2, SuiteSparseGraphBLAS.IteratorIterator()); push!(vals, D[it]); end
        @test vals == [1.0, 2.0] # index a dense matrix at the iterator's position
    end
end
