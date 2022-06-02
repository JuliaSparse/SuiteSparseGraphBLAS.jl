function getproperty(klu::KLUFactorization{Tv, Ti, M}, s::Symbol) where {Tv<:KLUTypes, Ti<:KLUITypes, M}
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
        Lp = Vector{Ti}(undef, klu.n + 1)
        Li = Vector{Ti}(undef, lnz)
        Lx = Vector{Float64}(undef, lnz)
        Lz = Tv == Float64 ? C_NULL : Vector{Float64}(undef, lnz)
        _extract!(klu; Lp, Li, Lx, Lz)
        return Lp, Li, Lx, Lz
    elseif s === :(_U)
        unz = klu.unz
        Up = Vector{Ti}(undef, klu.n + 1)
        Ui = Vector{Ti}(undef, unz)
        Ux = Vector{Float64}(undef, unz)
        Uz = Tv == Float64 ? C_NULL : Vector{Float64}(undef, unz)
        _extract!(klu; Up, Ui, Ux, Uz)
        return Up, Ui, Ux, Uz
    elseif s === :(_F)
        fnz = klu.nzoff
        # We often don't have an F, so create the right vectors for an empty SparseMatrixCSC
        if fnz == 0
            Fp = zeros(Ti, klu.n + 1)
            Fi = Vector{Ti}()
            Fx = Vector{Float64}()
            Fz = Tv == Float64 ? C_NULL : Vector{Float64}()
        else
            Fp = Vector{Ti}(undef, klu.n + 1)
            Fi = Vector{Ti}(undef, fnz)
            Fx = Vector{Float64}(undef, fnz)
            Fz = Tv == Float64 ? C_NULL : Vector{Float64}(undef, fnz)
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
            out = Vector{Float64}(undef, klu.n)
        elseif s === :R
            out = Vector{Ti}(undef, klu.nblocks + 1)
        else
            out = Vector{Ti}(undef, klu.n)
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
        if Tv == Float64
            return SparseMatrixCSC(M, klu.n, klu.n, (p), (i), x)
        else
            return SparseMatrixCSC(M, klu.n, klu.n, (p), (i), Complex.(x, z))
        end
    end
end