ztype(op::LibGraphBLAS.GrB_UnaryOp) = juliatype(ptrtogbtype[LibGraphBLAS.GxB_UnaryOp_ztype(op)])
xtype(op::LibGraphBLAS.GrB_UnaryOp) = juliatype(ptrtogbtype[LibGraphBLAS.GxB_UnaryOp_xtype(op)])
Base.show(io::IO, ::MIME"text/plain", u::LibGraphBLAS.GrB_UnaryOp) = gxbprint(io, u)

xtype(op::LibGraphBLAS.GrB_BinaryOp) = juliatype(ptrtogbtype[LibGraphBLAS.GxB_BinaryOp_xtype(op)])
ytype(op::LibGraphBLAS.GrB_BinaryOp) = juliatype(ptrtogbtype[LibGraphBLAS.GxB_BinaryOp_ytype(op)])
ztype(op::LibGraphBLAS.GrB_BinaryOp) = juliatype(ptrtogbtype[LibGraphBLAS.GxB_BinaryOp_ztype(op)])
Base.show(io::IO, ::MIME"text/plain", u::LibGraphBLAS.GrB_BinaryOp) = gxbprint(io, u)


operator(monoid::LibGraphBLAS.GrB_Monoid) = LibGraphBLAS.GxB_Monoid_operator(monoid)
xtype(monoid::LibGraphBLAS.GrB_Monoid) = xtype(operator(monoid))
ytype(monoid::LibGraphBLAS.GrB_Monoid) = ytype(operator(monoid))
ztype(monoid::LibGraphBLAS.GrB_Monoid) = ztype(operator(monoid))
Base.show(io::IO, ::MIME"text/plain", m::LibGraphBLAS.GrB_Monoid) = gxbprint(io, m)

mulop(rig::LibGraphBLAS.GrB_Semiring) = LibGraphBLAS.GxB_Semiring_multiply(rig)
addop(rig::LibGraphBLAS.GrB_Semiring) = LibGraphBLAS.GxB_Semiring_add(rig)
xtype(rig::LibGraphBLAS.GrB_Semiring) = xtype(mulop(rig))
ytype(rig::LibGraphBLAS.GrB_Semiring) = ytype(mulop(rig))
ztype(rig::LibGraphBLAS.GrB_Semiring) = ztype(addop(rig))
Base.show(io::IO, ::MIME"text/plain", s::LibGraphBLAS.GrB_Semiring) = gxbprint(io, s)
