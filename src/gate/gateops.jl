export inner_gate, op, key, shift, AdjointGate, TransposeGate, ConjugateGate, gate
export OneBodyGate, TwoBodyGate, ThreeBodyGate
export XGate, YGate, ZGate, HGate, SGate, TGate, SqrtXGate, SqrtYGate
export RxGate, RyGate, RzGate
export CZGate, CNOTGate, SWAPGate, iSWAPGate, CRxGate, CRyGate, CRzGate, TOFFOLIGate

abstract type AbstractOneBodyGate <: AbstractGate end
abstract type AbstractTwoBodyGate <: AbstractGate end
abstract type AbstractThreeBodyGate <: AbstractGate end


op(s::AbstractGate) = s.op
key(s::AbstractGate) = s.key
scalar_type(s::AbstractGate) = scalar_type(op(s))


# transformed gate
inner_gate(s::AbstractTransformedGate) = s.g
key(s::AbstractTransformedGate) = key(inner_gate(s))
shift(s::AbstractTransformedGate) = typeof(s)(shift(inner_gate(s)))


struct AdjointGate{G} <: AbstractTransformedGate
	g::G
end
op(s::AdjointGate{<:AbstractOneBodyGate}) = Base.adjoint(op(inner_gate(s)))
op(s::AdjointGate{<:AbstractTwoBodyGate}) = permute(conj(op(inner_gate(s))), (3,4,1,2))
op(s::AdjointGate{<:AbstractThreeBodyGate}) = permute(conj(op(inner_gate(s))), (4,5,6,1,2,3))
scalar_type(::Type{AdjointGate{G}}) where G = scalar_type(G)

struct TransposeGate{G} <: AbstractTransformedGate
	g::G
end
op(s::TransposeGate{<:AbstractOneBodyGate}) = Base.transpose(op(inner_gate(s)))
op(s::TransposeGate{<:AbstractTwoBodyGate}) = permute(op(inner_gate(s)), (3,4,1,2))
op(s::TransposeGate{<:AbstractThreeBodyGate}) = permute(op(inner_gate(s)), (4,5,6,1,2,3))
scalar_type(::Type{TransposeGate{G}}) where G = scalar_type(G)


struct ConjugateGate{G} <: AbstractTransformedGate
	g::G
end
op(s::ConjugateGate) = conj(op(inner_gate(s)))
scalar_type(::Type{ConjugateGate{G}}) where G = scalar_type(G)


Base.transpose(s::AbstractGate) = TransposeGate(s)
Base.transpose(s::TransposeGate) = inner_gate(s)
Base.transpose(s::ConjugateGate) = AdjointGate(inner_gate(s))
Base.transpose(s::AdjointGate) = ConjugateGate(inner_gate(s))

Base.adjoint(s::AbstractGate) = AdjointGate(s)
Base.adjoint(s::AdjointGate) = inner_gate(s)
Base.adjoint(s::TransposeGate) = ConjugateGate(inner_gate(s))
Base.adjoint(s::ConjugateGate) = TransposeGate(inner_gate(s))

Base.conj(s::AbstractGate) = ConjugateGate(s)
Base.conj(s::ConjugateGate) = inner_gate(s)
Base.conj(s::AdjointGate) = TransposeGate(inner_gate(s))
Base.conj(s::TransposeGate) = AdjointGate(inner_gate(s))


# one body gate operation
struct OneBodyGate{T} <: AbstractOneBodyGate
	key::Int
	op::T

	function OneBodyGate(key::Int, m::AbstractMatrix; check_unitary::Bool=true) 
		(size(m) == (2, 2)) || error("matrix for one body gate must be a 2*2.")
		if check_unitary
		    if !isapprox(m' * m, eye(2)) 
		    	@warn "input matrix $m is not unitary."
		    end
		end
		new{typeof(m)}(key, m)
	end
end

# constructor
# OneBodyGate(s::OneBodyGate) = OneBodyGate(key(s), op(s))
scalar_type(::Type{OneBodyGate{T}}) where T = scalar_type(T)

# attributes
# explicitly construct a new gate of the same type, instead of lazy evaluation
Base.transpose(s::OneBodyGate) = OneBodyGate(key(s), Base.transpose(op(s)))
Base.conj(s::OneBodyGate) = OneBodyGate(key(s), Base.conj(op(s)))
Base.adjoint(s::OneBodyGate) = OneBodyGate(key(s), Base.adjoint(op(s)))
shift(s::OneBodyGate, i::Int) = OneBodyGate(key(s)+i, op(s))


# two body gate operations

# help funcitons
function _get_norm_order(key::NTuple{N, Int}, p) where N
	seq = sortperm([key...])
	perm = (seq..., [s + N for s in seq]...)
	return key[seq], permute(p, perm)
end

function _get_norm_order(key::NTuple{N, Int}) where N
	seq = sortperm([key...])
	perm = [seq; [s + N for s in seq]]
	return key[seq], perm
end

function _shift(key::NTuple{N, Int}, i::Int) where N
	return NTuple{N, Int}(l+i for l in key)
end

# two body gate
struct TwoBodyGate{T} <: AbstractTwoBodyGate
	key::Tuple{Int, Int}
	op::T

	function TwoBodyGate(key::Tuple{Int, Int}, m::AbstractArray{T, 4}) where T
		(size(m) == (2,2,2,2)) || error("4-d tensor for two body gate must be a 2*2*2*2.")
		(key[1] != key[2]) || error("duplicate positions not allowed for two body gate")
		key, m = _get_norm_order(key, m)
		new{typeof(m)}(key, m)
	end

end

function TwoBodyGate(key::Tuple{Int, Int}, m::AbstractMatrix; check_unitary::Bool=true)
	(size(m) == (4,4)) || error("matrix for two body gate must be a 4*4.")
	if check_unitary
	    if !isapprox(m' * m, eye(4)) 
	    	@warn "input matrix $m is not unitary."
	    end		    
	end
	TwoBodyGate(key, reshape(m,2,2,2,2))
end


# constructor
scalar_type(::Type{TwoBodyGate{T}}) where T = scalar_type(T)


# attributes
# explicitly construct a new gate of the same type, instead of lazy evaluation
Base.transpose(s::TwoBodyGate) = TwoBodyGate(key(s), permute(op(s), (3,4,1,2)))
Base.conj(s::TwoBodyGate) = TwoBodyGate(key(s), Base.conj(op(s)))
Base.adjoint(s::TwoBodyGate) = TwoBodyGate(key(s), permute(conj(op(s)), (3,4,1,2)))
shift(s::TwoBodyGate, i::Int) = TwoBodyGate(_shift(key(s), i), op(s))


# three body gate
struct ThreeBodyGate{T} <: AbstractThreeBodyGate
	key::Tuple{Int, Int, Int}
	op::T
	function ThreeBodyGate(key::Tuple{Int, Int, Int}, m::AbstractArray{T, 6}) where T
		(size(m) == (2,2,2,2,2,2)) || error("6-d tensor for three body gate must be a 2*2*2*2*2*2.")
		(length(Set(key))==3) || error("duplicate positions not allowed for three body gate")
		key, m = _get_norm_order(key, m)
		new{typeof(m)}(key, m)
	end
end

function ThreeBodyGate(key::Tuple{Int, Int, Int}, m::AbstractMatrix; check_unitary::Bool=true)
	(size(m) == (8,8)) || error("matrix for three body gate must be a 8*8.")
	if check_unitary
	    if !isapprox(m' * m, eye(8)) 
	    	@warn "input matrix $m is not unitary."
	    end		    
	end
	TwoBodyGate(key, reshape(m,2,2,2,2,2,2))
end

# constructor
# ThreeBodyGate(s::ThreeBodyGate) = ThreeBodyGate(key(s), op(s))
scalar_type(::Type{ThreeBodyGate{T}}) where T = scalar_type(T)


# attributes
# explicitly construct a new gate of the same type, instead of lazy evaluation
Base.transpose(s::ThreeBodyGate) = ThreeBodyGate(key(s), permute(op(s), (4,5,6,1,2,3)))
Base.conj(s::ThreeBodyGate) = ThreeBodyGate(key(s), conj(op(s)))
Base.adjoint(s::ThreeBodyGate) = ThreeBodyGate(key(s), permute(conj(op(s)), (4,5,6,1,2,3)))
shift(s::ThreeBodyGate, i::Int) = ThreeBodyGate(_shift(key(s), i), op(s))


# concrete gate operations
XGate(key::Int) = OneBodyGate(key, X)
YGate(key::Int) = OneBodyGate(key, Y)
ZGate(key::Int) = OneBodyGate(key, Z)
HGate(key::Int) = OneBodyGate(key, H)
SGate(key::Int) = OneBodyGate(key, S)
TGate(key::Int) = OneBodyGate(key, T)
SqrtXGate(key::Int) = OneBodyGate(key, Xh)
SqrtYGate(key::Int) = OneBodyGate(key, Yh)


# parameteric one body gate
struct RxGate{T} <: AbstractOneBodyGate
	key::Int
	parameter::T
end
op(s::RxGate) = Rx(value(s.parameter))
shift(s::RxGate, i::Int) = RxGate(key(s) + i, s.parameter)

struct RyGate{T} <: AbstractOneBodyGate
	key::Int
	parameter::T
end
op(s::RyGate) = Ry(value(s.parameter))
shift(s::RyGate, i::Int) = RyGate(key(s) + i, s.parameter)


struct RzGate{T} <: AbstractOneBodyGate
	key::Int
	parameter::T
end
op(s::RzGate) = Rz(value(s.parameter))
shift(s::RzGate, i::Int) = RzGate(key(s) + i, s.parameter)



CZGate(key::Tuple{Int, Int}) = TwoBodyGate(key, CZ)
CNOTGate(key::Tuple{Int, Int}) = TwoBodyGate(key, CNOT)
SWAPGate(key::Tuple{Int, Int}) = TwoBodyGate(key, SWAP)
iSWAPGate(key::Tuple{Int, Int}) = TwoBodyGate(key, iSWAP)

struct CRxGate{T} <:AbstractTwoBodyGate
	key::Tuple{Int, Int}
	parameter::T
	perm::Vector{Int}
end

function CRxGate(key::Tuple{Int, Int}, parameter::Real) 
	key, perm = _get_norm_order(key)
	CRxGate(key, parameter, perm)
end
op(s::CRxGate) = permute(reshape(CONTROL(Rx(value(s.parameter))),2,2,2,2), s.perm)
shift(s::CRxGate, i::Int) = CRxGate((l+i for l in key(s)), s.parameter, s.perm)


struct CRyGate{T} <: AbstractTwoBodyGate
	key::Tuple{Int, Int}
	parameter::T
	perm::Vector{Int}	
end

function CRyGate(key::Tuple{Int, Int}, parameter::Real) 
	key, perm = _get_norm_order(key)
	CRyGate(key, parameter, perm)
end
op(s::CRyGate) = permute(reshape(CONTROL(Ry(value(s.parameter))),2,2,2,2), s.perm)
shift(s::CRyGate, i::Int) = CRyGate((l+i for l in key(s)), s.parameter, s.perm)



struct CRzGate{T} <: AbstractTwoBodyGate
	key::Tuple{Int, Int}
	parameter::T
	perm::Vector{Int}	
end

function CRzGate(key::Tuple{Int, Int}, parameter::Real)
	key, perm = _get_norm_order(key)
	CRzGate(key, parameter, perm)
end
op(s::CRzGate) = permute(reshape(CONTROL(Rz(value(s.parameter))),2,2,2,2), s.perm)
shift(s::CRzGate, i::Int) = CRzGate((l+i for l in key(s)), s.parameter, s.perm)




TOFFOLIGate(key::Tuple{Int, Int, Int}) = ThreeBodyGate(key, TOFFOLIGate)

gate(key::Int, m::AbstractMatrix) = OneBodyGate(key, m)
gate(key::Tuple{Int}, m::AbstractMatrix) = OneBodyGate(key[1], m)
gate(key::Tuple{Int, Int}, m::AbstractArray) = TwoBodyGate(key, m)
gate(key::Tuple{Int, Int, Int}, m::AbstractArray) = ThreeBodyGate(key, m)




