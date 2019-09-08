using VQC
using Zygote

using LinearAlgebra: dot


"""
	circuit gradient with dot loss function
"""
function qstate_grad_dot_real(L::Int)
	x = randn(L)
	target_state = qrandn(Complex{Float64}, L)

	loss(s) = real(dot(target_state, qstate(s)))
	grad1 = simple_gradient(loss, x)[1]
	grad = gradient(loss, x)
	return isapprox(grad1, collect_gradients(grad), atol=1.0e-4)
end

@testset "gradient of qstate with loss function real(dot(x, qstate(y)))" begin
	for L in 2:13
		@test qstate_grad_dot_real(L)
	end
end