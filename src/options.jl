"""
    gbset(A::GBArray, option, value)
    gbset(option, value)

Set an option either for a specific GBArray, or globally. The commonly used options are:
    - `:format = [:byrow | :bycol]`: The global default or array specific
    column major or row major ordering.
    - `:nthreads = [Integer]`: The global number of OpenMP threads to use.
    - `:burble = [Bool]`: Print diagnostic output.
    - `:sparsity_control = [:full | :bitmap | :sparse | :hypersparse]`: Set the sparsity of a
    single GBArray.
"""
gbset

function gbset(option, value)
    option = option_toconst(option)
    value = option_toconst(value)
    libgb.GxB_Global_Option_set(option, value)
    return nothing
end

function gbget(option)
    option = option_toconst(option)
    return libgb.GxB_Global_Option_get(option)
end

function gbset(A::GBMatrix, option, value)
    option = option_toconst(option)
    value = option_toconst(value)
    libgb.GxB_Matrix_Option_set(A, option, value)
    return nothing
end

function gbget(A::GBMatrix, option)
    option = option_toconst(option)
    return libgb.GxB_Matrix_Option_get(A, option)
end

function gbset(A::GBVector, option, value)
    option = option_toconst(option)
    value = option_toconst(value)
    libgb.GxB_Matrix_Option_set(A, option, value)
    return nothing
end

function gbget(A::GBVector, option)
    option = option_toconst(option)
    return libgb.GxB_Matrix_Option_get(A, option)
end

function format(A::GBVecOrMat)
    t = gbget(A, SPARSITY_STATUS)
    f = gbget(A, FORMAT)
    return (GBSparsity(t), GBFormat(f))
end

const HYPER_SWITCH = libgb.GxB_HYPER_SWITCH
const BITMAP_SWITCH = libgb.GxB_BITMAP_SWITCH
const FORMAT = libgb.GxB_FORMAT
const SPARSITY_STATUS = libgb.GxB_SPARSITY_STATUS
const SPARSITY_CONTROL = libgb.GxB_SPARSITY_CONTROL
const BASE1 = libgb.GxB_PRINT_1BASED
const NTHREADS = libgb.GxB_GLOBAL_NTHREADS
const BURBLE = libgb.GxB_BURBLE

const BYROW = libgb.GxB_BY_ROW
const BYCOL = libgb.GxB_BY_COL

#only translate if it's a symbol
option_toconst(option) = option
function option_toconst(sym::Symbol)
    sym === :format && return FORMAT
    sym === :nthreads && return NTHREADS
    sym === :burble && return BURBLE
    sym === :byrow && return BYROW
    sym === :bycol && return BYCOL
    sym === :sparsity_status && return SPARSITY_STATUS
    sym === :sparsity_control && return SPARSITY_CONTROL
    sym === :full && return GBDENSE
    sym === :bitmap && return GBBITMAP
    sym === :sparse && return GBSPARSE
    sym === :hypersparse && return GBHYPER
end


"""
Sparsity options for GraphBLAS. values can be summed to produce additional options.
"""
@enum GBSparsity::Int32 begin
    GBDENSE = 8 #libgb.GxB_FULL
    GBBITMAP = 4 #libgb.GxB_BITMAP
    GBSPARSE = 2 #libgb.GxB_SPARSE
    GBHYPER = 1 #libgb.GxB_HYPERSPARSE
    GBANYSPARSITY = 15 #libgb.GxB_ANY_SPARSITY
    GBDENSE_OR_BITMAP = 12 #libgb.GxB_FULL + libgb.GXB_BITMAP
    GBSPARSE_OR_HYPER = 3 #libgb.GxB_SPARSE + libgb.GXB_HYPERSPARSE
    #... Probably don't need others
end
