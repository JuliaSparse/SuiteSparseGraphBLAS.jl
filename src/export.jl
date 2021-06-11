function exportdensematrix(A::GBMatrix{T};
    desc::Descriptor = Descriptors.NULL
) where {T}
    nrows = Ref{libgb.GrB_Index}(size(A,1))
    ncols = Ref{libgb.GrB_Index}(size(A,2))
    Csize = Ref{libgb.GrB_Index}(length(A) * sizeof(T))
    Cx = Ptr{T}(Libc.malloc(length(A) * sizeof(T)))
    CRef = Ref{Ptr{Cvoid}}(Cx)
    isuniform = Ref{Bool}(false)
    libgb.GxB_Matrix_export_FullC(
        Ref(A.p),
        Ref(toGBType(T).p),
        nrows,
        ncols,
        CRef,
        Csize,
        isuniform,
        desc
    )
    C = Matrix{T}(undef, nrows[], ncols[])
    unsafe_copyto!(pointer(C), Ptr{T}(CRef[]), length(C))
    return C
end

function Matrix(A::GBMatrix)
    return exportdensematrix(A)
end


function exportdensevec(
    v::GBVector{T};
    desc::Descriptor = Descriptors.NULL
) where {T}
    n = Ref{libgb.GrB_Index}(size(v,1))
    vsize = Ref{libgb.GrB_Index}(length(v) * sizeof(T))
    vx = Ptr{T}(Libc.malloc(length(v) * sizeof(T)))
    CRef = Ref{Ptr{Cvoid}}(vx)
    isuniform = Ref{Bool}(false)
    libgb.GxB_Vector_export_Full(
        Ref(v.p),
        Ref(toGBType(T).p),
        n,
        CRef,
        vsize,
        isuniform,
        desc
    )
    v = Vector{T}(undef, n[])
    unsafe_copyto!(pointer(v), Ptr{T}(CRef[]), length(v))
    return v
end

function Vector(v::GBVector)
    return exportdensevec(v)
end
