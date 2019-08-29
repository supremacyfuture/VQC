push!(LOAD_PATH, "..")

using VQC: qstate, qrandn, simple_gradient, distance, collect_gradients
using VQC: get_coef_sizes_1d, variational_circuit_1d
using LinearAlgebra: dot

using Zygote


"""
	circuit gradient with dot loss function
"""
function circuit_grad_dot_real(L::Int, depth::Int)
	target_state = qrandn(Complex{Float64}, L)
	initial_state = qstate(Complex{Float64}, L)
	x0 = randn(get_coef_sizes_1d(L, depth))
	circuit =  variational_circuit_1d(L, depth, x0)

	loss(x) = real(dot(target_state, x * initial_state))

	loss_1(x) = loss(variational_circuit_1d(L, depth, x))

	grad1 = simple_gradient(loss_1, x0)[1]
	grad = gradient(loss, circuit)
	return isapprox(grad1, collect_gradients(grad), atol=1.0e-4)
end


"""
	circuit gradient with dot loss function
"""
function circuit_grad_dot_imag(L::Int, depth::Int)
	target_state = qrandn(Complex{Float64}, L)
	initial_state = qstate(Complex{Float64}, L)
	x0 = randn(get_coef_sizes_1d(L, depth))
	circuit =  variational_circuit_1d(L, depth, x0)

	loss(x) = imag(dot(target_state, x * initial_state))

	loss_1(x) = loss(variational_circuit_1d(L, depth, x))

	grad1 = simple_gradient(loss_1, x0)[1]
	grad = gradient(loss, circuit)
	return isapprox(grad1, collect_gradients(grad), atol=1.0e-4)
end

"""
	circuit gradient with dot loss function
"""
function circuit_grad_dot_abs(L::Int, depth::Int)
	target_state = qrandn(Complex{Float64}, L)
	initial_state = qstate(Complex{Float64}, L)
	x0 = randn(get_coef_sizes_1d(L, depth))
	circuit =  variational_circuit_1d(L, depth, x0)

	loss(x) = abs(dot(target_state, x * initial_state))

	loss_1(x) = loss(variational_circuit_1d(L, depth, x))

	grad1 = simple_gradient(loss_1, x0)[1]
	grad = gradient(loss, circuit)

	return isapprox(grad1, collect_gradients(grad), atol=1.0e-4)
end

"""
	circuit gradient with dot loss function
"""
function circuit_grad_dot_abs2(L::Int, depth::Int)
	target_state = qrandn(Complex{Float64}, L)
	initial_state = qstate(Complex{Float64}, L)
	x0 = randn(get_coef_sizes_1d(L, depth))
	circuit =  variational_circuit_1d(L, depth, x0)

	loss(x) = abs2(dot(target_state, x * initial_state))

	loss_1(x) = loss(variational_circuit_1d(L, depth, x))

	grad1 = simple_gradient(loss_1, x0)[1]
	grad = gradient(loss, circuit)
	return isapprox(grad1, collect_gradients(grad), atol=1.0e-4)
end


"""
	circuit gradient with distance loss function
"""
function circuit_grad_distance(L::Int, depth::Int)
	target_state = qrandn(Complex{Float64}, L)
	initial_state = qstate(Complex{Float64}, L)
	x0 = randn(get_coef_sizes_1d(L, depth))
	circuit =  variational_circuit_1d(L, depth, x0)

	loss(x) = distance(target_state, x * initial_state)

	loss_1(x) = loss(variational_circuit_1d(L, depth, x))

	# println("number of parameters $(length(initial_state))")

	grad1 = simple_gradient(loss_1, x0)[1]
	grad = gradient(loss, circuit)
	return isapprox(grad1, collect_gradients(grad), atol=1.0e-4)
end


@testset "gradient of quantum circuit with loss function real(dot(x, circuit*y))" begin
	for L in 2:5
		for depth in 0:5
		    @test circuit_grad_dot_real(L, depth)
		end	    
	end
end

@testset "gradient of quantum circuit with loss function imag(dot(x, circuit*y))" begin
	for L in 2:5
		for depth in 0:5
		    @test circuit_grad_dot_imag(L, depth)
		end	    
	end
end

@testset "gradient of quantum circuit with loss function abs(dot(x, circuit*y))" begin
	for L in 2:5
		for depth in 0:5
		    @test circuit_grad_dot_abs(L, depth)
		end	    
	end
end


@testset "gradient of quantum circuit with loss function abs2(dot(x, circuit*y))" begin
	for L in 2:5
		for depth in 0:5
		    @test circuit_grad_dot_abs2(L, depth)
		end	    
	end
end


@testset "gradient of quantum circuit with loss function distance(x, circuit*y)" begin
	for L in 2:5
		for depth in 0:5
		    @test circuit_grad_distance(L, depth)
		end	    
	end
end
