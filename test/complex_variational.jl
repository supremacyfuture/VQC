push!(LOAD_PATH, "..")

using VQC: qstate, qrandn, QCircuit, QMeasure, simple_gradient, distance, collect_gradients
using VQC: get_coef_sizes_1d, variational_circuit_1d, nparameters, parallelize, StateVector
using VQC: cgrad

using Zygote

L = 5

depth = 5

target_state = qrandn(Complex{Float64}, L)

initial_state = qstate(Complex{Float64}, L)

x0 = randn(get_coef_sizes_1d(L, depth))
circuit =  variational_circuit_1d(L, depth, x0)

# loss(m) = distance(target_state, m * initial_state)
# loss_1(x) = loss(variational_circuit_1d(L, depth, x))

# println("number of parameters $(length(x0))")

# grad1 = simple_gradient(loss_1, x0, dt=0.00001)
# @time grad1 = simple_gradient(loss_1, x0, dt=0.00001)
# println(grad1)


# grad = gradient(loss, circuit)

# @time grad = gradient(loss, circuit)
# println(grad)


# pcircuit = parallelize(circuit)
# grad = gradient(loss, pcircuit)
# @time grad = gradient(loss, pcircuit)
# println(grad)

loss(x) = distance(target_state, circuit * x)
loss_1(x) = loss(StateVector(x))

println("number of parameters $(length(initial_state))")

s_0 = initial_state.data

grad1 = simple_gradient(loss_1, s_0)
@time grad1 = simple_gradient(loss_1, s_0)
println(collect_gradients(grad1))


grad = gradient(loss, initial_state)

@time grad = gradient(loss, initial_state)
println(collect_gradients(grad))

pcircuit = parallelize(circuit)

loss_2(x) = distance(target_state, pcircuit * x)

grad = gradient(loss_2, initial_state)
@time grad = gradient(loss_2, initial_state)
println(collect_gradients(grad))

println(collect_gradients(grad) - collect_gradients(grad1))



