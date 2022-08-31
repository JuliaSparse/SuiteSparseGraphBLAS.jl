function _packdensematrix!(
    A::AbstractGBArray{T}, M::VecOrMat{T};
    desc = nothing, shallow = true
) where {T}
    desc = _handledescriptor(desc)
    Csize = length(A) * sizeof(T)
    ptr = pointer(M)
    if shallow 
        lock(memlock)
        try
            KEEPALIVE[Ptr{Cvoid}(ptr)] = M
        finally
            unlock(memlock)
        end
    end
    @wraperror LibGraphBLAS.GxB_Matrix_pack_FullC(
        gbpointer(A),
        Ref{Ptr{Cvoid}}(ptr),
        Csize,
        false, #isuniform
        desc
    )
    return A
end

function _packdensematrixR!(
    A::AbstractGBArray{T}, M::VecOrMat{T};
    desc = nothing, shallow = true
) where {T}
    desc = _handledescriptor(desc)
    Csize = length(A) * sizeof(T)
    ptr = pointer(M)
    if shallow 
        lock(memlock)
        try
            KEEPALIVE[Ptr{Cvoid}(ptr)] = M
        finally
            unlock(memlock)
        end
    end
    @wraperror LibGraphBLAS.GxB_Matrix_pack_FullR(
        gbpointer(A),
        Ref{Ptr{Cvoid}}(ptr),
        Csize,
        false, #isuniform
        desc
    )
    return A
end

function _packcscmatrix!(
    A::AbstractGBArray{T},
    colptr::Vector{Ti},
    rowidx::Vector{Ti},
    values::Vector{T};
    desc = nothing,
    colptrsize = length(colptr) * sizeof(LibGraphBLAS.GrB_Index),
    rowidxsize = length(rowidx) * sizeof(LibGraphBLAS.GrB_Index),
    valsize = length(values) * sizeof(T),
    decrementindices = true,
    shallow = true
    ) where {T, Ti}
    if decrementindices && colptr[begin] == 1
        decrement!(colptr)
        decrement!(rowidx)
    end

    colpointer = pointer(colptr)
    rowpointer = pointer(rowidx)
    valpointer = pointer(values)
    if shallow
        lock(memlock)
        try
            KEEPALIVE[Ptr{LibGraphBLAS.GrB_Index}(colpointer)] = colptr
            KEEPALIVE[Ptr{LibGraphBLAS.GrB_Index}(rowpointer)] = rowidx
            KEEPALIVE[Ptr{Cvoid}(valpointer)] = values
        finally
            unlock(memlock)
        end
    end
    colptr = Ref{Ptr{LibGraphBLAS.GrB_Index}}(colpointer)
    rowidx = Ref{Ptr{LibGraphBLAS.GrB_Index}}(rowpointer)
    values = Ref{Ptr{Cvoid}}(valpointer)
    desc = _handledescriptor(desc)
    @wraperror LibGraphBLAS.GxB_Matrix_pack_CSC(
        gbpointer(A),
        colptr,
        rowidx,
        values,
        colptrsize,
        rowidxsize,
        valsize,
        false,
        false,
        desc
    )
    return A
end

function _packcsrmatrix!(
    A::AbstractGBArray{T},
    rowptr::Vector{Ti},
    colidx::Vector{Ti},
    values::Vector{T};
    desc = nothing,
    rowptrsize = length(rowptr) * sizeof(LibGraphBLAS.GrB_Index),
    colidxsize = length(colidx) * sizeof(LibGraphBLAS.GrB_Index),
    valsize = length(values) * sizeof(T),
    decrementindices = true,
    shallow = true
    ) where {T, Ti}
    if decrementindices && rowptr[begin] == 1
        decrement!(rowptr)
        decrement(colidx)
    end

    rowpointer = pointer(rowptr)
    colpointer = pointer(colidx)
    valpointer = pointer(values)
    if shallow
        lock(memlock)
        try
            KEEPALIVE[Ptr{LibGraphBLAS.GrB_Index}(rowpointer)] = rowptr
            KEEPALIVE[Ptr{LibGraphBLAS.GrB_Index}(colpointer)] = colidx
            KEEPALIVE[Ptr{Cvoid}(valpointer)] = values
        finally
            unlock(memlock)
        end
    end
    rowptr = Ref{Ptr{LibGraphBLAS.GrB_Index}}(rowpointer)
    colidx = Ref{Ptr{LibGraphBLAS.GrB_Index}}(colpointer)
    values = Ref{Ptr{Cvoid}}(valpointer)

    @wraperror LibGraphBLAS.GxB_Matrix_pack_CSR(
        gbpointer(A),
        rowptr,
        colidx,
        values,
        rowptrsize,
        colidxsize,
        valsize,
        false,
        false,
        desc
    )
    return A
end

function makeshallow!(A)
    ccall((:GB_make_shallow, libgraphblas), Cvoid, (LibGraphBLAS.GrB_Matrix,), gbpointer(parent(A)))
end

function pack!(A::AbstractGBArray, M::VecOrMat; order = ColMajor(), shallow = true)
    if order === ColMajor()
        _packdensematrix!(A, M; shallow)
    else
        _packdensematrixR!(A, M; shallow)
    end
    shallow && makeshallow!(A)
    return A
end

function pack!(
    A::AbstractGBArray, ptr, idx, values; 
    order = ColMajor(), decrementindices = true, shallow = true
)
    
    if order === ColMajor()
        _packcscmatrix!(A, ptr, idx, values; decrementindices, shallow)
    else
        _packcsrmatrix!(A, ptr, idx, values; decrementindices, shallow)
    end
    shallow && makeshallow!(A)
    return A
end

function pack!(A::AbstractGBArray, S::SparseMatrixCSC; shallow = true)
    pack!(A, getcolptr(S), getrowval(S), getnzval(S); shallow)
end
pack!(
    A::AbstractGBArray, 
    S::Transpose{<:Any, <:SparseMatrixCSC}; shallow = true
) = transpose(pack!(A, parent(S); shallow))

function pack!(A::AbstractGBArray, s::SparseVector; shallow = true)
    ptrvec = [1, length(s.nzind) + 1]
    ptrvec = shallow ? ptrvec : _copytoraw(ptrvec)
    pack!(A, ptrvec, s.nzind, s.nzval; shallow)
end
pack!(
    A::AbstractGBArray, 
    s::Transpose{<:Any, <:SparseVector}; shallow = true
) = transpose(pack!(A, parent(s); shallow))

function pack!(::Type{GT}, A::AbstractArray{T}; fill = nothing, shallow = true) where {GT<:AbstractGBArray, T}
    if GT <: AbstractGBVector
        G = GT{T}(size(A, 1); fill)
    else
        G = GT{T}(size(A, 1), size(A, 2); fill)
    end
    return pack!(G, A; shallow)
end
pack!(
    ::Type{GT}, A::Transpose{<:Any, AbstractArray}; 
    fill = nothing, shallow = true
) where {GT<:AbstractGBArray} = 
    transpose(pack!(GT, parent(A); fill, shallow))

# These functions do not have the `!` since they will not modify A during packing (to decrement indices)
function pack(::Type{GT}, A::DenseVecOrMat; fill = nothing, shallow = true) where {GT<:AbstractGBArray}
    return pack!(GT, A; fill, shallow)
end
pack(
    ::Type{GT}, A::Transpose{<:Any, <:DenseVecOrMat}; 
    fill = nothing, shallow = true
) where {GT<:AbstractGBArray} = 
    transpose(pack(GT, parent(A); fill, shallow))

function pack(A::DenseVecOrMat; fill = nothing, shallow = true)
    if A isa AbstractVector
        return pack!(GBVector, A; fill, shallow)
    else
        return pack!(GBMatrix, A; fill, shallow)
    end
end
pack(A::Transpose{<:Any, <:DenseVecOrMat}; fill = nothing, shallow = true) = 
    transpose(pack(parent(A); fill, shallow))

packquote(x) = :($(esc(x)) = SuiteSparseGraphBLAS.pack($(esc(x))))
macro _densepack(expr...)
    keepalives = expr[begin:end-1]
    expr = expr[end]
    syms = packquote.(keepalives)
    display(
    quote
        GC.@preserve $((esc.(keepalives)...)) begin
            println("preserving $(keepalives...)")
        end
    end
    )
end

macro _densepack(sym, ex)
    Meta.isexpr(ex, :call) || throw(ArgumentError("expected call, got $ex"))
    for i in eachindex(ex.args)
        if i > 1 && ex.args[i] === sym
            ex.args[i] = Expr(:call, :pack, sym)
        end
    end
    return esc(:(GC.@preserve $sym $ex))
end

macro _densepack(xs...)
    syms = xs[1:(end - 1)]
    ex = xs[end]
    Meta.isexpr(ex, :call) || throw(ArgumentError("expected call, got $ex"))
    for i in eachindex(ex.args)
        if i > 1 && ex.args[i] ∈ syms
            ex.args[i] = Expr(:call, :pack, ex.args[i])
        end
    end
    return esc(:(GC.@preserve $(syms...) $ex))
end