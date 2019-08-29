push!(LOAD_PATH, "..")


using VQC: qstate, QCircuit, QMeasure
using VQC: add!, H, CONTROL, extend!, QFT, apply!, qvalues


function simple_phase_estimation(L::Int, auto_reset::Bool=false)
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

	j = rand(0:1, L)
	state = qstate(L+1)
	phi = to_digits(j)
	circuit = phase_estimate_circuit(j)
	for i = 1:(L+1)
		add!(circuit, QMeasure(i, auto_reset=auto_reset))
	end
	results = apply!(circuit, state)
	res = qvalues(results)
	phi_out = to_digits(res)
	return (phi == phi_out) && (j[1:L] == res[1:L])
end

@testset "simple phase estimation" begin
    for L in 2:15
        @test simple_phase_estimation(L, false)
        @test simple_phase_estimation(L, true)
    end
end