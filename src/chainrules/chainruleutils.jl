import LinearAlgebra
import ChainRulesCore: frule, rrule
using ChainRulesCore
const RealOrComplex = Union{Real, Complex}

# LinearAlgebra.norm doesn't like the nothings.
LinearAlgebra.norm(A::GBVecOrMat, p::Real=2) = norm(nonzeros(A), p)
ChainRulesCore.ProjectTo(x::GBArrayOrTranspose{T}) where T = 
ProjectTo{AbstractArray}(; element=ChainRulesCore._eltype_projectto(T), axes=axes(x))
function (project::ProjectTo{AbstractArray})(dx::GBArrayOrTranspose{S}) where {S}
    # First deal with shape. The rule is that we reshape to add or remove trivial dimensions
    # like dx = ones(4,1), where x = ones(4), but throw an error on dx = ones(1,4) etc.
    dy = if axes(dx) === project.axes
        dx
    else
        for d in 1:max(M, length(project.axes))
            if size(dx, d) != length(get(project.axes, d, 1))
                throw(ChainRulesCore._projection_mismatch(project.axes, size(dx)))
            end
        end
        reshape(dx, project.axes)
    end
    # Then deal with the elements. One projector if AbstractArray{<:Number},
    # or one per element for arrays of anything else, including arrays of arrays:
    dz = if hasproperty(project, :element)
        T = ChainRulesCore.project_type(project.element)
        S <: T ? dy : map(project.element, dy)
    else
        map((f, y) -> f(y), project.elements, dy)
    end
    return dz
end
