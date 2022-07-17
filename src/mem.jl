const PTRTOJL = Dict{Ptr{Cvoid}, VecOrMat}()
const memlock = Threads.SpinLock()


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
    println("creating: $p with size $size")
    lock(memlock)
    try
        PTRTOJL[p] = v
    finally
        unlock(memlock)
    end
    return p
end

function gbcalloc(size)
    v = zeros(UInt8, size)
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
        size > 0 && (return gbmalloc(size))
    end
    # We now have that ptr != C_NULL and size > 0
    # so we must resize
    if addr ∈ keys(PTRTOJL)
        lock(memlock)
        return try
            v = pop!(PTRTOJL, ptr)
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
    println("freeing: $addr")
    lock(memlock)
    try
        delete!(PTRTOJL, addr)
    catch
        println("failed to free $addr")
    finally
        unlock(memlock)
    end
    return
end
