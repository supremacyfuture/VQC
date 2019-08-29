export collect_gradients

_collect_gradients_impl!(a::Vector, b::Nothing) = nothing
_collect_gradients_impl!(a::Vector, b::Real) = push!(a, b)
_collect_gradients_impl!(a::Vector, b::Complex) = push!(a, 2*conj(b))
function _collect_gradients_impl!(a::Vector, b::AbstractArray) 
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

function collect_gradients(args...)
	a = []
	for item in args
	    _collect_gradients_impl!(a, item)
	end
	return [a...]
end


