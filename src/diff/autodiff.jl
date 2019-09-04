@adjoint vdot(x::StateVector, y::StateVector) = vdot(x, y), z -> (y * z, x * z)

# Base.conj(x::StateVector) = begin
#     xd = data(x)
#     return StateVector(conj(xd))
# end

# @adjoint Base.conj(x::StateVector) = conj(x), z -> (conj(z),)

@adjoint StateVector(x::Vector) = StateVector(x), z -> (data(z),)
@adjoint data(x::StateVector) = data(x), z->(StateVector(z),)


# @adjoint *(circuit::AbstractCircuit, state::StateVector) = circuit * state, z->begin
#     circuits = differentiate(circuit)
#     return [vdot(z, s * state) for s in circuits], z * circuit
# end

_get_real(s::Real) = s
_get_real(s::Complex) = 2 * real(s)

_get_real(s::AbstractVector) = [_get_real(item) for item in s]

@adjoint *(circuit::AbstractCircuit, state::StateVector) = begin
    r = circuit * state
    circuits = differentiate(circuit)
    # tmp(z::StateVector) = [vdot(z, s * state) for s in circuits], z * circuit
    # return r, z -> begin
    #     if !isa(z, ComplexGradient)
    #         return tmp(z)
    #     else
    #         dx, dy = tmp(grad(z))
    #         # cdx = nothing
    #         # cdy = nothing
    #         # if cgrad(z) !== nothing
    #         #     cdx, cdy = tmp(conj(cgrad(z)))
    #         #     cdx = conj(cdx)
    #         #     cdy = conj(cdy)
    #         # end
    #         # return [real(a+b) for (a, b) in zip(dx, cdx)], ComplexGradient(dy, cdy)
    #         return [2*real(a) for a in dx], ComplexGradient(dy)
    #     end
    # end
    return r, z -> (_get_real([vdot(z, s * state) for s in circuits]), z * circuit)
end 

# @adjoint *(circuit::AbstractCircuit, state::StateVector) = begin
#     r = circuit * state
#     circuits = differentiate(circuit)
#     return r, z -> begin
#         a = [vdot(z, s * state) for s in circuits]
#         println(a)
#         return (_get_real(a), z * circuit)
#     end 
# end 