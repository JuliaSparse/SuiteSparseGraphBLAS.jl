# This functionality is derived directly from the MATLAB interface of SuiteSparse:GraphBLAS
# by Tim Davis.

function argminmax(A::GBMatOrTranspose{T}, minmax, dim) where {T}
    nrows, ncols = size(A)
    n = (dim == 2) ? ncols : nrows
    y = GBVector{T}(n)
    y[:] = 1
    if minmax == min || min == BinaryOps.MIN
        rig = Semirings.MIN_FIRST
    else
        rig = Semirings.MAX_FIRST
    end
    dim == 2 ? desc = nothing : desc = T0
    x = mul(A, y, rig; desc=desc) # x = [min|max](A)
    D = Diagonal(x)
    if dim == 1
        G = mul(A, D, Semirings.ANY_EQ)
    else
        G = mul(D, A, Semirings.ANY_EQ)
    end
    select!(NONZERO, G, G)
    mul(G, y, Semirings.MIN_SECONDI1; desc)
end
