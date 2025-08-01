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
        @test m[9, 10] === novalue
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
        @test m[9, 10] == novalue
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
end
