export parallelize

abstract type AbstractConstCircuit <: AbstractCircuit end
abstract type AbstractParametericCircuit <: AbstractCircuit end

nparameters(s::AbstractConstCircuit) = 0
reset_parameters!(s::AbstractConstCircuit, coeff::AbstractVector{<:Number}, start_pos::Int=1) = start_pos

@adjoint *(circuit::AbstractConstCircuit, s::StateVector) = circuit * s, z -> (nothing, z * circuit)

struct ConstQCircuit <: AbstractConstCircuit
	data::Vector{AbstractQuantumOperation}
end
ConstQCircuit() = ConstQCircuit(Vector{AbstractQuantumOperation}())


struct ParametericQCircuit <: AbstractParametericCircuit
	data::Vector{AbstractQuantumOperation}
end
ParametericQCircuit() = ParametericQCircuit(Vector{AbstractQuantumOperation}())


struct ParallelizedQCircuit <: AbstractCircuit
	data::Vector{AbstractQuantumOperation}
end

Base.push!(x::ParallelizedQCircuit, s::ConstQCircuit) = push!(data(x), s)
Base.push!(x::ParallelizedQCircuit, s::ParametericQCircuit) = push!(data(x), s)

function parallelize(circuit::AbstractCircuit)
	r = []
	isempty(circuit) && return r
	if nparameters(circuit[1]) == 0
	    tmp = ConstQCircuit()
	    push!(tmp, circuit[1])
	else
		tmp = ParametericQCircuit()
		push!(tmp, circuit[1])
	end
	push!(r, tmp)
	for i in 2:length(circuit)
		c = r[end]
		gate = circuit[i]
		if isa(c, ConstQCircuit)
		    if nparameters(gate)==0
		        push!(c, gate)
		    else
		    	tmp = ParametericQCircuit()
		    	push!(tmp, gate)
		    	push!(r, tmp)
		    end
		elseif isa(c, ParametericQCircuit)
			if nparameters(gate)==0
			    tmp = ConstQCircuit()
			    push!(tmp, gate)
			    push!(r, tmp)
			else
				push!(c, gate)
			end
		else
			error("wrong circuit type.")
		end
	end
	return ParallelizedQCircuit([r...])
end

function *(circuits::ParallelizedQCircuit, v::StateVector)
	for item in circuits
	    v = item * v
	end
	return v
end
