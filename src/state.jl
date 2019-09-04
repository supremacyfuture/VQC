export StateVector, qstate, qrandn, distance, expectation, vdot
export amplitude, amplitudes, probability, probabilities

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
+(x::StateVector) = x
-(X::StateVector) = StateVector(-data(x))

Base.conj(x::StateVector) = StateVector(conj(data(x)))

vdot(x::StateVector{A}, y::StateVector{B}) where {A, B} = begin
	(length(x)==length(y)) || error("quantum state size mismatch.")
    r = zero(promote_type(A, B))
    for i in 1:length(x)
        r += x[i] * y[i]
    end
    return r
end

dot(x::StateVector, y::StateVector) = vdot(conj(x), y)

norm(s::StateVector) = norm(data(s))

function distance(x::StateVector, y::StateVector)
    sA = dot(x, x)
    sB = dot(y, y)
    c = dot(x, y)
    r = real(sA+sB-2*c)
    # println("$sA, $sB, $c")
    (r >= 0) || error("distance $r is negative.")
    return sqrt(r)
end 

expectation(a::StateVector, circuit::AbstractCircuit, b::StateVector) = dot(a, circuit * b)

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

function amplitude(s::StateVector, i::Vector{Int}) 
	(length(i)==nqubits(s)) || error("basis mismatch with number of qubits.")
	for s in i
	    (s == 0 || s == 1) || error("qubit state must be 0 or 1.")
	end
	cudim = dim2cudim_col(Tuple([2 for _ in 1:length(i)]))
	idx = mind2sind_col(i, cudim)
	return data(s)[idx+1]
end

amplitudes(s::StateVector) = data(s)

probabilities(s::StateVector) = (abs.(data(s))).^2

probability(s::StateVector, i::Vector{Int}) = abs(amplitude(s, i))^2

swap!(s::StateVector, i::Int, j::Int) = swap!(data(s), i, j)

_collect_gradients_impl!(a::Vector, b::StateVector) = _collect_gradients_impl!(a, data(b))
_reset_parameters_impl!(s::StateVector, coeff::AbstractVector{<:Number}, start_pos::Int=1) = _reset_parameters_impl!(
	data(s), coeff, start_pos)
