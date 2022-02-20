ztype(op::libgb.GrB_UnaryOp) = juliatype(ptrtogbtype[libgb.GxB_UnaryOp_ztype(op)])
xtype(op::libgb.GrB_UnaryOp) = juliatype(ptrtogbtype[libgb.GxB_UnaryOp_xtype(op)])
Base.show(io::IO, ::MIME"text/plain", u::libgb.GrB_UnaryOp) = gxbprint(io, u)

xtype(op::libgb.GrB_BinaryOp) = juliatype(ptrtogbtype[libgb.GxB_BinaryOp_xtype(op)])
ytype(op::libgb.GrB_BinaryOp) = juliatype(ptrtogbtype[libgb.GxB_BinaryOp_ytype(op)])
ztype(op::libgb.GrB_BinaryOp) = juliatype(ptrtogbtype[libgb.GxB_BinaryOp_ztype(op)])
Base.show(io::IO, ::MIME"text/plain", u::libgb.GrB_BinaryOp) = gxbprint(io, u)


operator(monoid::libgb.GrB_Monoid) = libgb.GxB_Monoid_operator(monoid)
xtype(monoid::libgb.GrB_Monoid) = xtype(operator(monoid))
ytype(monoid::libgb.GrB_Monoid) = ytype(operator(monoid))
ztype(monoid::libgb.GrB_Monoid) = ztype(operator(monoid))
Base.show(io::IO, ::MIME"text/plain", m::libgb.GrB_Monoid) = gxbprint(io, m)

mulop(rig::libgb.GrB_Semiring) = libgb.GxB_Semiring_multiply(rig)
addop(rig::libgb.GrB_Semiring) = libgb.GxB_Semiring_add(rig)
xtype(rig::libgb.GrB_Semiring) = xtype(mulop(rig))
ytype(rig::libgb.GrB_Semiring) = ytype(mulop(rig))
ztype(rig::libgb.GrB_Semiring) = ztype(addop(rig))
Base.show(io::IO, ::MIME"text/plain", s::libgb.GrB_Semiring) = gxbprint(io, s)
