const KEEPALIVE = Dict{Ptr, VecOrMat}()
function isshallow(A)
    ccall((:GB_is_shallow, libgraphblas), Bool, (LibGraphBLAS.GrB_Matrix,), A)
end
const memlock = Threads.SpinLock()
function _jlmalloc(size, ::Type{T}) where {T}
    return ccall(:jl_malloc, Ptr{T}, (UInt, ), size)
end
function _jlfree(p::Union{DenseVecOrMat{T}, Ptr{T}, Ref{T}}) where {T}
    ccall(:jl_free, Cvoid, (Ptr{T}, ), p isa DenseVecOrMat ? pointer(p) : p)
end

function _sizedjlmalloc(n, ::Type{T}) where {T}
    return _jlmalloc(n * sizeof(T), T)
end

function _copytoraw(A::DenseVecOrMat{T}) where {T}
    sz = sizeof(A)
    ptr = _jlmalloc(sz, T)
    GC.@preserve A unsafe_copyto!(ptr, pointer(A), length(A))
    return unsafe_wrap(Array, ptr, size(A))
end

# GraphBLAS indices are 64-bit, so narrower index types (e.g. Int32) are widened first.
_int64(v::Vector{Int64}) = v
_int64(v::AbstractVector{<:Integer}) = convert(Vector{Int64}, v)

function _copytoraw(A::SparseMatrixCSC, ::Type{T} = eltype(A)) where {T}
    return _copytoraw(_int64(getcolptr(A))), _copytoraw(_int64(getrowval(A))),
        _copytoraw(convert(Vector{T}, getnzval(A)))
end

function _copytoraw(v::SparseVector, ::Type{T} = eltype(v)) where {T}
    return _copytoraw([1, length(v.nzind) + 1]), _copytoraw(_int64(v.nzind)),
        _copytoraw(convert(Vector{T}, v.nzval))
end
