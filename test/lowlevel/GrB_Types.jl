@testset "GrB_Types" begin
    @test GrB_Type(Int64) == GrB.GrB_INT64
    @test GrB.get(GrB.GrB_Type(Int64), :eltypecode) == 
        Integer(GrB.LibGraphBLAS.GrB_INT64_CODE)
    @test_throws GrB.InvalidObjectError GrB.GrB_Type(Tuple{})
    
    struct β{T}
        x::T
    end
    T = GrB.GrB_Type(β{Int64})
    @test GrB.get(T, :eltypecode) == 
        Integer(GrB.LibGraphBLAS.GrB_UDT_CODE)
    @test GrB.get(T, :size) == sizeof(β{Int64})
    @test GrB.get(T, :jit_cname) == "__Int64_"
    @test GrB.get(T, :jit_cdef) == "typedef struct { char x [8] ; } __Int64_;"

    @test GrB.ptr_to_GrB_Type[Base.unsafe_convert(GrB.LibGraphBLAS.GrB_Type, T)] === T
    @test T === GrB.GrB_Type(β{Int64})

    T = GrB.GrB_Type(NTuple{8, Int64})
    @test GrB.get(T, :eltypecode) == 
        Integer(GrB.LibGraphBLAS.GrB_UDT_CODE)
    @test GrB.get(T, :size) == sizeof(NTuple{8, Int64})
    @test GrB.get(T, :jit_cname) == "NTuple_8__Int64_"
    @test GrB.get(T, :jit_cdef) == "typedef struct { char x [64] ; } NTuple_8__Int64_;"
end
