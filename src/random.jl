"""
    gbrand(typeorrange, nrows, ncols, density; kwargs...)::GBMatrix
    gbrand(rng::AbstractRNG, typeorrange, nrows, ncols, density; kwargs...)::GBMatrix

Construct a random `GBMatrix`, analogous to `sprand` from SparseArrays

# Arguments
- `rng::AbstractRNG`: Random number generator for both values and indices.
- `typeorrange`: Either a type such as `Float64`, or a range such as `1:10`.
Any input which supports `eltype(typeorrange)`.
- `nrows::Integer`, `ncols::Integer`: Dimensions of the result.
- `density::AbstractFloat`: The approximate density of result.

# Keywords
- `symmetric::Bool`: The result matrix is symmetric, Aᵀ = A.
- `pattern::Bool`: The result matrix consists solely of `one(eltype(typeorrange))`.
- `skewsymmetric::Bool`: The result matrix is skew-symmetric, Aᵀ = -A.
- `hermitian::Bool`: The result matrix is hermitian, aᵢⱼ = āⱼᵢ.
- `nodiagonal::Bool`: The result matrix has no values on the diagonal.

# Returns
- `GBMatrix`
"""
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
    # TODO: switch from A[i, j] = x, to COO->build
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
