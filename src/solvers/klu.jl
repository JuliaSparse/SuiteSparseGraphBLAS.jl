using KLU: KLUTypes, KLUITypes, AbstractKLUFactorization, klu_l_common, 
klu_common, _klu_name, KLUFactorization, KLUValueTypes, KLUIndexTypes,
_common, klu_factor!, klu_analyze!, klu_analyze, klu_l_analyze, kluerror, 
klu_factor, klu_l_factor, klu_numeric, klu_l_numeric, _extract!

mutable struct GB_KLUFactorization{Tv<:KLUTypes, Ti<:KLUITypes, M<:AbstractGBMatrix} <: AbstractKLUFactorization{Tv, Ti}
    common::Union{klu_l_common, klu_common}
    _symbolic::Ptr{Cvoid}
    _numeric::Ptr{Cvoid}
    n::Int
    A::M
    function GB_KLUFactorization(A::AbstractGBMatrix{Tv}) where Tv
        n = size(A, 1)
        n == size(A, 2) || throw(ArgumentError("KLU only accepts square matrices."))
        Ti = signed(LibGraphBLAS.GrB_Index)
        common = _common(Ti)
        obj = new{Tv, Ti, typeof(A)}(common, C_NULL, C_NULL, n, A)
        return finalizer(obj) do klu
            KLU._free_symbolic(klu)
            KLU._free_numeric(klu)
        end
    end
end

# getproperty overloads
function Base.getproperty(klu::GB_KLUFactorization{Tv, Ti, M}, s::Symbol) where {Tv<:KLUTypes, Ti<:KLUITypes, M}
    # Forwards to the numeric struct:
    if s ∈ [:lnz, :unz, :nzoff]
        klu._numeric == C_NULL && throw(ArgumentError("This KLUFactorization has not yet been factored. Try `klu_factor!`."))
        return getproperty(klu.numeric, s)
    end
    if s ∈ [:nblocks, :maxblock]
        klu._symbolic == C_NULL && throw(ArgumentError("This KLUFactorization has not yet been analyzed. Try `klu_analyze!`."))
        return getproperty(klu.symbolic, s)
    end
    if s === :symbolic
        klu._symbolic == C_NULL && throw(ArgumentError("This KLUFactorization has not yet been analyzed. Try `klu_analyze!`."))
        if Ti == Int64
            return unsafe_load(Ptr{klu_l_symbolic}(klu._symbolic))
        else
            return unsafe_load(Ptr{klu_symbolic}(klu._symbolic))
        end
    end
    if s === :numeric
        klu._numeric == C_NULL && throw(ArgumentError("This KLUFactorization has not yet been factored. Try `klu_factor!`."))
        if Ti == Int64
            return unsafe_load(Ptr{klu_l_numeric}(klu._numeric))
        else
            return unsafe_load(Ptr{klu_numeric}(klu._numeric))
        end
    end
    # Non-overloaded parts:
    if s ∉ [:L, :U, :F, :p, :q, :R, :Rs, :(_L), :(_U), :(_F)]
        return getfield(klu, s)
    end
    # Factor parts:
    if s === :(_L)
        lnz = klu.lnz
        Lp = unsafe_wrap(Array, _sizedjlmalloc(klu.n + 1, Ti), klu.n + 1)
        Li = unsafe_wrap(Array, _sizedjlmalloc(lnz, Ti), lnz)
        Lx = unsafe_wrap(Array, _sizedjlmalloc(lnz, Float64), lnz)
        Lz = Tv == Float64 ? C_NULL : unsafe_wrap(Array, _sizedjlmalloc(lnz, Float64), lnz)
        _extract!(klu; Lp, Li, Lx, Lz)
        return Lp, Li, Lx, Lz
    elseif s === :(_U)
        unz = klu.unz
        Up = unsafe_wrap(Array, _sizedjlmalloc(klu.n + 1, Ti), klu.n + 1)
        Ui = unsafe_wrap(Array, _sizedjlmalloc(unz, Ti), unz)
        Ux = unsafe_wrap(Array, _sizedjlmalloc(unz, Float64), unz)
        Uz = Tv == Float64 ? C_NULL : unsafe_wrap(Array, _sizedjlmalloc(unz, Float64), unz)
        _extract!(klu; Up, Ui, Ux, Uz)
        return Up, Ui, Ux, Uz
    elseif s === :(_F)
        fnz = klu.nzoff
        # We often don't have an F, so create the right vectors for an empty SparseMatrixCSC
        if fnz == 0
            return nothing
        else
            Fp = unsafe_wrap(Array, _sizedjlmalloc(klu.n + 1, Ti), klu.n + 1)
            Fi = unsafe_wrap(Array, _sizedjlmalloc(fnz, Ti), fnz)
            Fx = unsafe_wrap(Array, _sizedjlmalloc(fnz, Float64), fnz)
            Fz = Tv == Float64 ? C_NULL : unsafe_wrap(Array, _sizedjlmalloc(fnz, Float64), fnz)
            _extract!(klu; Fp, Fi, Fx, Fz)
            # F is *not* sorted on output, so we'll have to do it here:
            for i ∈ 1:(length(Fp) - 1)
                # find each segment
                first = Fp[i] + 1
                last = Fp[i+1]
                first > last && (continue)
                first == length(Fi) && (break)
                # sort each column of rowval, nzval, and Fz for complex numbers if necessary
                #by the ascending permutation of rowval.
                Fiview = view(Fi, first:last)
                Fxview = view(Fx, first:last)
                P = sortperm(Fiview)
                Fiview .= Fiview[P]
                Fxview .= Fxview[P]
                if Fz != C_NULL && length(Fz) == length(Fx)
                    Fzview = view(Fz, first:last)
                    Fzview .= Fzview[P]
                end
            end
        end
        return Fp, Fi, Fx, Fz
    end
    if s ∈ [:q, :p, :R, :Rs]
        if s === :Rs
            out = similar(klu.A, Float64, klu.n)
            out = pack!(out, unsafe_wrap(Array, _sizedjlmalloc(klu.n, Float64), klu.n); shallow = false)
        elseif s === :R
            out = similar(klu.A, Ti, klu.nblocks + 1)
            out = pack!(out, unsafe_wrap(Array, _sizedjlmalloc(klu.nblocks + 1, Ti), klu.nblocks + 1); shallow = false)
        else
            out = similar(klu.A, Ti, klu.n)
            out = pack(out, unsafe_wrap(Array, _sizedjlmalloc(klu.n, Ti), klu.n); shallow = false)
        end
        # This tuple construction feels hacky, there's a better way I'm sure.
        s === :q && (s = :Q)
        s === :p && (s = :P)
        _extract!(klu; NamedTuple{(s,)}((out,))...)
        if s ∈ [:Q, :P, :R]
            increment!(out)
        end
        return out
    end
    if s ∈ [:L, :U, :F]
        if s === :L
            p, i, x, z = klu._L
        elseif s === :U
            p, i, x, z = klu._U
        elseif s === :F
            p, i, x, z = klu._F
        end
        out = similar(klu.A, Tv, klu.n, klu.n)
        if Tv == Float64
            return pack!(out, p, i, x)
        else
            return pack!(out, p, i, Complex.(x, z))
        end
    end
end

# klu_analyze! overloads
function KLU.klu_analyze!(K::GB_KLUFactorization{Tv, Ti}) where {Tv, Ti<:KLUITypes}
    if K._symbolic != C_NULL return K end
    colptr, rowval, vals = unpack!(K.A, Sparse(); order = ColMajor(), incrementindices = false, attachfinalizer = false)
    if Ti == Int64
        sym = klu_l_analyze(K.n, colptr, rowval, Ref(K.common))
    else
        sym = klu_analyze(K.n, colptr, rowval, Ref(K.common))
    end
    pack!(K.A, colptr, rowval, vals; decrementindices = false, shallow = false, order = ColMajor())
    if sym == C_NULL
        kluerror(K.common)
    else
        K._symbolic = sym
    end
    return K
end

# TODO: P and Q should also accept GBVectors
# User provided permutation vectors:
function KLU.klu_analyze!(K::GB_KLUFactorization{Tv, Ti}, P::Vector{Ti}, Q::Vector{Ti}) where {Tv, Ti<:KLUITypes}
    if K._symbolic != C_NULL return K end
    colptr, rowval, vals = unpack!(K.A, Sparse(); order = ColMajor(), incrementindices = false, attachfinalizer = false)
    if Ti == Int64
        sym = klu_l_analyze_given(K.n, colptr, rowval, P, Q, Ref(K.common))
    else
        sym = klu_analyze_given(K.n, colptr, rowval, P, Q, Ref(K.common))
    end
    pack!(K.A, colptr, rowval, vals; decrementindices = false, shallow = false, order = ColMajor())
    if sym == C_NULL
        kluerror(K.common)
    else
        K._symbolic = sym
    end
    return K
end

for Tv ∈ KLU.KLUValueTypes, Ti ∈ KLU.KLUIndexTypes
    factor = _klu_name("factor", Tv, Ti)
    @eval begin
        function KLU.klu_factor!(K::GB_KLUFactorization{$Tv, $Ti})
            K._symbolic == C_NULL  && klu_analyze!(K)
            colptr, rowval, vals = unpack!(K.A, Sparse(); order = ColMajor(), incrementindices = false, attachfinalizer = false)
            num = $factor(colptr, rowval, vals, K._symbolic, Ref(K.common))
            pack!(K.A, colptr, rowval, vals; decrementindices = false, shallow = false, order = ColMajor())
            if num == C_NULL
                kluerror(K.common)
            else
                K._numeric = num
            end
            return K
        end
    end
end

for Tv ∈ KLUValueTypes, Ti ∈ KLUIndexTypes
    rgrowth = _klu_name("rgrowth", Tv, Ti)
    rcond = _klu_name("rcond", Tv, Ti)
    condest = _klu_name("condest", Tv, Ti)
    @eval begin
        """
            rgrowth(K::KLUFactorization)

        Calculate the reciprocal pivot growth.
        """
        function KLU.rgrowth(K::GB_KLUFactorization{$Tv, $Ti})
            K._numeric == C_NULL && klu_factor!(K)
            colptr, rowval, vals = unpack!(K.A, Sparse(); order = ColMajor(), incrementindices = false, attachfinalizer = false)
            ok = $rgrowth(K.colptr, K.rowval, K.nzval, K._symbolic, K._numeric, Ref(K.common))
            pack!(K.A, colptr, rowval, vals; decrementindices = false, shallow = false, order = ColMajor())
            if ok == 0
                kluerror(K.common)
            else
                return K.common.rgrowth
            end
        end

        """
            condest(K::KLUFactorization)

        Accurately estimate the 1-norm condition number of the factorization.
        """
        function KLU.condest(K::GB_KLUFactorization{$Tv, $Ti})
            K._numeric == C_NULL && klu_factor!(K)
            colptr, rowval, vals = unpack!(K.A, Sparse(); order = ColMajor(), incrementindices = false, attachfinalizer = false)
            ok = $condest(K.colptr, K.nzval, K._symbolic, K._numeric, Ref(K.common))
            pack!(K.A, colptr, rowval, vals; decrementindices = false, shallow = false, order = ColMajor())
            if ok == 0
                kluerror(K.common)
            else
                return K.common.condest
            end
        end
    end
end

function KLU.klu(A::AbstractGBMatrix{Tv}) where {Tv<:Union{Float64, ComplexF64}}
    K = GB_KLUFactorization(A)
    return klu_factor!(K)
end

# No refactors for now. TODO: Enable refactors!!!
# No use of GBVectors for B or X right now. TODO!!!