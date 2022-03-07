function as(f::Function, type::Type{<:Union{Matrix, Vector}}, A::AbstractGBArray{T}; dropzeros=false, freeunpacked=false, nomodstructure = false) where {T}
    (type == Matrix && !(A isa AbstractMatrix)) && throw(ArgumentError("Cannot wrap $(typeof(A)) in a Matrix."))
    (type == Vector && !(A isa AbstractVector)) && throw(ArgumentError("Cannot wrap $(typeof(A)) in a Vector."))
    if gbget(A, SPARSITY_STATUS) != Int64(GBDENSE)
        X = similar(A)
        if X isa GBVector
            X[:] = zero(T)
        else
            X[:,:] = zero(T)
        end
        if nomodstructure
            A = eadd!(X, A, X)
        else
            A = eadd!(A, X, A)
        end
    end
    
    array = _unpackdensematrix!(A)
    result = try
        f(array)
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

function as(f::Function, ::Type{SparseMatrixCSC}, A::AbstractGBMatrix{T}; freeunpacked=false) where {T}
    colptr, colptrsize, rowidx, rowidxsize, values, valsize =  _unpackcscmatrix!(A)
    array = SparseMatrixCSC{T, LibGraphBLAS.GrB_Index}(size(A, 1), size(A, 2), colptr, rowidx, values)
    result = try
        f(array)
    finally
        if freeunpacked
            ccall(:jl_free, Cvoid, (Ptr{LibGraphBLAS.GrB_Index},), pointer(colptr))
            ccall(:jl_free, Cvoid, (Ptr{LibGraphBLAS.GrB_Index},), pointer(rowidx))
            ccall(:jl_free, Cvoid, (Ptr{T},), pointer(values))
        else
            _packcscmatrix!(A, colptr, rowidx, values; colptrsize, rowidxsize, valsize)
        end
    end
    return result
end

function as(f::Function, ::Type{SparseVector}, A::AbstractGBVector{T}; freeunpacked=false) where {T}
    colptr, colptrsize, rowidx, rowidxsize, values, valsize =  _unpackcscmatrix!(A)
    vector = SparseVector{T, LibGraphBLAS.GrB_Index}(size(A, 1), rowidx, values)
    result = try
        f(vector)
    finally
        if freeunpacked
            ccall(:jl_free, Cvoid, (Ptr{LibGraphBLAS.GrB_Index},), pointer(colptr))
            ccall(:jl_free, Cvoid, (Ptr{LibGraphBLAS.GrB_Index},), pointer(rowidx))
            ccall(:jl_free, Cvoid, (Ptr{T},), pointer(values))
        else
            _packcscmatrix!(A, colptr, rowidx, values; colptrsize, rowidxsize, valsize)
        end
    end
    return result
end


function Base.Matrix(A::AbstractGBMatrix)
    # we use nomodstructure here to avoid the pitfall of densifying A. 
    return as(Matrix, A; nomodstructure=true) do arr
        return copy(arr)
    end
end

function Matrix!(A::AbstractGBMatrix)
    # we use nomodstructure here to avoid the pitfall of densifying A. 
    return as(Matrix, A; freeunpacked=true) do arr
        return copy(arr)
    end
end

function Base.Vector(v::AbstractGBVector)
    # we use nomodstructure here to avoid the pitfall of densifying A. 
    return as(Vector, v; nomodstructure=true) do vec
        return copy(vec)
    end
end

function Vector!(v::AbstractGBVector)
    # we use nomodstructure here to avoid the pitfall of densifying A. 
    return as(Vector, v; freeunpacked=true) do vec
        return copy(vec)
    end
end

function SparseArrays.SparseMatrixCSC(A::AbstractGBMatrix)
    return as(SparseMatrixCSC, A) do arr
        return copy(arr)
    end
end

function SparseArrays.SparseVector(v::AbstractGBVector)
    return as(SparseVector, v) do arr
        return copy(arr)
    end
end
