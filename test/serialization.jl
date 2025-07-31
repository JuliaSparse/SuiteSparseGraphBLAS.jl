using Serialization
using SuiteSparseGraphBLAS: gbread, gbwrite, gbread_matrix
@testset "serialization.jl" begin
    @testset "Serialization.serialize deserialize roundtrip" begin
        struct Point
            x::Float64
            y::Float64
        end
        A = GBMatrix{Point}(10, 10; fill = nothing)
        A[3, 5] = Point(1.0, 11.5)
        path, io = mktemp()
        serialize(io, A)
        close(io)
        B = deserialize(path)
        @test A == B

        A = GBMatrix{Point}(10, 10; fill = Point(0, 0))
        A[3, 5] = Point(1.0, 11.5)
        path, io = mktemp()
        serialize(io, A)
        close(io)
        B = deserialize(path)
        @test A == B
    end
    @testset "gbwrite and gbread" begin
        A = GBMatrix{Point}(10, 10; fill = Point(0, 0))
        A[3, 5] = Point(1.0, 11.5)
        path, io = mktemp()
        gbwrite(io, A)
        close(io)
        B = gbread(path, GBMatrix{Point, Point}; fill = Point(0, 0))
        @test A == B
    end

    @testset "gbwrite and gbread_matrix" begin
        A = gbrand(Float32, 10, 10, 0.25)
        path, io = mktemp()
        gbwrite(io, A)
        close(io)
        B = gbread_matrix(path)
        @test A == B
    end
end
