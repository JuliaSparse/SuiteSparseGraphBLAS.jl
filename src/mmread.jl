# mmread adapted from MatrixMarket.jl
# Copyright (c) 2013: Viral B. Shah.
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

_parseint(x) = parse(Int, x)

function find_splits(s::String, num)
    splits = Vector{Int}(undef, num)
    cur = 1
    in_space = s[1] == '\t' || s[1] == ' '
    @inbounds for i in 1:length(s)
        if s[i] == '\t' || s[i] == ' '
            if !in_space
                in_space = true
                splits[cur] = i
                cur += 1
                cur > num && break
            end
        else
            in_space = false
        end
    end

    splits
end

# Hack to represent skew-symmetric matrix as an ordinary matrix with duplicated elements
function skewsymmetric!(M::AbstractMatrix)
    m,n = size(M)
    m == n || throw(DimensionMismatch())
    return M .- transpose(tril(M, -1))
end

function symmetric!(M::AbstractMatrix)
    m,n = size(M)
    m == n || throw(DimensionMismatch())
    if eltype(M) == Bool
        return M .| transpose(tril(M, -1))
    else
        return M .+ transpose(tril(M, -1))
    end
end

function hermitian!(M::AbstractMatrix)
    m,n = size(M)
    m == n || throw(DimensionMismatch())
    if eltype(M) == Bool
        return M .| conj(transpose(tril(M, -1)))
    else
        return M .+ conj(transpose(tril(M, -1)))
    end
end


function mmread(filename, infoonly::Bool=false, retcoord::Bool=false)
    open(filename,"r") do mmfile
        # Read first line
        firstline = chomp(readline(mmfile))
        tokens = split(firstline)
        if length(tokens) != 5
            throw(ArgumentError(string("Not enough words on first line: ", firstline)))
        end
        if tokens[1] != "%%MatrixMarket"
            throw(ArgumentError(string("Expected start of header `%%MatrixMarket`, got `$(tokens[1])`")))
        end
        (head1, rep, field, symm) = map(lowercase, tokens[2:5])
        if head1 != "matrix"
            throw(ArgumentError("Unknown MatrixMarket data type: $head1 (only \"matrix\" is supported)"))
        end

        eltype = field == "real" ? Float64 :
                 field == "complex" ? ComplexF64 :
                 field == "integer" ? Int64 :
                 field == "pattern" ? Bool :
                 throw(ArgumentError("Unsupported field $field (only real and complex are supported)"))

        symlabel = symm == "general" ? identity :
                   symm == "symmetric" ? symmetric! :
                   symm == "hermitian" ? hermitian! :
                   symm == "skew-symmetric" ? skewsymmetric! :
                   throw(ArgumentError("Unknown matrix symmetry: $symm (only general, symmetric, skew-symmetric and hermitian are supported)"))

        # Skip all comments and empty lines
        ll   = readline(mmfile)
        while length(chomp(ll))==0 || (length(ll) > 0 && ll[1] == '%')
            ll = readline(mmfile)
        end
        # Read matrix dimensions (and number of entries) from first non-comment line
        dd = map(_parseint, split(ll))
        if length(dd) < (rep == "coordinate" ? 3 : 2)
            throw(ArgumentError(string("Could not read in matrix dimensions from line: ", ll)))
        end
        rows = dd[1]
        cols = dd[2]
        entries = (rep == "coordinate") ? dd[3] : (rows * cols)
        infoonly && return (rows, cols, entries, rep, field, symm)

        rep == "coordinate" ||
            return GBMatrix(symlabel(reshape([parse(Float64, readline(mmfile)) for i in 1:entries],
                                    (rows,cols))))

        rr = Vector{Int}(undef, entries)
        cc = Vector{Int}(undef, entries)
        xx = Vector{eltype}(undef, entries)
        for i in 1:entries
            line = readline(mmfile)
            splits = find_splits(line, eltype == ComplexF64 ? 3 : (eltype == Bool ? 1 : 2))
            rr[i] = _parseint(line[1:splits[1]])
            cc[i] = _parseint(eltype == Bool
                              ? line[splits[1]:end]
                              : line[splits[1]:splits[2]])
            if eltype == ComplexF64
                real = parse(Float64, line[splits[2]:splits[3]])
                imag = parse(Float64, line[splits[3]:length(line)])
                xx[i] = ComplexF64(real, imag)
            elseif eltype == Bool
                xx[i] = true
            else
                xx[i] = parse(eltype, line[splits[2]:length(line)])
            end
        end
        (retcoord
         ? (rr, cc, xx, rows, cols, entries, rep, field, symm)
         : symlabel(GBMatrix(rr, cc, xx, rows, cols)))
    end
end