# inplace sorts
function Base.sort!(
    C::Union{GBVecOrMat, Nothing}, #output matrix, possibly aliased with A, 
    #or Nothing if just interested in P
    P::Union{GBVecOrMat, Nothing}, # permutation matrix, possibly Nothing if just interested in C
    A::GBArrayOrTranspose; #input matrix, possibly aliased with C.
    dims = nothing,
    lt = <,
    desc = nothing
    # We only support a limited set of the keywords for now.
    # Missing by, rev, order, alg
)
    A isa GBMatrixOrTranspose && dims === nothing && throw(ArgumentError("dims must be either 1 (sort columns) or 2 (sort rows) for matrix arguments."))
    A isa GBVector && (dims = 1)
    C, P = _handlenothings(C, P)
    C == C_NULL && P == C_NULL && throw(ArgumentError("One (or both) of C and P must not be nothing."))
    op = binaryop(lt, eltype(A))
    if dims == 1
        transpose = true
    elseif dims == 2
        transpose = false
    else
        throw(ArgumentError("dims must be either 1 (sort columns) or 2 (sort rows)"))
    end
    desc = _handledescriptor(desc; in1=A)
    desc.transpose_input1 = transpose
    @wraperror LibGraphBLAS.GxB_Matrix_sort(C, P, op, gbpointer(parent(A)), desc)
    return C
end

function Base.sort!(A::GBVecOrMat; dims = nothing, lt = <, desc = nothing)
    return sort!(A, nothing, A; dims, lt, desc)
end

function Base.sort!(C::GBVecOrMat, A::GBArrayOrTranspose; dims, lt = <, desc = nothing)
    return sort!(C, nothing, A; dims, lt, desc)
end

function Base.sortperm!(P::GBVecOrMat, A::GBArrayOrTranspose; dims = nothing, lt = <, desc = nothing)
    sort!(nothing, P, A; dims, lt, desc)
    return P
end

function Base.sort(A::GBArrayOrTranspose; dims = nothing, lt = <, desc = nothing)
    C = similar(A)
    return sort!(C, A; dims, lt, desc)
end

function Base.sortperm(A::GBArrayOrTranspose; dims = nothing, lt = <, desc = nothing)
    P = similar(A, Int64)
    return sortperm!(P, A; dims, lt, desc)
end

