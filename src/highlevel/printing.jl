# TODO: display materialization of views
# TODO: should not display fill when dense.
# TODO: a println method for reconstruction.
function Base.show(io::IO, ::MIME"text/plain", A::EagerGBMatrix{T, F, O}) where {T, F, O}
    println(io, "EagerGBMatrix{$T, $F, $O} with fill=$(SparseBase.getfill(A)): ")
    GrB.gxbprint(io, A.A)
end

function Base.show(io::IO, ::MIME"text/plain", op::Operation)
    println(io, "Operation(C::$(typeof(op.out))<M::$(typeof(op.M))> = $(op.operation){$(op.operator)}($(op.inputs)))")
end

function _show(io::IO, A)
    if isnothing(A.A)
        if isnothing(A.op)
            println(io, "Uninitialized $(size(A, 1)) × $(size(A, 2))")
        else
            print(io, "$(size(A, 1)) × $(size(A, 2)) defined by ")
            show(io, MIME("text/plain"), A.op)
        end
    else
        GrB.gxbprint(io, A.A)
    end
end

function Base.show(io::IO, ::MIME"text/plain", A::LazyGBMatrix{T, F, O}) where {T, F, O}
    println(io, "LazyGBMatrix{$T, $F, $O} with fill=$(SparseBase.getfill(A)): ")
    _show(io, A)
end
function Base.show(io::IO, ::MIME"text/plain", A::GBMatrix{T, F, O}) where {T, F, O}
    println(io, "GBMatrix{$T, $F, $O} with fill=$(SparseBase.getfill(A)): ")
    _show(io, A)
end
