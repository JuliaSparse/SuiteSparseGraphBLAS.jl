@testset "kron" begin
    m1 = GBMatrix(UInt64[1, 2, 3, 5], UInt64[1, 3, 1, 2], Int8[1, 2, 3, 5])
    n1 = GBMatrix(ones(UInt32, 4, 4))
    m2 = sparse([1, 2, 3, 5], [1, 3, 1, 2], Int8[1, 2, 3, 5])
    n2 = ones(Int32, 4, 4)
    o1 = kron(m1, n1)
    @test o1 == GBMatrix(kron(m2, n2)) #basic kron is equivalent
    mask = GBMatrix{Bool}(20, 12)
    mask[17:20, 5:8] = false #don't care value, using structural
    #mask out bottom chunk using structural complement
    o2 = kron(m1, n1; mask, desc=SC)
    @test o2[20, 5] === nothing #We don't want values in masked out area
    @test o2[1:2:15, :] == o1[1:2:15, :] #The rest should match, test indexing too.
end
