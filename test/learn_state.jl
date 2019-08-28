push!(LOAD_PATH, "..")

using VQC: qstate, qrandn, QCircuit, QMeasure, naive_real_gradient, collect_gradients
using VQC: get_real_coef_sizes_1d, real_variational_circuit_1d, nparameters, distance
using VQC: reset_parameters!

using Zygote

using Flux.Optimise

L = 5

depth = 5

target_state = qrandn(Float64, L)

initial_state = qstate(Float64, L)


loss(m) = distance(target_state, m * initial_state)
loss_1(x) = loss(real_variational_circuit_1d(L, depth, x))


function train()	
    x0 = randn(get_real_coef_sizes_1d(L, depth))
    circuit =  real_variational_circuit_1d(L, depth, x0)

    println("number of parameters $(nparameters(circuit))")

    println("initial loss is $(loss(circuit))")
    opt = ADAM()
    paras = copy(x0) 

	for i in 1:10000
		grad = gradient(loss, circuit)[1]
        grad = collect_gradients(grad)
        Optimise.update!(opt, paras, grad)
        reset_parameters!(circuit, paras)
    	println("loss is $(loss(circuit)) in the $i-th iteration")
	end
end

train()