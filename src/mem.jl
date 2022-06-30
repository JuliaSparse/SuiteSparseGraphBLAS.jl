function _jlmalloc(size)
    return ccall(:jl_malloc, Ptr{Cvoid}, (UInt, ), size)
end
function _jlfree(p::Union{DenseVecOrMat{T}, Ptr{T}, Ref{T}}) where {T}
    ccall(:jl_free, Cvoid, (Ptr{T}, ), p isa DenseVecOrMat ? pointer(p) : p)
end

function _copytorawptr(A::DenseVecOrMat{T}) where {T}
    sz = sizeof(A)
    ptr = _jlmalloc(sz)
    ptr = Ptr{T}(ptr)
    unsafe_copyto!(ptr, pointer(A), length(A))
    return ptr
end

_copytoraw(A::DenseVecOrMat) = unsafe_wrap(Array, _copytorawptr(A), size(A))