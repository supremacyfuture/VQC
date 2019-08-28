export vdot, distance, expectation

vdot(x::StateVector{A}, y::StateVector{B}) where {A, B} = begin
	(length(x)==length(y)) || error("quantum state size mismatch.")
    r = zero(promote_type(A, B))
    for i in 1:length(x)
        r += x[i] * y[i]
    end
    return r
end

@adjoint vdot(x::StateVector, y::StateVector) = vdot(x, y), z -> (y * z, x * z)

Base.conj(x::StateVector) = begin
    xd = data(x)
    return StateVector(conj(xd))
end

@adjoint Base.conj(x::StateVector) = conj(x), z -> (conj(z),)

dot(x::StateVector, y::StateVector) = vdot(conj(x), y)


# @adjoint *(circuit::AbstractCircuit, state::StateVector) = circuit * state, z->begin
#     circuits = differentiate(circuit)
#     return [vdot(z, s * state) for s in circuits], z * circuit
# end

@adjoint *(circuit::AbstractCircuit, state::StateVector) = begin
    r = circuit * state
    circuits = differentiate(circuit)
    tmp(z::StateVector) = [vdot(z, s * state) for s in circuits], z * circuit
    return r, z -> begin
        if !isa(z, ComplexGradient)
            return tmp(z)
        else
            dx, dy = tmp(grad(z))
            # cdx = nothing
            # cdy = nothing
            # if cgrad(z) !== nothing
            #     cdx, cdy = tmp(conj(cgrad(z)))
            #     cdx = conj(cdx)
            #     cdy = conj(cdy)
            # end
            # return [real(a+b) for (a, b) in zip(dx, cdx)], ComplexGradient(dy, cdy)
            return [2*real(a) for a in dx], ComplexGradient(dy)
        end
    end
end 

function distance(x::StateVector, y::StateVector)
    sA = dot(x, x)
    sB = dot(y, y)
    c = dot(x, y)
    r = real(sA+sB-2*c)
    # println("$sA, $sB, $c")
    (r >= 0) || error("distance $r is negative.")
    return sqrt(r)
end 

expectation(a::StateVector, circuit::AbstractCircuit, b::StateVector) = dot(a, circuit * b)