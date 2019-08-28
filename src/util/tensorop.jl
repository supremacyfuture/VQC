
"""	
	move_selected_index_forward(a, I)
	move the indexes specified by I to the front of a
	# Arguments
	@ a::NTuple{N, Int}: the input tensor.
	@ I: tuple or vector of integer.
"""
function move_selected_index_forward(a::Vector{T}, I) where {T}
    na = length(a)
    nI = length(I)
    b = Vector{T}(undef, na)
    k1 = 0
    k2 = nI
    for i=1:na
        s = 0
        while s != nI
        	if i == I[s+1]
        		b[s+1] = a[k1+1]
        	    k1 += 1
        	    break
        	end
        	s += 1
        end
        if s == nI
        	b[k2+1]=a[k1+1]
        	k1 += 1
            k2 += 1
        end
    end
    return b
end

function move_selected_index_forward(a::NTuple{N, T}, I) where {N, T}
    return NTuple{N, T}(move_selected_index_forward([a...], I))
end

"""	
	move_selected_index_backward(a, I)
	move the indexes specified by I to the back of a
	# Arguments
	@ a::NTuple{N, Int}: the input tensor.
	@ I: tuple or vector of integer.
"""
function move_selected_index_backward(a::Vector{T}, I) where {T}
	na = length(a)
	nI = length(I)
	nr = na - nI
	b = Vector{T}(undef, na)
	k1 = 0
	k2 = 0
	for i = 1:na
	    s = 0
	    while s != nI
	    	if i == I[s+1]
	    		b[nr+s+1] = a[k1+1]
	    		k1 += 1
	    		break
	    	end
	    	s += 1
	    end
	    if s == nI
	        b[k2+1] = a[k1+1]
	        k2 += 1
	        k1 += 1
	    end
	end
	return b
end

function move_selected_index_backward(a::NTuple{N, T}, I) where {N, T}
	return NTuple{N, T}(move_selected_index_backward([a...], I))
end

function swap!(qstate::AbstractVector, i::Int, j::Int) where T
	(i == j) && return 
	if i < j
		fsize = 2^(i-1)
		msize = 2^(j-i-1)
		bsize = div(length(qstate), (fsize*4*msize))
		s = reshape(qstate, (fsize, 2, msize, 2, bsize))

		# tmp = Tensor{T}(undef, fsize, msize, bsize)
		tmp = s[:, 1, :, 2, :]
		s[:, 1, :, 2, :] = s[:, 2, :, 1, :]
		s[:, 2, :, 1, :] = tmp
	else
		swap!(qstate, j, i)
	end
end


"""
	a is a small matrix, 
	b is a matrix with large second dimension
	b <- contract(a, b, ((2,), (2,)))
"""
function _inplace_dot!(b::AbstractMatrix, a::AbstractMatrix, maxsize::Int) 
	batchsize = div(maxsize, size(b, 2))
	s = 0
	for j = 0:batchsize:(size(b, 1)+1-batchsize)
		b[(s+1):(s+batchsize), :] = b[(s+1):(s+batchsize), :]*a
		s += batchsize
	end
	b[(s+1):end, :] = b[(s+1):end, :] * a
end

"""
	a is a small matrix, 
	b is a 3-dimensional tensor
"""
function inplace_apply!(b::AbstractArray{T, 3}, a::AbstractMatrix, maxsize::Int=1000000) where T
	(size(b, 2) <= maxsize) || error("wrong maxsize.")
	batchsize = div(maxsize, size(b, 2))
	aT = Base.transpose(a)
	for i = 1:size(b, 3)
		_inplace_dot!(view(b, :,:,i), aT, maxsize)
	end
end

function eye(::Type{T}, d::Int) where {T <: Number}
	r = zeros(T, d, d)
	for i in 1:d
	    r[i, i] = 1
	end
	return r
end

eye(d::Int) = eye(Float64, d)


"""
	permute(tensor, perm)

Tensor permute operation.
"""
permute(m::AbstractArray, perm) = PermutedDimsArray(m, perm)

"""
	creshape(tensor, dims)

Tensor reshape operation (using C-like index order).
"""
creshape(m::AbstractArray, dims::NTuple{N, Int}) where N = permute(reshape(m, reverse(dims)), Tuple(N:-1:1))
creshape(m::AbstractArray, dims::Int...) = creshape(m, dims)

# do we really need tie function?
function _group_extent(extent::NTuple{N, Int}, idx::NTuple{N1, Int}) where {N, N1}
    ext = Vector{Int}(undef, N1)
    l = 0
    for i=1:N1
        ext[i] = prod(extent[(l+1):(l+idx[i])])
        l += idx[i]
    end
    return NTuple{N1, Int}(ext)
end


function tie(a::AbstractArray{T, N}, axs::NTuple{N1, Int}) where {T, N, N1}
    (sum(axs) != N) && error("total number of axes should equal to tensor rank.")
    return reshape(a, _group_extent(size(a), axs))
end

function contract(a::AbstractArray{Ta, Na}, b::AbstractArray{Tb, Nb}, axs::Tuple{NTuple{N, Int}, NTuple{N, Int}}) where {Ta, Na, Tb, Nb, N}
    ia, ib = axs
    seqindex_a = move_selected_index_backward(collect(1:Na), ia)
    seqindex_b = move_selected_index_forward(collect(1:Nb), ib)
    ap = permute(a, seqindex_a)
    bp = permute(b, seqindex_b)
    return reshape(tie(ap, (Na-N, N)) * tie(bp, (N, Nb-N)), size(ap)[1:(Na-N)]..., size(bp)[(N+1):Nb]...)
end


function _row_kron(a::AbstractArray{T1, 2}, b::AbstractArray{T2, 2}) where {T1, T2}
	c = contract(a, b, ((), ()))
	c = permute(c, (1,3,2,4))
	s1 = size(c, 1)*size(c, 2)
	s2 = size(c, 3)*size(c, 4)
	return reshape(c, (s1, s2))
end


