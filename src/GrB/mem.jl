function isshallow(A)
    ccall((:GB_is_shallow, libgraphblas), Bool, (LibGraphBLAS.GrB_Matrix,), A)
end

function _jlmalloc(size, ::Core.Type{T}) where {T}
    return ccall(:jl_malloc, Ptr{T}, (UInt, ), size)
end
function _jlfree(p::Union{DenseVecOrMat{T}, Ptr{T}, Ref{T}}) where {T}
    ccall(:jl_free, Cvoid, (Ptr{T}, ), p isa DenseVecOrMat ? pointer(p) : p)
end

function _sizedjlmalloc(n, ::Core.Type{T}) where {T}
    return _jlmalloc(n * sizeof(T), T)
end

function _copytoraw(A::DenseVecOrMat{T}) where {T}
    sz = sizeof(A)
    ptr = _jlmalloc(sz, T)
    unsafe_copyto!(ptr, pointer(A), length(A))
    return unsafe_wrap(Array, ptr, size(A))
end

# function _copytoraw(A::SparseMatrixCSC)
#     return _copytoraw(getcolptr(A)), _copytoraw(getrowval(A)), _copytoraw(getnzval(A))
# end
# 
# function _copytoraw(v::SparseVector)
#     return _copytoraw([1, length(v.nzind) + 1]), _copytoraw(v.nzind), _copytoraw(v.nzval)
# end
