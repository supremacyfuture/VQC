export get_coef_sizes_1d, variational_circuit_1d, get_coef_sizes_2d, variational_circuit_2d

function toOneDIndex(idx::Tuple{Int, Int}, shape::Tuple{Int, Int}, major::Char='C')
	(major in ['R', 'C']) || error("major must be R or C.")
	i, j = idx
	(i<=shape[1] && j<=shape[2]) || error("index out of range.")
	if major == 'R'
		return (i-1)*shape[2] + j
	else
		return (j-1)*shape[1] + i
	end
end


function get_coef_sizes_1d(L::Int, depth::Int)
	hcount = L * (depth+1) 
	return hcount
end

function variational_circuit_1d(L::Int, depth::Int, coeff::Vector{<:Real})
	(length(coeff) == get_coef_sizes_1d(L, depth)) || error("coeff length error")
	circuit = QCircuit()
	hcount = 1
	for i in 1:L
		add!(circuit, RxGate(i, Variable(coeff[hcount])))
		hcount += 1
	end
	for i in 1:depth
		for j in 1:(L-1)
		    add!(circuit, CNOTGate((j, j+1)))
		end
		for j in 1:L
			add!(circuit, RxGate(j, Variable(coeff[hcount])))
			hcount += 1
		end
	end
	return circuit	
end

variational_circuit_1d(L::Int, depth::Int) = variational_circuit_1d(
	L, depth, randn(get_coef_sizes_1d(L, depth)))

function get_coef_sizes_2d(m::Int, n::Int, depth::Int)
	hcount = m*n*(depth+1)
	return hcount
end

function variational_circuit_2d(m::Int, n::Int, depth::Int, coeff::Vector{<:Number})
	(length(coeff) == get_coef_sizes_2d(m, n, depth)) || error("coeff length error")
	L = m*n
	circuit = QCircuit()
	hcount = 1
	for i in 1:L
		add!(circuit, RxGate(i, Variable(coeff[hcount])))
		hcount += 1
	end	
	sp = (m, n)
	for l in 1:depth
		for i in 1:m
		    for j in 1:(n-1)
		        add!(circuit, CNOTGate((toOneDIndex((i, j), sp), toOneDIndex((i, j+1), sp))))
		    end
		end
		for i in 1:(m-1)
		    for j in 1:n
		        add!(circuit, CNOTGate((toOneDIndex((i, j), sp), toOneDIndex((i+1, j), sp))))
		    end
		end
		for i in 1:L
			add!(circuit, RxGate(i, Variable(coeff[hcount])))
			hcount += 1
		end	
	end
	return circuit
end

variational_circuit_2d(m::Int, n::Int, depth::Int) = variational_circuit_2d(
	m, n, depth, get_coef_sizes_2d(m, n, depth))
