"""
    gbset(A::GBArray, option, value)
    gbset(option, value)

Set an option either for a specific GBArray, or globally. The commonly used options are:
    - `:format = [RowMajor() | ColMajor()]`: The global default or array specific
    column major or row major ordering.
    - `:nthreads = [Integer]`: The global number of OpenMP threads to use.
    - `:burble = [Bool]`: Print diagnostic output.
    - `:sparsity_control = [:full | :bitmap | :sparse | :hypersparse]`: Set the sparsity of a
    single GBArray.
"""
gbset
using .LibGraphBLAS: GrB_Descriptor, GrB_Info, GrB_Desc_Field, GrB_Desc_Value, GrB_OUTP, GrB_MASK, GrB_INP0, GrB_INP1,
GxB_DESCRIPTOR_NTHREADS, GxB_AxB_METHOD, GxB_SORT, GxB_DESCRIPTOR_CHUNK, GxB_HYPER_SWITCH, GxB_BITMAP_SWITCH,
GxB_GLOBAL_CHUNK, GxB_BURBLE, GxB_PRINT_1BASED, GxB_FORMAT, GxB_SPARSITY_STATUS, GxB_SPARSITY_CONTROL, GxB_GLOBAL_NTHREADS
# manually wrapping these. They use `...` so aren't picked up by Clang.

function GxB_Global_Option_get(field)
    if field ∈ [GxB_HYPER_SWITCH, GxB_BITMAP_SWITCH]
        T = Cdouble
    elseif field ∈ [GxB_FORMAT]
        T = UInt32
    elseif field ∈ [GxB_GLOBAL_NTHREADS, GxB_GLOBAL_CHUNK]
        T = Cint
    elseif field ∈ [GxB_BURBLE]
        T = Bool
    end
    v = Ref{T}()
    LibGraphBLAS.GxB_Global_Option_get(field, v)
    return v[]
end

function GxB_Global_Option_set(field, value)
    if field ∈ [GxB_HYPER_SWITCH, GxB_BITMAP_SWITCH, GxB_GLOBAL_CHUNK]
        value isa Cdouble || throw(ArgumentError("$field specifies a value of type Float64"))
    elseif field ∈ [GxB_GLOBAL_NTHREADS, GxB_BURBLE, GxB_PRINT_1BASED, GxB_FORMAT]
        value = Cint(value)
    else
        throw(ArgumentError("$field is not a valid Matrix option."))
    end
    LibGraphBLAS.GxB_Global_Option_set(field, value)
end

function GxB_Matrix_Option_get(A::AbstractGBArray, field)
    if field ∈ [GxB_HYPER_SWITCH, GxB_BITMAP_SWITCH]
        T = Cdouble
    elseif field ∈ [GxB_FORMAT, GxB_SPARSITY_STATUS, GxB_SPARSITY_CONTROL]
        T = Cint
    end
    v = Ref{T}()
    LibGraphBLAS.GxB_Matrix_Option_get(A, field, v)
    return v[]
end

function GxB_Matrix_Option_set(A::AbstractGBArray, field, value)
    if field ∈ [GxB_HYPER_SWITCH, GxB_BITMAP_SWITCH]
        value isa Cdouble || throw(ArgumentError("$field specifies a value of type Float64"))
    elseif field == GxB_FORMAT
        value isa LibGraphBLAS.GxB_Format_Value || 
            throw(ArgumentError("$field specifies a value of type GxB_Format_Value"))
    elseif field == GxB_SPARSITY_CONTROL
        value isa Cint || throw(ArgumentError("$field specifies a value of type Cint"))
    else
        throw(ArgumentError("$field is not a valid Matrix option."))
    end
    LibGraphBLAS.GxB_Matrix_Option_set(A, field, value)
end

function gbset(option, value)
    option = option_toconst(option)
    value = option_toconst(value)
    GxB_Global_Option_set(option, value)
    return nothing
end

function gbget(option)
    option = option_toconst(option)
    return GxB_Global_Option_get(option)
end

function gbset(A::AbstractGBArray, option, value)
    option = option_toconst(option)
    if option == GxB_FORMAT && _hasconstantorder(A)
        throw(ArgumentError("$(typeof(A)) may not have its storage order changed."))
    end
    value = option_toconst(value)
    GxB_Matrix_Option_set(A, option, value)
    return nothing
end

function gbget(A::AbstractGBArray, option)
    option = option_toconst(option)
    return GxB_Matrix_Option_get(A, option)
end

"""
    sparsitystatus(A::AbstractGBArray)::AbstractSparsity

Return the current sparsity of `A`, which is one of `Dense`,
`Bitmap`, `Sparse`, or `Hypersparse`.
"""
function sparsitystatus(A::AbstractGBArray)
    t = GBSparsity(gbget(A, SPARSITY_STATUS))
    return consttoshape(t)
end

"""
    format(A::AbstractGBArray) -> (s::AbstractSparsity, o::StorageOrders.StorageOrder)

Return the sparsity status and storage order of `A` as a tuple.
"""
function format(A::AbstractGBArray)
    return (sparsitystatus(A), storageorder(A))
end

"""
    setstorageorder!(A::AbstractGBArray, o::StorageOrders.StorageOrder)

Set the storage order of A, either `StorageOrders.RowMajor()` or `StorageOrders.ColMajor()`.

Users must call `wait(A)` before this will be reflected in `A`, 
however operations will perform this `wait` automatically on input.
"""
function setstorageorder!(A::AbstractGBArray, o::StorageOrders.StorageOrder)
    gbset(A, :format, o)
end

shapetoconst(::Dense) = GBDENSE
shapetoconst(::Bytemap) = GBBITMAP
shapetoconst(::Sparse) = GBSPARSE
shapetoconst(::Hypersparse) = GBHYPER

function consttoshape(c)
    c == GBDENSE && (return Dense())
    c == GBBITMAP && (return Bytemap())
    c == GBSPARSE && (return Sparse())
    c == GBHYPER && (return Hypersparse())
end

const HYPER_SWITCH = LibGraphBLAS.GxB_HYPER_SWITCH
const BITMAP_SWITCH = LibGraphBLAS.GxB_BITMAP_SWITCH
const FORMAT = LibGraphBLAS.GxB_FORMAT
const SPARSITY_STATUS = LibGraphBLAS.GxB_SPARSITY_STATUS
const SPARSITY_CONTROL = LibGraphBLAS.GxB_SPARSITY_CONTROL
const BASE1 = LibGraphBLAS.GxB_PRINT_1BASED
const NTHREADS = LibGraphBLAS.GxB_GLOBAL_NTHREADS
const BURBLE = LibGraphBLAS.GxB_BURBLE

const BYROW = LibGraphBLAS.GxB_BY_ROW
const BYCOL = LibGraphBLAS.GxB_BY_COL

#only translate if it's a symbol
option_toconst(option) = option
function option_toconst(option::StorageOrders.StorageOrder)
    option === StorageOrders.ColMajor() && (return BYCOL)
    option === StorageOrders.RowMajor() && (return BYROW)
    throw(ArgumentError("Invalid Orientation setting $option"))
end
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

function option_toconst(sparsity::AbstractSparsity)
    return shapetoconst(sparsity)
end

"""
Sparsity options for GraphBLAS. values can be summed to produce additional options.
"""
@enum GBSparsity::Int32 begin
    GBDENSE = 8 #LibGraphBLAS.GxB_FULL
    GBBITMAP = 4 #LibGraphBLAS.GxB_BITMAP
    GBSPARSE = 2 #LibGraphBLAS.GxB_SPARSE
    GBHYPER = 1 #LibGraphBLAS.GxB_HYPERSPARSE
    GBANYSPARSITY = 15 #LibGraphBLAS.GxB_ANY_SPARSITY
    GBDENSE_OR_BITMAP = 12 #LibGraphBLAS.GxB_FULL + LibGraphBLAS.GXB_BITMAP
    GBSPARSE_OR_HYPER = 3 #LibGraphBLAS.GxB_SPARSE + LibGraphBLAS.GXB_HYPERSPARSE
    #... Probably don't need others
end
