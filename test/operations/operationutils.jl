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
    desc = Descriptor()
    desc, mask = _handlemask!(desc, ~~~v)
    @test desc.complement_mask && mask isa GBVector
    desc = Descriptor()
    desc, mask = _handlemask!(desc, ~~Structural(v)) 
    @test !desc.complement_mask && desc.structural_mask && mask isa GBVector
end
end
    