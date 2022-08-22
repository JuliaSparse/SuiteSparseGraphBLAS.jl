@testset "Issues" begin
    @testset "#81" begin
        # basic issue
        B = GBVector([1, 2, 3, 4, 5, 6, 7], [1, 2, 3, 4, 5, 6, 7])
        A = GBMatrix([1,1,2,2,3,4,4,5,6,7,7,7], [2,4,5,7,6,1,3,6,3,3,4,5], [1:12...])
        @test A[:, 2] isa GBVector
        @test A[2, :] isa GBVector
        @test emul(A[:, 2], B) == GBVector([1], [1], nrows = 7)

        # test that GBMatrix <ewise> GBVector is allowed
        # with correct sizes:
        @test GBMatrix(B) .+ B == GBMatrix(B .* 2)
    end

    @testset "#79" begin
        # Indexing GBMatrix with a list of indices
        # mutates that parameter
        i = [1,2]
        A = GBMatrix([1,1,2,2,3,4,4,5,6,7,7,7], [2,4,5,7,6,1,3,6,3,3,4,5], [1:12...])
        A[i, :]
        @test i == [1,2]
    end

    @testset "#78" begin
        @test GBVector{Int}([1, 2, 3, 4, 5, 6, 7], [1, 2, 3, 4, 5, 6, 7]) ==
            GBVector([1, 2, 3, 4, 5, 6, 7], [1, 2, 3, 4, 5, 6, 7])

        @test GBMatrix{Int64}([1,3,5], [1,3,5], [1,3,5]) == 
            GBMatrix([1,3,5], [1,3,5], [1,3,5])

        @test GBVector{Int128}([1,2,3], [1,2,3])[1] == Int128(1)
    end

    @testset "#74" begin
        # this interface needs its own tests.
        # an extra is here for that particular issue.
        A = GBMatrix([[1,2] [3,4]])
        @test *(Monoid((a, b)->a + b, zero), *)(A, A) == A * A
    end

    @testset "#71" begin
        # segfault with weird ctor
        @test_throws ArgumentError GBMatrix{Int, Int}(10, 10)
        @test_throws ArgumentError GBVector{Int, Int}(10)
    end

    @testset "#85" begin
        A = GBMatrix([1,1,2,2,3,4,4,5,6,7,7,7], [2,4,5,7,6,1,3,6,3,3,4,5], [1:12...])
        B = GBVector([3, 4, 5, 6, 7], [3, 4, 5, 6, 7])
        x = subassign!(A, B', 3, :);
        x == GBVector([3,4,5,6,7], [3,4,5,6,7])'
        @test A[3, 3] == 3
        B = GBVector([1, 2, 3, 4, 5, 6, 7], [1, 2, 3, 4, 5, 6, 7])
        @test subassign!(A, B', 3, :; mask=B') == B'
        @test A[3,7] == 7
    end
end