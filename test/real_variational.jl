push!(LOAD_PATH, "..")

using VQC: qstate, qrandn, QCircuit, QMeasure, naive_real_gradient, distance, vdot
using VQC: get_real_coef_sizes_1d, real_variational_circuit_1d, nparameters, parallelize

using Zygote

L = 15

depth = 15

target_state = qrandn(Float64, L)

initial_state = qstate(Float64, L)

x0 = randn(get_real_coef_sizes_1d(L, depth))
circuit =  real_variational_circuit_1d(L, depth, x0)

loss(m) = distance(target_state, m * initial_state)
loss_1(x) = loss(real_variational_circuit_1d(L, depth, x))

println("number of parameters $(length(x0))")

grad1 = naive_real_gradient(loss_1, x0, dt=0.00001)
@time grad1 = naive_real_gradient(loss_1, x0, dt=0.00001)
println(grad1)


grad = gradient(loss, circuit)

@time grad = gradient(loss, circuit)
println(grad)


pcircuit = parallelize(circuit)
grad = gradient(loss, pcircuit)
@time grad = gradient(loss, pcircuit)
println(grad)




