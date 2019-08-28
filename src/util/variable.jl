export Variable

struct Variable{T}
	value::T

	Variable(m::Number) = new{typeof(m)}(m)
end

Base.:+(a::Variable, b::Float64) = a.value + b
Base.:-(a::Variable, b::Float64) = a.value - b

value(x::Variable) = x.value
value(x) = x