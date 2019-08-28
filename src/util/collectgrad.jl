export collect_gradients

_collect_gradients_impl!(a::Vector, b::Nothing) = nothing
_collect_gradients_impl!(a::Vector, b::Number) = push!(a, b)
function _collect_gradients_impl!(a::Vector, b::AbstractVector) 
	for item in b
	    _collect_gradients_impl!(a, item)
	end
end

function _collect_gradients_impl!(a::Vector, b::AbstractDict)
	for (k, v) in b
	    _collect_gradients_impl!(a, v)
	end
end

function _collect_gradients_impl!(a::Vector, b::NamedTuple)
	for v in b
	    _collect_gradients_impl!(a, v)
	end
end

function _collect_gradients_impl!(a::Vector, b::Tuple)
	for v in b
	    _collect_gradients_impl!(a, v)
	end
end

_collect_gradients_impl!(a::Vector, b::ComplexGradient) = _collect_gradients_impl!(a, 2*cgrad(b))

function collect_gradients(m)
	a = []
	_collect_gradients_impl!(a, m)
	return [a...]
end


