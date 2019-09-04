export QCircuit, add!, extend!, apply!

data(s::AbstractCircuit) = s.data
scalar_type(s::AbstractCircuit) = promote_type([scalar_type(v) for v in s]...)

# vector interface
Base.getindex(x::AbstractCircuit, i::Int) = Base.getindex(data(x), i)
Base.setindex!(x::AbstractCircuit, v::AbstractQuantumOperation,  i::Int) = Base.setindex!(data(x), v, i)
Base.length(x::AbstractCircuit) = Base.length(data(x))
Base.iterate(x::AbstractCircuit) = Base.iterate(data(x))
Base.iterate(x::AbstractCircuit, state) = Base.iterate(data(x), state)
Base.eltype(x::AbstractCircuit) = Base.eltype(data(x))

# attributes
Base.isempty(x::AbstractCircuit) = Base.isempty(data(x))
Base.empty!(x::AbstractCircuit) = empty!(data(x))

add!(x::AbstractCircuit, s) = push!(x, s)
Base.push!(x::AbstractCircuit, s::AbstractQuantumOperation) = Base.push!(data(x), s)
Base.push!(x::AbstractCircuit, s::Tuple{Int, M}) where M = push!(x, OneBodyGate(s[1], s[2]))
Base.push!(x::AbstractCircuit, s::Tuple{NTuple{1, Int}, M}) where M = push!(x, OneBodyGate(s[1][1], s[2]))
Base.push!(x::AbstractCircuit, s::Tuple{NTuple{2, Int}, M}) where M = push!(x, TwoBodyGate(s[1], s[2]))
Base.push!(x::AbstractCircuit, s::Tuple{NTuple{3, Int}, M}) where M = push!(x, ThreeBodyGate(s[1], s[2]))

Base.lastindex(x::AbstractCircuit) = Base.lastindex(data(x))

extend!(x::AbstractCircuit, s) = append!(x, s)
Base.append!(x::AbstractCircuit, y::AbstractCircuit) = append!(data(x), data(y))
Base.append!(x::AbstractCircuit, y::Vector{T}) where {T<:AbstractQuantumOperation} = append!(data(x), y)

Base.transpose(x::AbstractCircuit) = typeof(x)([transpose(x[i]) for i = length(x):-1:1])
Base.conj(x::AbstractCircuit) = typeof(x)([conj(x[i]) for i = 1:length(x)])
Base.adjoint(x::AbstractCircuit) = typeof(x)([x[i]' for i = length(x):-1:1])
shift(x::AbstractCircuit, l::Int) = typeof(x)([shift(gate, l) for gate in x])



"""
Quantum circuit
"""

struct QCircuit <: AbstractCircuit
	data::Vector{AbstractQuantumOperation}
end

QCircuit() = QCircuit(Vector{AbstractQuantumOperation}())

function apply_and_collect!(s::AbstractCircuit, state::StateVector, result) 
	for gate in s
		apply_and_collect!(gate, state, result) 
	end
end

function apply!(circuit::AbstractCircuit, v::StateVector)
	result = []
	apply_and_collect!(circuit, v, result)
	return Observables(result)
end

function *(circuit::AbstractCircuit, v::StateVector)
	T = promote_type(scalar_type(circuit), scalar_type(v))
	v1 = StateVector{T}(copy(data(v)))
	result = apply!(circuit, v1)
	return v1
end

*(v::StateVector, circuit::AbstractCircuit) = transpose(circuit) * v
