function hvcat!(C, Tiles)
    libgb.GxB_Matrix_concat(C, Tiles, size(Tiles,1), size(Tiles,2), C_NULL)
    return C
end

function Base.hvcat(Tiles)
    ncols = sum(size.(Tiles[1,:], 2))
    nrows = sum(size.(Tiles[:, 1], 1))
    types = eltype.(Tiles)
    t = types[1]
    for type ∈ types[2:end]
        t = promote_type(t, type)
    end
    if Tiles isa AbstractArray{<:GBVector} && ncols == 1
        C = GBVector{t}(nrows)
    else
        C = GBMatrix{t}(nrows,ncols)
    end
    return hvcat!(C, Tiles)
end

vcat!(C, A::GBArray...) = hvcat!(C, collect(A))
Base.vcat(A::GBArray...) = hvcat(collect(A))

hcat!(C, A::GBArray...) = hvcat!(C, reshape(collect(A), 1, :))
Base.hcat(A::GBArray...) = hvcat(reshape(collect(A), 1, :))
