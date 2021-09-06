@testset "Operations" begin
    include("operations/ewise.jl")
    include("operations/kron.jl")
    include("operations/map.jl")
    include("operations/mul.jl")
    include("operations/reduce.jl")
    include("operations/select.jl")
    include("operations/transpose.jl")
end
