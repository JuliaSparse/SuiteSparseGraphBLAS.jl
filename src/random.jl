#TODO:
# This is actually kind of hard. sprand works best for now, but it has problems:
# 1. It involves creating a SparseMatrixCSC -> GBMatrix which is slowish
# 2. It doesn't support the elements from a collection like 1:10.
# 3. It only supports a proportion rather than nvals, boon or bane I'm not sure.
