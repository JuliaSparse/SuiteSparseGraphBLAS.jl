@enum GrB_Info begin
    GrB_SUCCESS = 0                 # all is well
    GrB_NO_VALUE = 1                # A(ij) requested but not there
    
    # In non-blocking mode these errors are caught right away.

    GrB_UNINITIALIZED_OBJECT = 2    # object has not been initialized
    GrB_INVALID_OBJECT = 3          # object is corrupted
    GrB_NULL_POINTER = 4            # input pointer is NULL
    GrB_INVALID_VALUE = 5           # generic error code; some value is bad
    GrB_INVALID_INDEX = 6           # a row or column index is out of bounds;
                                    # used for indices passed as scalars not
                                    # in a list.
    GrB_DOMAIN_MISMATCH = 7         # object domains are not compatible
    GrB_DIMENSION_MISMATCH = 8      # matrix dimensions do not match
    GrB_OUTPUT_NOT_EMPTY = 9        # output matrix already has values in it

    # In non-blocking mode these errors can be deferred.

    GrB_OUT_OF_MEMORY = 10          # out of memory
    GrB_INSUFFICIENT_SPACE = 11     # output array not large enough
    GrB_INDEX_OUT_OF_BOUNDS = 12    # a row or column index is out of bounds
    GrB_PANIC = 13                  # SuiteSparse:GraphBLAS only panics if a critical section fails
end

@enum GrB_Mode begin
    GrB_NONBLOCKING = 0             # methods may return with pending computations
    GrB_BLOCKING = 1                # no computations are ever left pending
end

@enum GxB_Print_Level begin
    GxB_SILENT = 0                  # nothing is printed just check the object
    GxB_SUMMARY = 1                 # print a terse summary
    GxB_SHORT = 2                   # short description about 30 entries of a matrix
    GxB_COMPLETE = 3                # print the entire contents of the object
end

@enum GrB_Desc_Field begin
    GrB_OUTP = 0                    # descriptor for output of a method
    GrB_MASK = 1                    # descriptor for the mask input of a method
    GrB_INP0 = 2                    # descriptor for the first input of a method
    GrB_INP1 = 3                    # descriptor for the second input of a method
end

@enum GrB_Desc_Value begin
    # for all GrB_Descriptor fields:
    GxB_DEFAULT = 0                 # default behavior of the method
    # for GrB_OUTP only:
    GrB_REPLACE = 1                 # clear the output before assigning new values to it
    # for GrB_MASK only:
    GrB_SCMP = 2                    # use the structural complement of the input
    # for GrB_INP0 and GrB_INP1 only:
    GrB_TRAN = 3                    # use the transpose of the input
end
