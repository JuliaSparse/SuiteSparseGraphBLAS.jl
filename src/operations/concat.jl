function cat!(C::GBArray, tiles::AbstractArray{T}) where {T<:GBArray}
    tiles = permutedims(tiles)
    @wraperror LibGraphBLAS.GxB_Matrix_concat(C, tiles, size(tiles,2), size(tiles,1), C_NULL)
    return C
end

"""
    cat(tiles::Array{<:GBArray})

Create a new array formed from the contents of `tiles` in the sense of a block matrix
This doesn't exactly match the Julia notion of `cat`.
"""
function Base.cat(tiles::VecOrMat{T}) where {T<:GBArray}
    ncols = sum(size.(tiles[1,:], 2))
    nrows = sum(size.(tiles[:, 1], 1))
    types = eltype.(tiles)
    t = types[1]
    for type ∈ types[2:end]
        t = promote_type(t, type)
    end
    if tiles isa AbstractArray{<:GBVector} && ncols == 1
        C = GBVector{t}(nrows)
    else
        C = GBMatrix{t}(nrows,ncols)
    end
    return cat!(C, tiles)
end

vcat!(C, A::GBArray...) = cat!(C, collect(A))
Base.vcat(A::GBArray...) = cat(collect(A))

hcat!(C, A::GBArray...) = cat!(C, permutedims(collect(A)))
Base.hcat(A::GBArray...) = cat(permutedims(collect(A)))

# TODO split. I don't necessarily see a great need for split though. We have indexing/slicing.