export Variable

mutable struct Variable{T}
	value::T

	Variable(m::Number) = new{typeof(m)}(m)
end

Base.:+(a::Variable, b::Float64) = a.value + b
Base.:-(a::Variable, b::Float64) = a.value - b

value(x::Variable) = x.value
value(x) = x

_reset_parameter_impl!(s::Variable, coeff::AbstractVector{<:Number}, start_pos::Int=1) = begin
    s.value = coeff[start_pos]
    return start_pos + 1
end