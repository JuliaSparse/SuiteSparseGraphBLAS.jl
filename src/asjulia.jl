function asArray(f::Function, A::GBVecOrMat{T}; dropzeros=false, freeunpacked=false) where {T}
    if gbget(A, SPARSITY_STATUS) != GBDENSE
        X = similar(A)
        if X isa GBVector
            X[:] = zero(T)
        else
            X[:,:] = zero(T)
        end
        #I don't like this, it defeats the purpose of this method, which is to make no copies.
        # But somehow maintaining the input A in its original form is key to the to_vec implementation
        # for ChainRules. Temporarily it's fine, it's no worse than it originally was.
        # TODO: fix this issue with the ChainRules code.
        A = eadd(X, A)
    end
    array = _unpackdensematrix!(A)
    result = try
        f(array, A)
    finally
        if freeunpacked
            ccall(:jl_free, Cvoid, (Ptr{T},), pointer(array))
        else
            _packdensematrix!(A, array)
            if dropzeros
                select!(nonzeros, A)
            end
        end
    end
    return result
end

function asSparseMatrixCSC(f::Function, A::GBMatrix{T}; freeunpacked=false) where {T}
    colptr, rowidx, values =  _unpackcscmatrix!(A)
    array = SparseMatrixCSC{T, libgb.GrB_Index}(size(A, 1), size(A, 2), colptr, rowidx, values)
    result = try
        f(array, A)
    finally
        if freeunpacked
            ccall(:jl_free, Cvoid, (Ptr{libgb.GrB_Index},), pointer(colptr))
            ccall(:jl_free, Cvoid, (Ptr{libgb.GrB_Index},), pointer(rowidx))
            ccall(:jl_free, Cvoid, (Ptr{T},), pointer(values))
        else
            _packcscmatrix!(A, colptr, rowidx, values)
        end
    end
    return result
end

function asSparseVector(f::Function, A::GBVector{T}; freeunpacked=false) where {T}
    colptr, rowidx, values =  _unpackcscmatrix!(A)
    vector = SparseVector{T, libgb.GrB_Index}(size(A, 1), rowidx, values)
    result = try
        f(vector, A)
    finally
        if freeunpacked
            ccall(:jl_free, Cvoid, (Ptr{libgb.GrB_Index},), pointer(colptr))
            ccall(:jl_free, Cvoid, (Ptr{libgb.GrB_Index},), pointer(rowidx))
            ccall(:jl_free, Cvoid, (Ptr{T},), pointer(values))
        else
            _packcscmatrix!(A, colptr, rowidx, values)
        end
    end
    return result
end


function Base.Matrix(A::GBMatrix)
    return asArray(A) do arr, _
        return copy(arr)
    end
end

function Matrix!(A::GBMatrix)
    return asArray(A; freeunpacked=true) do arr, _
        return copy(arr)
    end
end

function Base.Vector(v::GBVector)
    return asArray(v) do vec, _
        return copy(vec)
    end
end

function Vector!(v::GBVector)
    return asArray(v; freeunpacked=true) do vec, _
        return copy(vec)
    end
end

function SparseArrays.SparseMatrixCSC(A::GBMatrix)
    return asArray(A) do arr, _
        return copy(arr)
    end
end

function SparseArrays.SparseVector(v::GBVector)
    return asArray(v) do arr, _
        return copy(arr)
    end
end
