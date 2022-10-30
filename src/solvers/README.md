# Solvers for SuiteSparse:GraphBLAS

The solver files here are mostly temporary wrappers while a couple things 
(in no particular order and dependency) happen:

1. In a future version of Julia conditional deps come about
2. SparseArrays removal from sysimg
3. SuiteSparse solvers are separated out from each other into their own pkgs

Once those things occur this can hopefully be done more elegantly than essentially just
reimplementing all the behavior.