# export ComplexGradient

# struct ComplexGradient{M} 
# 	grad::M
# end

# grad(x::ComplexGradient) = x.grad
# cgrad(x::ComplexGradient) = conj(x.grad)

# scalar_type(x::ComplexGradient{M}) where M = scalar_type(M)
# scalar_type(::Type{ComplexGradient{M}}) where M = scalar_type(M)


# +(x::ComplexGradient, y::ComplexGradient) = ComplexGradient(grad(x) + grad(y))
# -(x::ComplexGradient, y::ComplexGradient) = ComplexGradient(grad(x) - grad(y))
# +(x::ComplexGradient) = x
# -(x::ComplexGradient) = ComplexGradient(-grad(x))
# *(x::ComplexGradient, y) = ComplexGradient(grad(x) * y)

# *(y, x::ComplexGradient) = ComplexGradient(y * grad(x))
# Base.conj(x::ComplexGradient) = ComplexGradient(cgrad(x))


# @adjoint Base.real(x::Complex) = begin
#     return real(x), z-> begin
#         return (ComplexGradient(0.5*z),)
#     end 
# end 

# @adjoint Base.imag(x::Complex) = imag(x), z -> (ComplexGradient(-0.5im*z),)

# @adjoint Base.conj(x::Complex) = begin
#     conj(x), z->(conj(z),)
# end 



# one need to change the behavior for functions accept complex number but return real number
# to make sure to get right right in the complex case
@adjoint Base.real(x::Complex) = real(x), z -> (0.5*z,)
@adjoint Base.imag(x::Complex) = imag(x), z -> (-0.5*im*z,)

@adjoint Base.abs2(x::Complex) = begin
    r = abs2(x)
    return r, z -> (z * conj(x), )
end

@adjoint Base.abs(x::Complex) = begin
    r = abs(x)
    return r, z -> (z * (0.5/r) * conj(x),)
end