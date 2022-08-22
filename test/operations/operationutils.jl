using SuiteSparseGraphBLAS: inferunarytype, inferbinarytype,
    Complement, Structural, _handlemask!, _handleaccum, _promotefill
@testset "operationutils.jl" begin
@testset "Unary inference" begin
    @test inferunarytype(ComplexF64, imag) === Float64
    @test inferunarytype(ComplexF64, SuiteSparseGraphBLAS.unaryop(real, ComplexF64)) ===
        Float64
end
@testset "Binary inference" begin
    @test inferbinarytype(ComplexF64, Float32, first) === ComplexF64
    @test inferbinarytype(ComplexF64, Float32, SuiteSparseGraphBLAS.second) === Float32
    f = (x, y) -> x + y
    @test inferbinarytype(ComplexF64, Int32, f) === ComplexF64
    @test inferbinarytype(Float64, Float64, (+, SuiteSparseGraphBLAS.pair)) ==
        Float64
end
@testset "Masking" begin
    v = GBVector([1,3,5], [true, false, true])
    d = Descriptor()
    @test (mask = _handlemask!(d, ~~~v); d.complement_mask && mask isa GBVector)
    d = Descriptor()
    @test (mask = _handlemask!(d, ~~Structural(v)); 
        !d.complement_mask && d.structural_mask && mask isa GBVector)
end
end
    