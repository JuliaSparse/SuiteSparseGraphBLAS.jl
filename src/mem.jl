const PTRTOJL = Dict{Ptr{Cvoid}, VecOrMat}()
const memlock = Threads.SpinLock()

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
    lock(memlock)
    try
        delete!(PTRTOJL, addr)
    finally
        unlock(memlock)
    end
    return
end
