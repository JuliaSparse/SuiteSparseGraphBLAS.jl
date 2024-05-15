for (typesym, jltype) ∈ (
    (:Scalar, :Scalar), (:Matrix, :Matrix), 
    (:UnaryOp, :(UnaryOp)), (:IndexUnaryOp, :IndexUnaryOp), 
    (:BinaryOp, :BinaryOp), (:Monoid, :Monoid), (:Semiring, :Semiring),
    (:Descriptor, :Descriptor),
    (:Type, :Type), (:Global, :(Global))
)
for (intypesym, intype, outtype) ∈ (
    (:Scalar, :Scalar, :Scalar), (:String, :String, :(Vector{UInt8})), 
    (:INT32, :Int32, :(Base.RefValue{Int32}))
)
    @eval begin
        function get!(
            object::$(jltype), 
            field::Enum{UInt32},
            value::$outtype
        )
            info = LibGraphBLAS.$(Symbol(:GrB_, typesym, :_get_, intypesym))(object, value, field)
            if info != LibGraphBLAS.GrB_SUCCESS
                GrB.@invalidvalue info field
                GrB.@uninitializedobject info object
                GrB.@fallbackerror info
            end
            return value
        end
        function set!(
            object::$(jltype), 
            field::Enum{UInt32},
            value::$intype
        )
            info = LibGraphBLAS.$(Symbol(:GrB_, typesym, :_set_, intypesym))(object, value, field)
            if info != LibGraphBLAS.GrB_SUCCESS
                GrB.@invalidvalue info field
                GrB.@uninitializedobject info object
                GrB.@alreadyset info object field
                GrB.@fallbackerror info
            end
            return value
        end
    end
end
    @eval begin
        function get!(
            object::$(jltype), 
            field::Enum{UInt32},
            value::Ptr{Cvoid}
        )
            info = LibGraphBLAS.$(Symbol(:GrB_, typesym, :_get_VOID))(object, value, field)
            if info != LibGraphBLAS.GrB_SUCCESS
                GrB.@invalidvalue info field
                GrB.@uninitializedobject info object
                GrB.@fallbackerror info
            end
            return value
        end
        function set!(
            object::$(jltype), 
            field::Enum{UInt32},
            value::Ptr{Cvoid}, size::Integer
        )
            info = LibGraphBLAS.$(Symbol(:GrB_, typesym, :_set_VOID))(object, value, field, size)
            if info != LibGraphBLAS.GrB_SUCCESS
                GrB.@invalidvalue info field
                GrB.@uninitializedobject info object
                GrB.@alreadyset info object field
                GrB.@fallbackerror info
            end
            return value
        end
        function get!(
            object::$(jltype), 
            field::Enum{UInt32},
            value::Base.RefValue{Csize_t}
        )
            info = LibGraphBLAS.$(Symbol(:GrB_, typesym, :_get_SIZE))(object, value, field)
            if info != LibGraphBLAS.GrB_SUCCESS
                GrB.@invalidvalue info field
                GrB.@uninitializedobject info object
                GrB.@fallbackerror info
            end
            return value
        end
    end
end

function set!(obj, option, value)
    optionconst, type, isreadable, iswriteable = option_toconst(option)
    if optionconst == LibGraphBLAS.GrB_STORAGE_ORIENTATION_HINT && _hasconstantorder(obj) &&
        value !== storageorder(obj)
        throw(ArgumentError("$(typeof(A)) may not have its storage orientation changed."))
    end
    !iswriteable && throw(ArgumentError("Option $option is not readable."))
    value2 = type !== Ptr{Cvoid} ? convert(type, value_toconst(value)) : value # TODO: this is really not good.
    set!(obj, optionconst, value2)
    return value
end

function _gbgetsize(option)
    _gbgetsize(Global(), option)
end
function _gbgetsize(obj, option)
    optionconst, type, isreadable, isrwriteable = option_toconst(option)
    return get!(obj, optionconst, Base.RefValue{Csize_t}())[]
end

function get(obj::Union{Type, Scalar, Matrix, UnaryOp, IndexUnaryOp, BinaryOp, Monoid, Semiring, Descriptor, Global}, option::Union{Symbol, Enum})
    optionconst, type, isreadable, iswriteable = option_toconst(option)
    !isreadable && throw(ArgumentError("Option $option is not writeable."))
    if type === String
        sz = _gbgetsize(obj, option)
        value = Vector{UInt8}(undef, sz)
        get!(obj, optionconst, value)
        if value !== C_NULL
            return unsafe_string(pointer(value))
        else
            throw(ErrorException("$option returned null pointer."))
        end
    else
        if !(type <: Scalar)
            value = Ref{type}()
            get!(obj, optionconst, value)
            return value[]
        else
            value = type()
            get!(obj, optionconst, value)
            return value[]
        end
    end
end

# We need to do this at runtime. This should perhaps be `RuntimeOrder`, but that trait should likely be removed.
# This should ideally work out fine. a GBMatrix or GBVector won't have 
SparseBase.runtime_storageorder(A::Matrix) = get!(A, :orientation) == 
    Integer(LibGraphBLAS.GrB_COLMAJOR) ? SparseBase.ColMajor() : SparseBase.RowMajor()


"""
    sparsitystatus(A)::AbstractSparsity

Return the current sparsity of `A`, which is one of `Dense`,
`Bitmap`, `Sparse`, or `Hypersparse`.
"""
function sparsitystatus(A)
    wait(A) # We need to do this to ensure we're actually unpacking correctly.
    t = GBSparsity(get!(A, :sparsitystatus))
    return consttoshape(t)
end

"""
    format(A) -> (s::AbstractSparsity, o::SparseBase.StorageOrder)

Return the sparsity status and storage order of `A` as a tuple.
"""
function format(A::Matrix)
    return (sparsitystatus(A), storageorder(A))
end

"""
    setstorageorder[!](A, o::SparseBase.StorageOrder)

Set the storage order of A, either `SparseBase.RowMajor()` or `SparseBase.ColMajor()`.

Users must call `wait(A)` before this will be reflected in `A`, 
however operations will perform this `wait` automatically on input.
"""
function setstorageorder!(A::Matrix, o::SparseBase.StorageOrder)
    set!(A, :orientation, o)
end

function setstorageorder(A::Matrix, o::SparseBase.StorageOrder)
    B = dup(A)
    set!(B, :orientation, o)
    return B
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

#only translate if it's a symbol
value_toconst(option) = option
function value_toconst(option::SparseBase.StorageOrder)
    option === SparseBase.ColMajor() && (return Int32(LibGraphBLAS.GrB_COLMAJOR))
    option === SparseBase.RowMajor() && (return Int32(LibGraphBLAS.GrB_ROWMAJOR))
    throw(ArgumentError("Invalid Orientation $option"))
end
value_toconst(option::Enum{T}) where T = T(option)

function value_toconst(sym::Symbol)
    # descriptor values:
    sym === :default && return Int32(LibGraphBLAS.GrB_DEFAULT)
    sym === :replace && return Int32(LibGraphBLAS.GrB_REPLACE)
    sym === :complement && return Int32(LibGraphBLAS.GrB_COMP)
    sym === :structural && return Int32(LibGraphBLAS.GrB_STRUCTURE)
    sym === :complementstructural && return Int32(LibGraphBLAS.GrB_STRUCTURE + LibGraphBLAS.GrB_COMP)

    throw(ArgumentError("Invalid value $(string(sym))"))
end

function value_toconst(sparsity::AbstractSparsity)
    return shapetoconst(sparsity)
end

# returns (constant, type, readable, writeable)
option_toconst(x::Enum) = x, Int32, true, true # TODO: do better!
function option_toconst(sym::Symbol)
    # GLOBALLY AVAILABLE OPTIONS
    sym === :libmajorversion && (return LibGraphBLAS.GrB_LIBRARY_VER_MAJOR, Int32, true, false)
    sym === :libminorversion && (return LibGraphBLAS.GrB_LIBRARY_VER_MINOR, Int32, true, false)
    sym === :libpatchversion && (return LibGraphBLAS.GrB_LIBRARY_VER_PATCH, Int32, true, false)
    sym === :apimajorversion && (return LibGraphBLAS.GrB_API_VER_MAJOR, Int32, true, false)
    sym === :apiminorversion && (return LibGraphBLAS.GrB_API_VER_MINOR, Int32, true, false)
    sym === :apipatchversion && (return LibGraphBLAS.GrB_API_VER_PATCH, Int32, true, false)
    sym === :blockingmode && (return LibGraphBLAS.GrB_BLOCKING_MODE, Int32, true, false)
    sym === :usingomp && (return LibGraphBLAS.GxB_LIBRARY_OPENMP, Int32, true, false)
    # also available for matrices and vectors:
    sym === :orientation && (return LibGraphBLAS.GrB_STORAGE_ORIENTATION_HINT, Int32, true, true)

    sym === :burble && (return LibGraphBLAS.GxB_BURBLE, Int32, true, true)
    sym === :print1based && (return LibGraphBLAS.GxB_PRINT_1BASED, Int32, true, true)
    sym === :jit_c_control && (return LibGraphBLAS.GxB_JIT_C_CONTROL, Int32, true, true)
    sym === :jit_use_cmake && (return LibGraphBLAS.GxB_JIT_USE_CMAKE, Int32, true, true)
    sym === :hyperswitch && (return LibGraphBLAS.GxB_HYPER_SWITCH, Scalar{Float64}, true, true)
    sym === :bitmapswitch && (return LibGraphBLAS.GxB_BITMAP_SWITCH, Scalar{Float64}, true, true)
    sym === :hashswitch && (return LibGraphBLAS.GxB_HYPER_HASH, Int32, true, true)
    
    sym === :name && (return LibGraphBLAS.GrB_NAME, String, true, true) # write once
    sym === :jit_cname && (return LibGraphBLAS.GxB_JIT_C_NAME, String, true, true) # write once
    sym === :jit_cdef && (return LibGraphBLAS.GxB_JIT_C_DEFINITION, String, true, true) # write once

    sym === :compilername && (return LibGraphBLAS.GxB_COMPILER_NAME, String, true, false)
    sym === :jit_compilername && (return LibGraphBLAS.GxB_JIT_C_COMPILER_NAME, String, true, true)
    sym === :jit_compilerflags && (return LibGraphBLAS.GxB_JIT_C_COMPILER_FLAGS, String, true, true)
    sym === :jit_linkerflags && (return LibGraphBLAS.GxB_JIT_C_LINKER_FLAGS, String, true, true)
    sym === :jit_libraries && (return LibGraphBLAS.GxB_JIT_C_LIBRARIES, String, true, true)
    sym === :jit_cmakelibraries && (return LibGraphBLAS.GxB_JIT_C_CMAKE_LIBS, String, true, true)
    sym === :jit_errorlog && (return LibGraphBLAS.GxB_JIT_ERROR_LOG, String, true, true)
    sym === :jit_cache && (return LibGraphBLAS.GxB_JIT_CACHE_PATH, String, true, true)
    sym === :jit_cmake && (return LibGraphBLAS.GxB_JIT_CMAKE, String, true, true)

    sym === :malloc && (return LibGraphBLAS.GxB_MALLOC_FUNCTION, Ptr{Cvoid}, true, false)
    sym === :calloc && (return LibGraphBLAS.GxB_CALLOC_FUNCTION, Ptr{Cvoid}, true, false)
    sym === :free && (return LibGraphBLAS.GxB_FREE_FUNCTION, Ptr{Cvoid}, true, false)
    sym === :realloc && (return LibGraphBLAS.GxB_REALLOC_FUNCTION, Ptr{Cvoid}, true, false)

    # TYPE OPTIONS
    sym === :eltypecode && (return LibGraphBLAS.GrB_ELTYPE_CODE, Int32, true, false)
    sym === :eltypestring && (return LibGraphBLAS.GrB_ELTYPE_STRING, String, true, false)
    sym === :size && (return LibGraphBLAS.GrB_SIZE, int32_t, true, false)
    
    # OP  OPTIONS
    sym === :input1typecode && (return LibGraphBLAS.GrB_INPUT1TYPE_CODE, Int32, true, false)
    sym === :input2typecode && (return LibGraphBLAS.GrB_INPUT2TYPE_CODE, Int32, true, false)
    sym === :input1typestring && (return LibGraphBLAS.GrB_INPUT1TYPE_STRING, String, true, false)
    sym === :input2typestring && (return LibGraphBLAS.GrB_INPUT2TYPE_STRING, String, true, false)
    sym === :outputtypecode && (return LibGraphBLAS.GrB_OUTPUTTYPE_CODE, Int32, true, false)
    sym === :outputtypestring && (return LibGraphBLAS.GrB_OUTPUTTYPE_STRING, String, true, false)

    sym === :sparsitycontrol && (return LibGraphBLAS.GxB_SPARSITY_CONTROL, Int32, true, true)
    sym === :sparsitystatus && (return LibGraphBLAS.GxB_SPARSITY_STATUS, Int32, true, false)

    sym === :outp && (return LibGraphBLAS.GrB_OUTP, Int32, true, true)
    sym === :mask && (return LibGraphBLAS.GrB_MASK, Int32, true, true)
    sym === :inp0 && (return LibGraphBLAS.GrB_INP0, Int32, true, true)
    sym === :inp1 && (return LibGraphBLAS.GrB_INP1, Int32, true, true)
    
    sym === :nthreads && (return LibGraphBLAS.GxB_NTHREADS, Int32, true, true)
    sym === :chunk && (return LibGraphBLAS.GxB_CHUNK, Int32, true, true)

    throw(ArgumentError("Invalid option $(string(sym))"))
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
