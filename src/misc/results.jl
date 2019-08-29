export Observables, todict, Results, qnames, qvalues, cnames, cvalues

struct Observables <: AbstractArray{Tuple{String, Number}, 1}
	data::Vector{Tuple{String, Number}}
end

data(x::Observables) = x.data

Observables() = Observables(Vector{Tuple{String, Number}}())
Observables(x::Observables) = Observables(data(x))


Base.getindex(x::Observables, key::Int) = Base.getindex(data(x), key)
Base.setindex!(x::Observables, v, key::Int) = Base.setindex!(data(x), v, key)
Base.length(x::Observables) = Base.length(data(x))
Base.IndexStyle(::Type{Observables}) = IndexLinear()
Base.iterate(s::Observables) = Base.iterate(data(s))
Base.iterate(s::Observables, state) = Base.iterate(data(s), state)
Base.size(s::Observables) = Base.size(data(s))
Base.eltype(s::Observables) = Base.eltype(data(s))

Base.push!(x::Observables, v::Tuple{String, Number}) = Base.push!(data(x), v)
Base.append!(x::Observables, y::Vector{Tuple{String, T}}) where {T<:Number} = Base.append!(data(x), y)
Base.append!(x::Observables, y::Observables) = Base.append!(data(x), data(y))
extend!(x::Observables, y) = Base.append!(x, y)

function Base.get(x::Observables, key, default=nothing)
	r = []
	for (name, value) in data(x)
		if name==key
			Base.push!(r, value)
		end
	end
	if isempty(r)
	    return default
	else
		return [r...]
	end	
end

function Base.getindex(x::Observables, key::String)
	r = Base.get(x, key, nothing)
	(r == nothing) && error("key $key not found.")
	return r
end

names(x::Observables) = [key for (key, value) in x]
values(x::Observables) = [value for (key, value) in x]

function get_norm(x::Observables)
	n = x["norm"]
	return n[end]
end

function rescale_by_norm!(x::Observables)
	isempty(x) && return
	v = first(data(x))
	(v[1] != "norm") && error("observables should start with norm.")
	norm = v[2]*v[2]
	x[1] = ("norm", 1.)
	for i in 2:length(x)
		if x[i][1] == "norm"
			norm = x[i][2] * x[i][2]
			x[i] = ("norm", 1.)
		else
			x[i] = (x[i][1], x[i][2]/norm)
		end
	end
end

function todict(x::Observables)
	r = Dict{String, Vector{Number}}()
	for (key, value) in data(x)
		v = Base.get!(r, key, Vector{Number}())
		Base.push!(v, value)
	end
	return Dict(k=>[v...] for (k, v) in r)
end

function converged(r::Dict{String, <:Vector}, tol::Real=1.0e-5, obs=nothing, distance::Int=50)
	if obs == nothing
		obs = [key for key in Base.keys(r) if key != "norm"]
	end
	for name in obs
		v = get(r, name, nothing)
		if v != nothing
			L = length(v)
			(L < distance) && return false
			(iterative_error(v[(L-distance+1):L]) > tol) && return false
		end
	end
	return true	
end

converged(x::Observables, tol::Real=1.0e-5, obs=nothing, distance::Int=50) = converged(todict(x), tol, obs, distance)

struct Results
	parameters
	observables::Observables
	other

	function Results(parameters::Dict{String, T1}, observables::Observables, other::Dict{String, T2}) where {T1, T2}
		new(parameters, observables, other)
	end
end

get_parameters(x::Results) = x.parameters
get_observables(x::Results) = x.observables

Base.get(x::Results, key::String, default=nothing) = Base.get(x.other, key, default)
Base.getindex(x::Results, key::String) = Base.getindex(x.other, key)
Base.append!(x::Results, y::Observables) = Base.append!(get_observables(x), y)



_is_quantum(s::String) = (s[1]=='Q')
_is_classical(s::String) = (s[1]=='C')

qnames(x::Observables) = [key for (key, value) in x if _is_quantum(key)]
qvalues(x::Observables) = [value for (key, value) in x if _is_quantum(key)]
cnames(x::Observables) = [key for (key, value) in x if _is_classical(key)]
cvalues(x::Observables) = [value for (key, value) in x if _is_classical(key)]