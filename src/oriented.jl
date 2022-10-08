StorageOrders.comptime_storageorder(::OrientedGBMatrix{T, F, O}) where {T, F, O} = O
function GBMatrixC{T, F}(
    A::SparseVector; 
    fill = defaultfill(F)
) where {T, F}
    C = GBMatrixC{T, F}(size(A, 1), 1; fill)
    return unsafepack!(C, _copytoraw(A)..., false)
end
GBMatrixC{T}(
    A::SparseVector; 
    fill::F = defaultfill(T)
) where {T, F} = GBMatrixC{T, F}(A; fill)
GBMatrixC(
    A::SparseVector{T}; 
    fill::F = defaultfill(T)
) where {T, F} = GBMatrixC{T, F}(A; fill)

function GBMatrixC{T, F}(
    A::SparseMatrixCSC; 
    fill = defaultfill(F)
) where {T, F}
    C = GBMatrixC{T, F}(size(A)...; fill)
    return unsafepack!(C, _copytoraw(A)..., false)
end
GBMatrixC{T}(
    A::SparseMatrixCSC; 
    fill::F = defaultfill(T)
) where {T, F} = GBMatrixC{T, F}(A; fill)
GBMatrixC(
    A::SparseMatrixCSC{T}; 
    fill::F = defaultfill(T)
) where {T, F} = GBMatrixC{T, F}(A; fill)

# BYROW
function GBMatrixR{T, F}(
    A::SparseVector; 
    fill = defaultfill(F)
) where {T, F}
    C = GBMatrixR{T, F}(size(A, 1), 1; fill)
    unsafepack!(C, _copytoraw(A)..., false)
    LibGraphBLAS.GxB_Matrix_Option_set(C, LibGraphBLAS.GxB_FORMAT, option_toconst(RowMajor()))
    return C
end
GBMatrixR{T}(
    A::SparseVector; 
    fill::F = defaultfill(T)
) where {T, F} = GBMatrixR{T, F}(A; fill)
GBMatrixR(
    A::SparseVector{T}; 
    fill::F = defaultfill(T)
) where {T, F} = GBMatrixR{T, F}(A; fill)

function GBMatrixR{T, F}(
    A::SparseMatrixCSC; 
    fill = defaultfill(F)
) where {T, F}
    C = GBMatrixR{T, F}(size(A)...; fill)
    unsafepack!(C, _copytoraw(A)..., false)
    LibGraphBLAS.GxB_Matrix_Option_set(C, LibGraphBLAS.GxB_FORMAT, option_toconst(RowMajor()))
    return C
end
GBMatrixR{T}(
    A::SparseMatrixCSC; 
    fill::F = defaultfill(T)
) where {T, F} = GBMatrixR{T, F}(A; fill)
GBMatrixR(
    A::SparseMatrixCSC{T}; 
    fill::F = defaultfill(T)
) where {T, F} = GBMatrixR{T, F}(A; fill)