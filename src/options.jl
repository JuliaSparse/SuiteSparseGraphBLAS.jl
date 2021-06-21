function gbset(field, value)
    libgb.GxB_Global_Option_set(field, value)
    return nothing
end

function gbget(field)
    return libgb.GxB_Global_Option_get(field)
end

function gbset(A::GBMatrix, field, value)
    libgb.GxB_Matrix_Option_set(A, field, value)
    return nothing
end

function gbget(A::GBMatrix, field)
    return libgb.GxB_Matrix_Option_get(A, field)
end

function gbset(A::GBVector, field, value)
    libgb.GxB_Vector_Option_set(A, field, value)
    return nothing
end

function gbget(A::GBVector, field)
    return libgb.GxB_Vector_Option_get(A, field)
end

function format(A::GBVecOrMat)
    t = gbget(A, SPARSITY_STATUS)
    f = gbget(A, FORMAT)
    return (GBSparsity(t), GBFormat(f))
end

@cenum GBOption::Int32 begin
    HYPER_SWITCH = 0
    BITMAP_SWITCH = 34
    FORMAT = 1
    SPARSITY_STATUS = 33
    SPARSITY_CONTROL = 32
end

@cenum GBFormat::Int32 begin
    BYROW = 0 #libgb.GxB_BY_ROW
    BYCOL = 1 #libgb.GxB_BY_COL
    NOFORMAT = -1 #libgb.GxB_NO_FORMAT
end

"""
Sparsity options for GraphBLAS. values can be summed to produce additional options.
"""
@cenum GBSparsity::Int32 begin
    GBDENSE = 8 #libgb.GxB_FULL
    GBBITMAP = 4 #libgb.GxB_BITMAP
    GBSPARSE = 2 #libgb.GxB_SPARSE
    GBHYPER = 1 #libgb.GxB_HYPERSPARSE
    GBANYSPARSITY = 15 #libgb.GxB_ANY_SPARSITY
    GBDENSE_OR_BITMAP = 12 #libgb.GxB_FULL + libgb.GXB_BITMAP
    GBSPARSE_OR_HYPER = 3 #libgb.GxB_SPARSE + libgb.GXB_HYPERSPARSE
    #... Probably don't need others
end
