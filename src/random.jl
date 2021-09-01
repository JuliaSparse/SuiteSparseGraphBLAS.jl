#TODO:
# This is actually kind of hard. sprand works best for now, but it has problems:
# 1. It involves creating a SparseMatrixCSC -> GBMatrix which is slowish
# 2. It doesn't support the elements from a collection like 1:10.
# 3. It only supports a proportion rather than nvals, boon or bane I'm not sure.

function gbrand(
    rng::AbstractRNG, typeorrange, nrows::Integer, ncols::Integer, density::AbstractFloat;
    symmetric=false, pattern=false, skewsymmetric=false, hermitian=false, nodiagonal=false
)
    type = eltype(typeorrange)
    A = GBMatrix{type}(nrows, ncols)
    (type <: Unsigned || type == Bool) && (skewsymmetric = false)
    if nrows != ncols
        symmetric = false
        skewsymmetric = false
        hermitian = false
    end
    if pattern || symmetric
        skewsymmetric = false
        hermitian = false
    end
    if skewsymmetric
        hermitian = false
        nodiagonal = false
    end
    if !(type <: Complex)
        hermitian = false
    end

    for _ ∈ 1:round(Int64, nrows * ncols * density)
        i = rand(rng, 1:nrows)
        j = rand(rng, 1:ncols)
        nodiagonal && (i == j) && continue
        if pattern
            x = one(type)
        else
            x = rand(rng, typeorrange)
        end
        A[i, j] = x
        symmetric && (A[j, i] = x)
        skewsymmetric && (A[j, i] = -x)
        hermitian && (A[j, i] = conj(x))
    end

    return A
end

function gbrand(
    typeorrange, nrows::Integer, ncols::Integer, density::AbstractFloat;
    symmetric=false, pattern=false, skewsymmetric=false, hermitian=false, nodiagonal=false
)
    return gbrand(
        default_rng(), typeorrange, nrows, ncols, density;
        symmetric, pattern, skewsymmetric, hermitian, nodiagonal
    )
end
