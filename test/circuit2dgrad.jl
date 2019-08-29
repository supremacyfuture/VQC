push!(LOAD_PATH, "..")

using VQC: qstate, qrandn, simple_gradient, distance, collect_gradients
using VQC: get_coef_sizes_2d, variational_circuit_2d
using LinearAlgebra: dot

using Zygote


"""
	circuit gradient with dot loss function
"""
function circuit2d_grad_dot_real(m::Int, n::Int, depth::Int)
	L = m * n
	target_state = qrandn(Complex{Float64}, L)
	initial_state = qstate(Complex{Float64}, L)
	x0 = randn(get_coef_sizes_2d(m, n, depth))
	circuit =  variational_circuit_2d(m, n, depth, x0)

	loss(x) = real(dot(target_state, x * initial_state))

	loss_1(x) = loss(variational_circuit_2d(m, n, depth, x))

	grad1 = simple_gradient(loss_1, x0)[1]
	grad = gradient(loss, circuit)
	return isapprox(grad1, collect_gradients(grad), atol=1.0e-4)
end

@testset "gradient of 2d quantum circuit with loss function real(dot(x, circuit*y))" begin
	for depth in 0:5
		@test circuit2d_grad_dot_real(3, 4, depth)
	end	    
end