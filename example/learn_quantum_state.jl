push!(LOAD_PATH, "..")

using VQC: qstate, qrandn, distance, collect_gradients
using VQC: variational_circuit_1d, nparameters, parameters, reset_parameters!

using Zygote
using Flux.Optimise



L = 5

target_state = qrandn(Complex{Float64}, L)

initial_state = qstate(Complex{Float64}, L)

loss(x) = distance(target_state, x * initial_state)

function train(depth::Int)
	circuit = variational_circuit_1d(L, depth)
	println("number of parameters $(nparameters(circuit))")
    println("initial loss is $(loss(circuit))")

    opt = ADAM()

    for i in 1:10000
        grad = collect_gradients(gradient(loss, circuit))
        paras = parameters(circuit)
        Optimise.update!(opt, paras, grad)
        reset_parameters!(paras, circuit)
        println("loss of step $i is $(loss(circuit))")
    end

end

train(5)