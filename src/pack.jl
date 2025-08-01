function _packdensematrix!(
    A::AbstractGBArray{T}, M::VecOrMat{T};
    desc = nothing, order = ColMajor()
) where {T}
    desc = _handledescriptor(desc)
    Csize = length(M) * sizeof(T)
    ptr = pointer(M)
    isiso = length(M) == 1 && length(A) != 1
    if order === ColMajor()
        @wraperror LibGraphBLAS.GxB_Matrix_pack_FullC(
            A,
            Ref{Ptr{Cvoid}}(ptr),
            Csize,
            isiso, #isuniform
            desc
        )
    elseif order === RowMajor()
        @wraperror LibGraphBLAS.GxB_Matrix_pack_FullR(
            A,
            Ref{Ptr{Cvoid}}(ptr),
            Csize,
            isiso, #isuniform
            desc
        )
    else
        throw(ArgumentError("order must be either RowMajor() or ColMajor()"))
    end
    return A
end

function _packbitmap!(
    A::AbstractGBArray{T}, bytemap::VecOrMat{B}, values::VecOrMat{T};
    desc = nothing, order = ColMajor()
) where {T, B<:Union{Int8, Bool}}
    desc = _handledescriptor(desc)
    valsize = length(A) * sizeof(T)
    bytesize = length(A) * sizeof(eltype(bytemap))
    isiso = (length(values) == 1) && (length(A) != 1)
    nvals = sum(bytemap)
    bytepointer = Ptr{Int8}(pointer(bytemap))
    valpointer = pointer(values)
    bytepointer = Ref{Ptr{Int8}}(bytepointer)
    valpointer = Ref{Ptr{Cvoid}}(valpointer)

    if order === ColMajor()
        @wraperror LibGraphBLAS.GxB_Matrix_pack_BitmapC(
            A,
            bytepointer,
            valpointer,
            bytesize,
            valsize,
            isiso,
            nvals,
            desc
        )
    elseif order === RowMajor()
        @wraperror LibGraphBLAS.GxB_Matrix_pack_BitmapR(
            A,
            bytepointer,
            valpointer,
            bytesize,
            valsize,
            isiso,
            nvals,
            desc
        )
    else
        throw(ArgumentError("order must be either RowMajor() or ColMajor()"))
    end
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
    jumbled = false
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
        jumbled,
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
    jumbled = false
    ) where {T, Ti}
    if decrementindices && rowptr[begin] == 1
        decrement!(rowptr)
        decrement!(colidx)
    end

    rowpointer = pointer(rowptr)
    colpointer = pointer(colidx)
    valpointer = pointer(values)
    rowptr = Ref{Ptr{LibGraphBLAS.GrB_Index}}(rowpointer)
    colidx = Ref{Ptr{LibGraphBLAS.GrB_Index}}(colpointer)
    values = Ref{Ptr{Cvoid}}(valpointer)
    desc = _handledescriptor(desc)
    @wraperror LibGraphBLAS.GxB_Matrix_pack_CSR(
        A,
        rowptr,
        colidx,
        values,
        rowptrsize,
        colidxsize,
        valsize,
        false,
        jumbled,
        desc
    )
    return A
end

function _packhypermatrix!(
    A::AbstractGBArray{T}, ptr::Vector{Ti}, idx1::Vector{Ti}, idx2::Vector{Ti}, values::Vector{T};
    desc = nothing, order = ColMajor(), decrementindices = true, jumbled = false
) where {T, Ti}
    desc = _handledescriptor(desc)
    valsize = length(A) * sizeof(T)
    ptrsize = length(ptr) * sizeof(Ti)
    idx1size = length(idx1) * sizeof(Ti)
    idx2size = length(idx2) * sizeof(Ti)
    nvec = length(ptr) - 1
    isiso = (length(values) == 1) && (length(A) != 1)
    ptrpointer = Ref{Ptr{LibGraphBLAS.GrB_Index}}(pointer(ptr))
    idx1pointer = Ref{Ptr{LibGraphBLAS.GrB_Index}}(pointer(idx1))
    idx2pointer = Ref{Ptr{LibGraphBLAS.GrB_Index}}(pointer(idx2))
    valpointer = Ref{Ptr{Cvoid}}(pointer(values))
    if decrementindices
        decrement!(ptr)
        decrement!(idx1)
        decrement!(idx2)
    end
    if order === ColMajor()
        @wraperror LibGraphBLAS.GxB_Matrix_pack_HyperCSC(
            A,
            ptrpointer,
            idx1pointer,
            idx2pointer,
            valpointer,
            ptrsize,
            idx1size,
            idx2size,
            valsize,
            isiso,
            nvec,
            jumbled,
            desc
        )
    elseif order === RowMajor()
        @wraperror LibGraphBLAS.GxB_Matrix_pack_HyperCSR(
            A,
            ptrpointer,
            idx1pointer,
            idx2pointer,
            valpointer,
            ptrsize,
            idx1size,
            idx2size,
            valsize,
            isiso,
            nvec,
            jumbled,
            desc
        )
    else
        throw(ArgumentError("order must be either RowMajor() or ColMajor()"))
    end

end

function makeshallow!(A)
    ccall((:GB_make_shallow, libgraphblas), Cvoid, (LibGraphBLAS.GrB_Matrix,), parent(A))
end

function unsafepack!(
    A::AbstractGBArray, M::StridedVecOrMat, shallow::Bool = true; 
    order = ColMajor(), decrementindices = false # we don't need this, but it avoids another method.
    )
    _packdensematrix!(A, M; order)
    shallow && makeshallow!(A)
    gbset!(A, :orientation, storageorder(A))
    return A
end

function unsafepack!(
    A::AbstractGBArray, M::DenseVecOrMat{T}, V::DenseVecOrMat, shallow::Bool = true;
    order = ColMajor(), decrementindices = false
) where {T <: Union{Int8, Bool}}
    _packbitmap!(A, M, V; order)
    shallow && makeshallow!(A)
    gbset!(A, :orientation, storageorder(A))
    return A
end

function unsafepack!(
    A::AbstractGBArray, ptr, idx, values, shallow::Bool = true; 
    order = ColMajor(), decrementindices = true, jumbled = false
)
    if order === ColMajor()
        _packcscmatrix!(A, ptr, idx, values; decrementindices)
    else
        _packcsrmatrix!(A, ptr, idx, values; decrementindices)
    end
    shallow && makeshallow!(A)
    gbset!(A, :orientation, storageorder(A))
    return A
end

function unsafepack!(
    A::AbstractGBArray, ptr, idx1, idx2, values, shallow::Bool = true;
    order = ColMajor(), decrementindices = true, jumbled = false
)
    _packhypermatrix!(A, ptr, idx1, idx2, values; order, decrementindices)
    shallow && makeshallow!(A)
    gbset!(A, :orientation, storageorder(A))
    return A
end

function unsafepack!(A::AbstractGBArray, S::SparseMatrixCSC, shallow::Bool = true; decrementindices =  true)
    unsafepack!(A, getcolptr(S), getrowval(S), getnzval(S), shallow; decrementindices)
end
unsafepack!(
    A::AbstractGBArray, 
    S::Transpose{<:Any, <:SparseMatrixCSC}, shallow; decrementindices = true
) = transpose(unsafepack!(A, parent(S), shallow; decrementindices))

function unsafepack!(A::AbstractGBArray, s::SparseVector, shallow::Bool = true; decrementindices = true)
    ptrvec = [1, length(s.nzind) + 1]
    ptrvec = shallow ? ptrvec : _copytoraw(ptrvec) # TODO: potential segfault when ptrvec goes out.
    unsafepack!(A, ptrvec, s.nzind, s.nzval, shallow; decrementindices)
end
unsafepack!(
    A::AbstractGBArray, 
    s::Transpose{<:Any, <:SparseVector}, shallow::Bool = true; decrementindices = true
) = transpose(unsafepack!(A, parent(s), shallow; decrementindices))

# These functions do not have the `!` since they will not modify A during packing (to decrement indices)
pack(A::StridedVecOrMat) =
    A isa AbstractVector ? GBShallowVector(A) : GBShallowMatrix(A)
function pack(A::Transpose{<:Any, <:StridedVecOrMat})
    return transpose(pack(parent(A)))
end
pack(A::Transpose) = 
    transpose(pack(parent(A)))

pack(A::GBArrayOrTranspose) = A
pack(A::AbstractArray) = pack(convert(Matrix, A))
pack(v::AbstractVector) = pack(convert(Vector, v))

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
