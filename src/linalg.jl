# not quite as fast as it *could* be, we have to construct the sparse representation of
# a diagonal. Which means ~triple the size of a basic Diagonal matrix.
# SSGrB doesn't have an internal representation for a Diagonal.
LinearAlgebra.:\(D::Diagonal, B::AbstractGBMatrix) = *(D, B, (any, \))