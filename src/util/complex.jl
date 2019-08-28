export ComplexGradient

struct ComplexGradient{M} 
	grad::M
end

grad(x::ComplexGradient) = x.grad
cgrad(x::ComplexGradient) = conj(x.grad)

scalar_type(x::ComplexGradient{M}) where M = scalar_type(M)
scalar_type(::Type{ComplexGradient{M}}) where M = scalar_type(M)


+(x::ComplexGradient, y::ComplexGradient) = ComplexGradient(grad(x) + grad(y))
-(x::ComplexGradient, y::ComplexGradient) = ComplexGradient(grad(x) - grad(y))
+(x::ComplexGradient) = x
-(x::ComplexGradient) = ComplexGradient(-grad(x))
*(x::ComplexGradient, y) = ComplexGradient(grad(x) * y)

*(y, x::ComplexGradient) = ComplexGradient(y * grad(x))
Base.conj(x::ComplexGradient) = ComplexGradient(cgrad(x))


@adjoint Base.real(x::Complex) = begin
    return real(x), z-> begin
        return (ComplexGradient(0.5*z),)
    end 
end 

@adjoint Base.imag(x::Complex) = imag(x), z -> (ComplexGradient(-0.5im*z),)

@adjoint Base.conj(x::Complex) = begin
	# println("using custom conj....")
    conj(x), z->(conj(z),)
end 



