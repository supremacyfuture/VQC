export collect_variables, parameters

_collect_variables_impl!(a::Vector, b::Nothing) = nothing
_collect_variables_impl!(a::Vector, b::Real) = push!(a, b)
_collect_variables_impl!(a::Vector, b::Complex) = push!(a, 2*conj(b))
function _collect_variables_impl!(a::Vector, b::AbstractArray) 
	for item in b
	    _collect_variables_impl!(a, item)
	end
end

function _collect_variables_impl!(a::Vector, b::AbstractDict)
	for (k, v) in b
	    _collect_variables_impl!(a, v)
	end
end

function _collect_variables_impl!(a::Vector, b::NamedTuple)
	for v in b
	    _collect_variables_impl!(a, v)
	end
end

function _collect_variables_impl!(a::Vector, b::Tuple)
	for v in b
	    _collect_variables_impl!(a, v)
	end
end

function collect_variables(args...)
	a = []
	for item in args
	    _collect_variables_impl!(a, item)
	end
	return [a...]
end

parameters(args...) = collect_variables(args...)
