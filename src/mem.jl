const PTRTOJL = Dict{Ptr{Cvoid}, VecOrMat}()
sizehint!(PTRTOJL, 75)
const memlock = Threads.SpinLock()

const MEMPOOL = zeros(Int64, 10000)

function _jlmalloc(size, ::Type{T}) where {T}
    return ccall(:jl_malloc, Ptr{T}, (UInt, ), size)
end
function _jlfree(p::Union{DenseVecOrMat{T}, Ptr{T}, Ref{T}}) where {T}
    ccall(:jl_free, Cvoid, (Ptr{T}, ), p isa DenseVecOrMat ? pointer(p) : p)
end

function _copytorawptr(A::DenseVecOrMat{T}) where {T}
    sz = sizeof(A)
    ptr = _jlmalloc(sz, T)
    ptr = ptr
    unsafe_copyto!(ptr, pointer(A), length(A))
    return ptr
end

_copytoraw(A::DenseVecOrMat) = unsafe_wrap(Array, _copytorawptr(A), size(A)) 

function gbmalloc(size, type)
    type = juliatype(ptrtogbtype[type])
    v = Vector{type}(undef, size)
    p = Ptr{Cvoid}(pointer(v))
    lock(memlock)
    try
        PTRTOJL[p] = v
    finally
        unlock(memlock)
    end
    return p
end

function gbrealloc(addr, size)
    if addr == C_NULL
        size == 0 && (return C_NULL)
        size > 0 && (return gbmalloc(size, GrB_UINT8))
    end
    # We now have that ptr != C_NULL and size > 0
    # so we must resize
    if addr ∈ keys(PTRTOJL)
        lock(memlock)
        return try
            v = pop!(PTRTOJL, addr)
            resize!(v, size)
            addr = Ptr{Cvoid}(pointer(v))
            PTRTOJL[addr] = v
            addr
        finally
            unlock(memlock)
        end
    else
        return C_NULL
    end
end

# I'm not going to aggressively free here,
# since it could still be valid elsewhere in Julia.
function gbfree(addr)
    lock(memlock)
    try
        delete!(PTRTOJL, addr)
    catch
        _jlfree(addr) # We do this as a back up, 
        # this might be wrong, and maybe should be caught again.
    finally
        unlock(memlock)
    end
    return
end
