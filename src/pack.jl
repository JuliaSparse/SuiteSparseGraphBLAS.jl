function _packdensematrix!(
    A::AbstractGBArray{T}, M::VecOrMat{T};
    desc = nothing
) where {T}
    desc = _handledescriptor(desc)
    Csize = length(A) * sizeof(T)
    ptr = pointer(M)
    @wraperror LibGraphBLAS.GxB_Matrix_pack_FullC(
        A,
        Ref{Ptr{Cvoid}}(ptr),
        Csize,
        false, #isuniform
        desc
    )
    return A
end

function _packdensematrixR!(
    A::AbstractGBArray{T}, M::VecOrMat{T};
    desc = nothing
) where {T}
    desc = _handledescriptor(desc)
    Csize = length(A) * sizeof(T)
    ptr = pointer(M)
    @wraperror LibGraphBLAS.GxB_Matrix_pack_FullR(
        A,
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
    decrementindices = true
    ) where {T, Ti}
    if decrementindices && colptr[begin] == 1
        decrement!(colptr)
        decrement!(rowidx)
    end

    colpointer = pointer(colptr)
    rowpointer = pointer(rowidx)
    valpointer = pointer(values)
    colptr = Ref{Ptr{LibGraphBLAS.GrB_Index}}(colpointer)
    rowidx = Ref{Ptr{LibGraphBLAS.GrB_Index}}(rowpointer)
    values = Ref{Ptr{Cvoid}}(valpointer)
    desc = _handledescriptor(desc)
    @wraperror LibGraphBLAS.GxB_Matrix_pack_CSC(
        A,
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
    decrementindices = true
    ) where {T, Ti}
    if decrementindices && rowptr[begin] == 1
        decrement!(rowptr)
        decrement(colidx)
    end

    rowpointer = pointer(rowptr)
    colpointer = pointer(colidx)
    valpointer = pointer(values)
    rowptr = Ref{Ptr{LibGraphBLAS.GrB_Index}}(rowpointer)
    colidx = Ref{Ptr{LibGraphBLAS.GrB_Index}}(colpointer)
    values = Ref{Ptr{Cvoid}}(valpointer)

    @wraperror LibGraphBLAS.GxB_Matrix_pack_CSR(
        A,
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
    ccall((:GB_make_shallow, libgraphblas), Cvoid, (LibGraphBLAS.GrB_Matrix,), parent(A))
end

function pack!(
    A::AbstractGBArray, M::StridedVecOrMat, shallow::Bool = true; 
    order = ColMajor(), decrementindices = true # we don't need this, but it avoids another method.
    )
    if order === ColMajor()
        _packdensematrix!(A, M)
    else
        _packdensematrixR!(A, M)
    end
    shallow && makeshallow!(A)
    return A
end

function pack!(
    A::AbstractGBArray, ptr, idx, values, shallow::Bool = true; 
    order = ColMajor(), decrementindices = true
)
    
    if order === ColMajor()
        _packcscmatrix!(A, ptr, idx, values; decrementindices)
    else
        _packcsrmatrix!(A, ptr, idx, values; decrementindices)
    end
    shallow && makeshallow!(A)
    return A
end

function pack!(A::AbstractGBArray, S::SparseMatrixCSC, shallow::Bool = true; decrementindices =  true)
    pack!(A, getcolptr(S), getrowval(S), getnzval(S), shallow; decrementindices)
end
pack!(
    A::AbstractGBArray, 
    S::Transpose{<:Any, <:SparseMatrixCSC}, shallow; decrementindices = true
) = transpose(pack!(A, parent(S), shallow; decrementindices))

function pack!(A::AbstractGBArray, s::SparseVector, shallow::Bool = true; decrementindices = true)
    ptrvec = [1, length(s.nzind) + 1]
    ptrvec = shallow ? ptrvec : _copytoraw(ptrvec)
    pack!(A, ptrvec, s.nzind, s.nzval, shallow; decrementindices)
end
pack!(
    A::AbstractGBArray, 
    s::Transpose{<:Any, <:SparseVector}, shallow::Bool = true; decrementindices = true
) = transpose(pack!(A, parent(s), shallow; decrementindices))


# if no GBArray is provided then we will always return a GBShallowArray
# We will also *always* decrementindices here.
# 
# function pack!(S::SparseMatrixCSC; fill = nothing)
#     return GBShallowMatrix(S; fill)
# end
# function pack!(S::Transpose{<:Any, <:SparseMatrixCSC}; fill = nothing)
#     return transpose(pack!(S; fill))
# end
# 
# function pack!(s::SparseVector; fill = nothing)
#     return GBShallowVector(s; fill)
# end
# function pack!(S::Transpose{<:Any, <:SparseVector}; fill = nothing)
#     return transpose(pack!(parent(S); fill))
# end

# These functions do not have the `!` since they will not modify A during packing (to decrement indices)
function pack(A::StridedVecOrMat; fill = nothing)
    if A isa AbstractVector
        return GBShallowVector(A; fill)
    else
        GBShallowMatrix(A; fill)
    end
end
function pack(A::Transpose{<:Any, <:StridedVecOrMat}; fill = nothing)
    return transpose(parent(A); fill)
end
pack(A::Transpose{<:Any, <:DenseVecOrMat}; fill = nothing) = 
    transpose(pack(parent(A); fill))

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