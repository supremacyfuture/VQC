export differentiate, nparameters, parameters, reset_parameters!

"""
Differentiate gates
"""

differentiate(s::AbstractQuantumOperation) = error("differentiate not implemented for operation type $(typeof(s)).")
differentiate(s::AbstractGate) = nothing
nparameters(s::AbstractGate) = 0


function differentiate(s::AdjointGate)
	r = differentiate(inner_gate(s))
	if r === nothing
	    return r
	else
		return AdjointGate(r)
	end
end

function differentiate(s::TransposeGate) 
	r = differentiate(inner_gate(s))
	if r === nothing
	    return r
	else
		return TransposeGate(r)
	end
end

function differentiate(s::ConjugateGate)
	r = differentiate(inner_gate(s))
	if r === nothing
	    return r
	else
		return ConjugateGate(r)
	end
end 

differentiate(s::RxGate{<:Variable}) =  RxGate(key(s), s.parameter + 0.5*pi)
nparameters(s::RxGate{<:Variable}) = 1
reset_parameter(s::RxGate, v::Number) = RxGate(key(s), Variable(v))

differentiate(s::RyGate{<:Variable}) = RyGate(key(s), s.parameter + 0.5*pi)
nparameters(s::RyGate{<:Variable}) = 1
reset_parameter(s::RyGate, v::Number) = RyGate(key(s), Variable(v))

differentiate(s::RzGate{<:Variable}) = RzGate(key(s), s.parameter + 0.5*pi)
nparameters(s::RzGate{<:Variable}) = 1
reset_parameter(s::RzGate, v::Number) = RzGate(key(s), Variable(v))


differentiate(s::CRxGate{<:Variable}) = begin
    m = permute(reshape(kron(Rx(value(s.parameter+0.5*pi)), DOWN), 2,2,2,2), s.perm)
    return TwoBodyGate(key(s), m)
end 
reset_parameter(s::CRxGate, v::Number) = CRxGate(key(s), Variable(v))
nparameters(s::CRxGate{<:Variable}) = 1

differentiate(s::CRyGate{<:Variable}) = begin
    m = permute(reshape(kron(Ry(value(s.parameter+0.5*pi)), DOWN), 2,2,2,2), s.perm)
    return TwoBodyGate(key(s), m)
end 
reset_parameter(s::CRyGate, v::Number) = CRyGate(key(s), Variable(v))
nparameters(s::CRyGate{<:Variable}) = 1

differentiate(s::CRzGate{<:Variable}) = begin
    m = permute(reshape(kron(Rz(value(s.parameter+0.5*pi)), DOWN), 2,2,2,2), s.perm)
    return TwoBodyGate(key(s), m)
end 

reset_parameter(s::CRzGate, v::Number) = CRzGate(key(s), Variable(v)) 
nparameters(s::CRzGate{<:Variable}) = 1

nparameters(s::AbstractCircuit) = isempty(s) ? 0 : sum([nparameters(gate) for gate in s])

function parameters(s::AbstractCircuit)
	r = []
	for gate in s
	    if nparameters(gate)==1
	        push!(r, value(gate.parameter))
	    end
	end
	return [r...]
end

function reset_parameters!(s::AbstractCircuit, coeff::AbstractVector{<:Number}, start_pos::Int=1) 
	j = start_pos
	for i in 1:length(s)
		if isa(s[i], AbstractCircuit)
		    j = reset_parameter!(s[i], coeff, j)
		else
	    	if nparameters(s[i]) == 1
	    		s[i] = reset_parameter(s[i], coeff[j])
	    		j += 1
	    	end			
		end
	end
	# (j == length(coeff)) || error("wrong number of parameters.")
	return j
end

"""
Differentiate circuit
"""
function differentiate(x::AbstractCircuit)
	r = []
	for i in 1:length(x)
	    df = differentiate(x[i])
	    if df === nothing
	        continue
	    end
	    if isa(df, Vector)
	        for item in df
	        	isa(item, AbstractCircuit) || error("wrong type...")
	            push!(r, QCircuit([[x[l] for l in 1:(i-1)]..., item, [x[l] for l in (i+1):length(x)]...]))
	        end
	    else
	    	push!(r, QCircuit([[x[l] for l in 1:(i-1)]..., df, [x[l] for l in (i+1):length(x)]...]))
	    end
	end
	return r
end
