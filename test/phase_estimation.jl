push!(LOAD_PATH, "..")

using VQC: qstate, QCircuit, QMeasure
using VQC: add!, H, CONTROL, extend!, QFT, CNOT
# using VQC: qvalues

function to_digits(s::Vector{Int})
	r = 0.
	for i = 1:length(s)
		r = r + s[i]*(2.)^(-i)
	end
	return r
end

function phase_estimate_circuit(j::Vector{Int})
	L = length(j)
	circuit = QCircuit()
	phi = to_digits(j)
	U = [exp(2*pi*im*phi) 0; 0. 1.]
	for i = 1:L
		add!(circuit, (i, H))
	end

	tmp = U
	for i = L:-1:1
		add!(circuit, ((i, L+1), CONTROL(tmp)))
		tmp = tmp * tmp
	end
	extend!(circuit, QFT(L)')
	return circuit
end

# println(CNOT)

L = 15

j = rand(0:1, L)
# j = [0, 1]

state = qstate(L+1)

phi = to_digits(j)

println("the target phase $j, $(to_digits(j))")

circuit = phase_estimate_circuit(j)

# println(circuit)

println("number of gates $(length(circuit))")

for i = 1:(L+1)
	add!(circuit, QMeasure(i, auto_reset=false))
end

results = circuit * state

r = [item[2] for item in results]

println(r)

phi_out = to_digits(r)
println("$phi, $phi_out, $(abs(phi_out-phi)/phi).\n")
println(j[1:L] == r[1:L])
