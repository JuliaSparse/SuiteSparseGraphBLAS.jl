"""
    GrB_Vector(I, X,[ n, nvals, dup])

Create a GraphBLAS vector of size n such that A[I[k]] = X[k].
dup is a GraphBLAS binary operator used to combine duplicates, it defaults to `FIRST`.
If n is not specified, it is set to maximum(I) (for one based indices).
nvals is set to length(I) if not specified.
"""
function GrB_Vector(
        I::Vector{U},
        X::Vector{T};
        n::Union{Int64, UInt64} = maximum(I).x,
        nvals::Union{Int64, UInt64} = length(I),
        dup::GrB_BinaryOp = default_dup(T)) where {T, U <: Abstract_GrB_Index}

    V = GrB_Vector{T}()
    GrB_T = get_GrB_Type(T)
    if U <: ZeroBasedIndex
        n += 1
    end
    res = GrB_Vector_new(V, GrB_T, n)
    if res != GrB_SUCCESS
        error(res)
    end
    res = GrB_Vector_build(V, I, X, nvals, dup)
    if res != GrB_SUCCESS
        error(res)
    end
    return V
end

"""
    GrB_Vector(T, n)

Create an empty GraphBLAS vector of type T and size n.
"""
function GrB_Vector(T, n::Union{Int64, UInt64})
    V = GrB_Vector{T}()
    GrB_T = get_GrB_Type(T)
    res = GrB_Vector_new(V, GrB_T, n)
    if res != GrB_SUCCESS
        error(res)
    end
    return V
end

"""
    ==(A, B)

Check if two GraphBLAS vectors are equal.
"""
function ==(A::GrB_Vector{T}, B::GrB_Vector{U}) where {T, U}
    T != U && return false

    Asize = size(A)
    Anvals = nnz(A)

    Asize == size(B) || return false
    Anvals == nnz(B) || return false

    C = GrB_Vector(Bool, Asize[1])
    op = equal_op(T)

    res = GrB_eWiseMult(C, GrB_NULL, GrB_NULL, op, A, B, GrB_NULL)
    
    if res != GrB_SUCCESS
        GrB_free(C)
        error(res)
    end

    if nnz(C) != Anvals
        GrB_free(C)
        return false
    end

    result = GrB_reduce(GxB_LAND_BOOL_MONOID, C, GrB_NULL)

    GrB_free(C)

    if typeof(result) == GrB_Info
        error(result)
    end

    return result
end

"""
    size(V,[ dim])

Return the size of a vector.
"""
function size(V::GrB_Vector)
    n = GrB_Vector_size(V)
    if typeof(n) == GrB_Info
        error(n)
    end
    return (n, )
end

function size(V::GrB_Vector, dim::Int64)
    if dim <= 0
        return error("dimension out of range")
    end

    if dim == 1
        n = GrB_Vector_size(V)
        if typeof(n) == GrB_Info
            error(n)
        end
        return n
    end

    return 1
end

"""
    nnz(V)

Return the number of stored (filled) elements in a GraphBLAS vector.
"""
function nnz(V::GrB_Vector)
    nvals = GrB_Vector_nvals(V)
    if typeof(nvals) == GrB_Info
        error(nvals)
    end
    return nvals
end

"""
    findnz(V, [index_type])

Return a tuple (I, X) where I is the indices of the stored values in GraphBLAS vector V and X is a vector of the values.
Indices are zero based by default if not specified.
"""
function findnz(V::GrB_Vector, index_type::Type{<:Abstract_GrB_Index} = ZeroBasedIndex)
    res = GrB_Vector_extractTuples(V, index_type)
    if typeof(res) == GrB_Info
        error(res)
    end
    I, X = res
    return I, X
end

"""
    setindex!(V, x, i)

Set V[i] = x where V is a GraphBLAS vector.
"""
function setindex!(V::GrB_Vector{T}, x::T, i::Abstract_GrB_Index) where T
    res = GrB_Vector_setElement(V, x, i)
    if res != GrB_SUCCESS
        error(res)
    end
end

"""
    getindex(V, i)

Return V[i] where V is a GraphBLAS vector.
"""
function getindex(V::GrB_Vector, i::Abstract_GrB_Index)
    res = GrB_Vector_extractElement(V, i)
    if typeof(res) == GrB_Info
        error(res)
    end
    return res
end

"""
    empty!(V)

Remove all stored entries from GraphBLAS vector V.
"""
function empty!(V::GrB_Vector)
    res = GrB_Vector_clear(V)
    if res != GrB_SUCCESS
        error(res)
    end
end

"""
    copy(V)

Create a new vector with the same domain, size, and contents as GraphBLAS vector V.
"""
function copy(V::GrB_Vector{T}) where T 
    W = GrB_Vector{T}()
    res = GrB_Vector_dup(W, V)
    if res != GrB_SUCCESS
        error(res)
    end
    return W
end

"""
    dropzeros!(v)

Remove all zero entries from GraphBLAS vector.
"""
function dropzeros!(v::GrB_Vector)
    outp_replace_desc = GrB_Descriptor(Dict(GrB_OUTP => GrB_REPLACE))
    res = GrB_assign(v, v, GrB_NULL, v, GrB_ALL, 0, outp_replace_desc)
    if res != GrB_SUCCESS
        error(res)
    end
    res = GrB_free(outp_replace_desc)
    if res != GrB_SUCCESS
        error(res)
    end
end
