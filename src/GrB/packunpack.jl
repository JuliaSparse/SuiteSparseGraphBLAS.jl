# Every vector argument to a pack_*! must outlive the matrix `A` *or* be a pointer to memory
# which is allocated via `jl_malloc` (see mem.jl) with `shallow=false` as a keyword argument.
# This includes `iso` valued matrices, which will have: length(Ax) == 1) && (length(Aj) != 1)

function makeshallow!(A::Matrix)
    ccall((:GB_make_shallow, libgraphblas), Cvoid, (LibGraphBLAS.GrB_Matrix,), A)
end

function unsafe_pack_Compressed!(
    A::Matrix{T}, 
    Ap::Vector{<:IType}, 
    Aj::Vector{<:IType}, 
    Ax::Vector{T}, order::Union{RowMajor, ColMajor}, shallow = true;
    desc = C_NULL, jumbled = false, decrement = true
) where {T}
    decrement && (Ap, Aj = fix_indexlist!(Ap, Aj))
    ptr, idx = Ref{Ptr{LibGraphBLAS.GrB_Index}}.(pointer.((Ap, Aj)))
    values = Ref{Ptr{Cvoid}}(pointer(Ax))
    isiso = (length(Ax) == 1) && (length(Aj) != 1)
    GC.@preserve Ap Aj Ax begin
        if order === RowMajor()
            info = LibGraphBLAS.GxB_Matrix_pack_CSR(
                A, ptr, idx, values, length(Ap) * sizeof(LibGraphBLAS.GrB_Index),
                length(Aj) * sizeof(LibGraphBLAS.GrB_Index), length(Ax) * sizeof(T), 
                isiso, jumbled, desc
            )
        elseif order === ColMajor()
            info = LibGraphBLAS.GxB_Matrix_pack_CSR(
                A, ptr, idx, values, length(Ap) * sizeof(LibGraphBLAS.GrB_Index),
                length(Aj) * sizeof(LibGraphBLAS.GrB_Index), length(Ax) * sizeof(T), 
                isiso, jumbled, desc
            )
        end
        if info != LibGraphBLAS.GrB_SUCCESS
            GrB.@fallbackerror info
        end
    end
    shallow && (makeshallow!(A))
    shallow && push!.(A.keepalives, (Ap, Aj, Ax))
    return A
end

function unsafe_pack_HyperCompressed!(
    A::Matrix{T}, 
    Ap::Vector{<:IType}, 
    Ah::Vector{<:IType}, 
    Aj::Vector{<:IType}, 
    Ax::Vector{T}, order::Union{RowMajor, ColMajor}, shallow = true;
    hyperhash = nothing, desc = C_NULL, jumbled = false, decrement = true
) where {T}
    decrement && (Ap = fix_indexlist!(Ap))
    decrement && (Ah = fix_indexlist!(Ah))
    decrement && (Aj = fix_indexlist!(Aj))
    ptr, idx1, idx2 = Ref{Ptr{LibGraphBLAS.GrB_Index}}.(pointer.((Ap, Ah, Aj)))
    values = Ref{Ptr{Cvoid}}(pointer(Ax))
    isiso = (length(Ax) == 1) && (length(Aj) != 1)
    GC.@preserve Ap Ah Aj Ax begin
        if order === RowMajor()
            info = LibGraphBLAS.GxB_Matrix_pack_HyperCSR(
                A, ptr, idx1, idx2, values, 
                length(Ap) * sizeof(Ti), length(Ah) * sizeof(Ti), 
                length(Aj) * sizeof(Ti), length(Ax) * sizeof(T), 
                isiso, length(Ah), jumbled, desc
            )
        else
            info = LibGraphBLAS.GxB_Matrix_pack_HyperCSC(
                A, ptr, idx1, idx2, values, 
                length(Ap) * sizeof(Ti), length(Ah) * sizeof(Ti), 
                length(Aj) * sizeof(Ti), length(Ax) * sizeof(T), 
                isiso, length(Ah), jumbled, desc
            )
        end
        if info != LibGraphBLAS.GrB_SUCCESS
            GrB.@fallbackerror info
        end
    end
    if hyperhash !== nothing
        unsafe_pack_HyperHash!(A, hyperhash, desc = desc)
    end
    shallow && (makeshallow!(A))
    shallow && push!.(A.keepalives, (Ap, Ah, Aj, Ax))
    return A
end
function unsafe_pack_HyperHash!(A::Matrix, Y::Matrix; desc = C_NULL)
    R = Ref{LibGraphBLAS.GrB_Matrix}(Y.p)
    info = LibGraphBLAS.GxB_Matrix_pack_HyperHash(A, R, desc)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@fallbackerror info
    end
    R = nothing; Y.p = C_NULL # Y.p is now owned by A internally.
    # the finalizer will safely accept the C_NULL.
    return A
end

function unsafe_pack_Bytemap!(
    A::Matrix{T}, Ab::Vector{Int8}, Ax::Union{Vector{T}, Base.Matrix{T}}, 
    order::Union{RowMajor, ColMajor}, shallow = true; desc = C_NULL
) where T
    bitmap = Ref{Ptr{Int8}}(pointer(Ab))
    values = Ref{Ptr{Cvoid}}(pointer(Ax))
    isiso = length(Ax) != length(bitmap)
    GC.@preserve Ab Ax begin
        if order === RowMajor()
            info = LibGraphBLAS.GxB_Matrix_pack_BitmapR(
                A, Ab, values, length(Ab) * sizeof(Int8), length(Ax) * sizeof(T), 
                isiso, desc
            )
        else
            info = LibGraphBLAS.GxB_Matrix_pack_BitmapC(
                A, Ab, values, length(Ab) * sizeof(Int8), length(Ax) * sizeof(T), 
                isiso, desc
            )
        end
        if info != LibGraphBLAS.GrB_SUCCESS
            GrB.@fallbackerror info
        end
    end
    shallow && (makeshallow!(A))
    shallow && push!.(A.keepalives, (Ab, Ax))
    return A
end

function unsafe_pack_Full!(
    A::Matrix{T}, Ax::Union{Vector{T}, Base.Matrix{T}}, order::Union{RowMajor, ColMajor}, 
    shallow = true; desc = C_NULL
) where T
    values = Ref{Ptr{Cvoid}}(pointer(Ax))
    isiso = length(Ax == 1) && length(Ax) != length(A)
    GC.@preserve Ax begin
        if order === RowMajor()
            info = LibGraphBLAS.GxB_Matrix_pack_FullR(
                A, values, length(Ax) * sizeof(T), isiso, desc
            )
        else
            info = LibGraphBLAS.GxB_Matrix_pack_FullC(
                A, values, length(Ax) * sizeof(T), isiso, desc
            )
        end
        if info != LibGraphBLAS.GrB_SUCCESS
            GrB.@fallbackerror info
        end
    end
    shallow && (makeshallow!(A))
    shallow && push!.(A.keepalives, (Ax))
    return A
end
function unsafe_unpack_Compressed!(
    A::Matrix{T}, order::Union{RowMajor, ColMajor}, ::Core.Type{Ti}; 
    desc = C_NULL, allowjumbled = false, allowiso = false, increment=true
) where {T, Ti<:Union{CIndex{Int64}, Int64}}
    ptr, idx = Ref{Ptr{LibGraphBLAS.GrB_Index}}.((C_NULL, C_NULL))
    values = Ref{Ptr{Cvoid}}(C_NULL)
    ptrsize, idxsize = Ref{LibGraphBLAS.GrB_Index}(), Ref{LibGraphBLAS.GrB_Index}()
    valuesize = Ref{LibGraphBLAS.GrB_Index}()
    isiso = allowiso ? Ref{Bool}(true) : C_NULL
    isjumbled = allowjumbled ? Ref{Bool}(true) : C_NULL
    nnonzeros = nvals(A)
    if order === RowMajor()
        info = LibGraphBLAS.GxB_Matrix_unpack_CSR(
            A, ptr, idx, values, ptrsize, idxsize, valuesize, isiso, isjumbled, desc
        )
    else
        info = LibGraphBLAS.GxB_Matrix_unpack_CSC(
            A, ptr, idx, values, ptrsize, idxsize, valuesize, isiso, isjumbled, desc
        )
    end
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@fallbackerror info
    end
    isiso = isiso == C_NULL ? false : isiso[]
    isjumbled = isjumbled == C_NULL ? false : isjumbled[]
    ptr = unsafe_wrap(Array, Ptr{Ti}(ptr[]), size(A, 2) + 1)
    idx = unsafe_wrap(Array, Ptr{Ti}(idx[]), nnonzeros)
    increment && unfix_indexlist!(ptr)
    increment && unfix_indexlist!(idx)
    nstored = isiso ? 1 : nnonzeros
    values = unsafe_wrap(Array, Ptr{T}(values[]), nstored)
    if A.shallow
        A.shallow = false
        Base.empty!(A.keepalives)
    end
    return ptr, idx, values, isiso, isjumbled
end

function unsafe_unpack_HyperHash!(A::Matrix; desc = C_NULL)
    r = Ref{LibGraphBLAS.GrB_Matrix}()
    info =  LibGraphBLAS.GxB_Matrix_unpack_HyperHash(A, r, desc)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@fallbackerror info
    end
    return finalizer(Matrix{nothing}(r[])) do B
        @checkfree LibGraphBLAS.GrB_Matrix_free(Ref(B.p))
    end
end
function unsafe_unpack_HyperCompressed!(
    A::Matrix{T}, order::Union{RowMajor, ColMajor}, ::Core.Type{Ti}; 
    desc = C_NULL, allowjumbled = false, allowiso = false, increment=true
) where {T, Ti<:Union{CIndex{Int64}, Int64}}
    ptr, idx1, idx2 = Ref{Ptr{LibGraphBLAS.GrB_Index}}.((C_NULL, C_NULL, C_NULL))
    values = Ref{Ptr{Cvoid}}(C_NULL)
    ptrsize, idx1size = Ref{LibGraphBLAS.GrB_Index}(), Ref{LibGraphBLAS.GrB_Index}()
    idx2size, valuesize = Ref{LibGraphBLAS.GrB_Index}(), Ref{LibGraphBLAS.GrB_Index}()
    isiso = allowiso ? Ref{Bool}(true) : C_NULL
    isjumbled = allowjumbled ? Ref{Bool}(true) : C_NULL
    nvec = Ref{LibGraphBLAS.GrB_Index}()
    nnonzeros = nvals(A)
    hash = unpack_HyperHash!(A)
    if order === RowMajor()
        info = LibGraphBLAS.GxB_Matrix_unpack_HyperCSR(
            A, ptr, idx1, idx2, values, ptrsize, idx1size, 
            idx2size, valuesize, isiso, isjumbled, desc
        )
    else
        info = LibGraphBLAS.GxB_Matrix_unpack_HyperCSC(
            A, ptr, idx1, idx2, values, ptrsize, idx1size, 
            idx2size, valuesize, isiso, isjumbled, nvec, desc
        )
    end
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@fallbackerror info
    end
    isiso = isiso == C_NULL ? false : isiso[]
    isjumbled = isjumbled == C_NULL ? false : isjumbled[]
    nvec = nvec[]
    ptr = unsafe_wrap(Array, Ptr{Ti}(ptr[]), nvec + 1)
    idx1 = unsafe_wrap(Array, Ptr{Ti}(idx1[]), nvec)
    idx2 = unsafe_wrap(Array, Ptr{Ti}(idx2[]), nnonzeros)
    increment && unfix_indexlist!(ptr)
    increment && unfix_indexlist!(idx1)
    increment && unfix_indexlist!(idx2)
    nstored = isiso ? 1 : nnonzeros
    values = unsafe_wrap(Array, Ptr{T}(values[]), nstored)
    if A.shallow
        A.shallow = false
        Base.empty!(A.keepalives)
    end
    return ptr, idx, values, isiso, isjumbled, hash
end

function unsafe_unpack_Bytemap!(
    A::Matrix{T}, order::Union{RowMajor, ColMajor}, ::Core.Type{VM}; 
    desc = C_NULL, allowiso = false
) where {T, VM}
    sizeBytemap = Ref{LibGraphBLAS.GrB_Index}(length(A) * sizeof(Int8))
    sizeValues = Ref{LibGraphBLAS.GrB_Index}(length(A) * sizeof(T))
    bytemap = Ref{Ptr{Int8}}(C_NULL)
    values = Ref{Ptr{Cvoid}}(C_NULL)
    nvals = Ref{LibGraphBLAS.GrB_Index}()
    isiso = allowiso ? Ref{Bool}(true) : C_NULL
    if order === RowMajor()
        info = LibGraphBLAS.GxB_Matrix_unpack_BytemapR(
            A, bytemap, values, sizeBytemap, sizeValues, isiso, nvals, desc
        )
    else
        info = LibGraphBLAS.GxB_Matrix_unpack_BytemapC(
            A, bytemap, values, sizeBytemap, sizeValues, isiso, nvals, desc
        )
    end
    isiso = isiso == C_NULL ? false : isiso[]
    outputdims = 
        if VM === Vector
            (size(A, 1) == length(A) || size(A, 2) == length(A)) ? 
                length(A) : 
                (throw(ArgumentError("Cannot unpack a matrix of size $(size(A)) into a vector")))
        else
            order === ColMajor() ? size(A) : (size(A, 2), size(A, 1))
        end
    bytes = unsafe_wrap(Array, bytemap[], outputdims)
    values = unsafe_wrap(
        Array, Ptr{T}(values[]), isiso ? (VM === Vector ? 1 : (1, 1)) : outputdims
    )
    nvals = nvals[]
    if A.shallow
        A.shallow = false
        Base.empty!(A.keepalives)
    end
    return bytes, values, isiso, nvals
end

function unsafe_unpack_Full!(
    A::Matrix{T}, order::Union{RowMajor, ColMajor}, ::Core.Type{VM}; 
    desc = C_NULL, allowiso = false
) where {T, VM}
    sizeValues = Ref{LibGraphBLAS.GrB_Index}(length(A) * sizeof(T))
    values = Ref{Ptr{Cvoid}}(C_NULL)
    isiso = allowiso ? Ref{Bool}(true) : C_NULL
    GC.@preserve Ax begin
        if order === RowMajor()
            info = LibGraphBLAS.GxB_Matrix_unpack_FullR(
                A, values, sizeValues, isiso, desc
            )
        else
            info = LibGraphBLAS.GxB_Matrix_unpack_FullC(
                A, values, sizeValues, isiso, desc
            )
        end
    end
    isiso = isiso == C_NULL ? false : isiso[]
    outputdims = 
        if isiso
            VM === Vector ? 1 : (1, 1)
        elseif VM === Vector
            (size(A, 1) == length(A) || size(A, 2) == length(A)) ? 
                length(A) : 
                (throw(ArgumentError("Cannot unpack a matrix of size $(size(A)) into a vector")))
        else
            order === ColMajor() ? size(A) : (size(A, 2), size(A, 1))
        end
    values = unsafe_wrap(Array, Ptr{T}(values[]), outputdims)
    if A.shallow
        A.shallow = false
        Base.empty!(A.keepalives)
    end
    return values, isiso
end
