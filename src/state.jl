export StateVector, qstate, qrandn

# struct StateVector{T} <: AbstractArray{T, 1}
# 	data::Vector{T}
# end

struct StateVector{T} 
	data::Vector{T}
end

data(s::StateVector{T}) where T = s.data
Base.copy(s::StateVector) = StateVector(copy(data(s)))
scalar_type(s::StateVector) = scalar_type(data(s))
scalar_type(::Type{StateVector{T}}) where T = T

# iterator
Base.iterate(s::StateVector{T}) where T = Base.iterate(data(s))
Base.iterate(s::StateVector{T}, state) where T = Base.iterate(data(s), state)
Base.IndexStyle(::Type{StateVector{T}}) where T = IndexLinear()
Base.eltype(s::StateVector{T}) where T = Base.eltype(data(s))
Base.length(s::StateVector{T})  where T = Base.length(data(s))
Base.size(s::StateVector{T}) where T = Base.size(data(s))
Base.size(s::StateVector{T}, i::Int) where T = size(data(s), i)
Base.isempty(s::StateVector{T}) where T = Base.isempty(data(s))
Base.similar(s::StateVector) = StateVector(similar(data(s)))
Base.similar(s::StateVector, dims::Dims) = StateVector(similar(data(s), dims))
Base.similar(s::StateVector, ::Type{T}) where T = StateVector(similar(data(s), T))
Base.similar(s::StateVector, ::Type{T}, dims::Dims) where T = StateVector(similar(data(s), T, dims))

# index access
Base.getindex(s::StateVector{T}, key::Int) where T = Base.getindex(data(s), key)
Base.setindex!(s::StateVector{T}, v, key::Int) where T = Base.setindex!(data(s), v, key)

+(x::StateVector, y::StateVector) = StateVector(data(x) + data(y))
-(x::StateVector, y::StateVector) = StateVector(data(x) - data(y))
*(x::StateVector, y::Number) = StateVector(data(x) * y)
*(y::Number, x::StateVector) = x * y
/(x::StateVector, y::Number) = StateVector(data(x) ./ y)


nqubits(s::StateVector{T}) where T = round(Int, log2(length(s))) 


kernal_mapping(s::Real) = [cos(s*pi/2), sin(s*pi/2)]

function qstate(::Type{T}, mpsstr::Vector{<:Real}) where {T <: Number}
	isempty(mpsstr) && error("no state")
	if length(mpsstr) == 1
	    v = kernal_mapping(mpsstr[1])
	else
		v = kron(kernal_mapping.(reverse(mpsstr))...)
	end
	return StateVector{T}(v)
end

qstate(mpsstr::Vector{<:Real}) = qstate(Complex{Float64}, mpsstr)
qstate(::Type{T}, n::Int) where {T <: Number} = qstate(T, [0 for _ in 1:n])
qstate(n::Int) = qstate(Complex{Float64}, n)

function qrandn(::Type{T}, n::Int) where {T <: Number} 
	(n >= 1) || error("number of qubits must be positive.")
	v = randn(T, 2^n)
	v ./= norm(v)
	return StateVector(v)
end

qrandn(n::Int) = qrandn(Complex{Float64}, n)

swap!(s::StateVector, i::Int, j::Int) = swap!(data(s), i, j)

_collect_gradients_impl!(a::Vector, b::StateVector) = _collect_gradients_impl!(a, data(b))
