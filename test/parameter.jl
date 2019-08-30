push!(LOAD_PATH, "..")

using VQC: nparameters, parameters, set_parameters!, QCircuit, Variable
using VQC: RxGate, HGate, CNOTGate, add!, parallelize


function test_parameter(L::Int, depth::Int)
	circuit = QCircuit()
	counts = 0
	vars = []
	for i in 1:L
	    add!(circuit, HGate(i))
	end
	for i in 1:L
		parameter = randn(Float64)
		# variable indicate a parameter
	    add!(circuit, RxGate(i, Variable(parameter)))
	    counts += 1
	    push!(vars, parameter)
	    # this is not a parameter
	    add!(circuit, RxGate(i, parameter + 1))
	end
	for d in 1:depth
		for i in 1:(L-1)
	    	add!(circuit, CNOTGate((i, i+1)))
		end
		for i in 1:L
			parameter = randn(Float64)
			# variable indicate a parameter
	    	add!(circuit, RxGate(i, Variable(parameter)))
	    	counts += 1
	    	push!(vars, parameter)
	    	# this is not a parameter
	    	add!(circuit, RxGate(i, parameter + 1))
		end    
	end
	check1 = (nparameters(circuit) == counts)
	check2 = (parameters(circuit) == vars)

	new_vars = randn(Float64, size(vars)...)
	set_parameters!(new_vars, circuit)
	check3 = (nparameters(circuit) == counts)
	check4 = (parameters(circuit) == new_vars)

	return check1 && check2 && check3 && check4
end

function test_parallelized_parameter(L::Int, depth::Int)
	circuit = QCircuit()
	counts = 0
	vars = []
	for i in 1:L
	    add!(circuit, HGate(i))
	end
	for i in 1:L
		parameter = randn(Float64)
		# variable indicate a parameter
	    add!(circuit, RxGate(i, Variable(parameter)))
	    counts += 1
	    push!(vars, parameter)
	    # this is not a parameter
	    add!(circuit, RxGate(i, parameter + 1))
	end
	for d in 1:depth
		for i in 1:(L-1)
	    	add!(circuit, CNOTGate((i, i+1)))
		end
		for i in 1:L
			parameter = randn(Float64)
			# variable indicate a parameter
	    	add!(circuit, RxGate(i, Variable(parameter)))
	    	counts += 1
	    	push!(vars, parameter)
	    	# this is not a parameter
	    	add!(circuit, RxGate(i, parameter + 1))
		end    
	end

	circuit = parallelize(circuit)

	check1 = (nparameters(circuit) == counts)
	check2 = (parameters(circuit) == vars)

	new_vars = randn(Float64, size(vars)...)
	set_parameters!(new_vars, circuit)
	check3 = (nparameters(circuit) == counts)
	check4 = (parameters(circuit) == new_vars)

	return check1 && check2 && check3 && check4
end

@testset "set the parameters of quantum circuit" begin
	for L in 2:10
		for depth in 0:7
		    @test test_parameter(L, depth)
		end	    
	end
end

@testset "set the parameters of blocked quantum circuit" begin
	for L in 2:10
		for depth in 0:7
		    @test test_parallelized_parameter(L, depth)
		end	    
	end
end


