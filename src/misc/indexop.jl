


"""
	compute cumulant dim (cudim) from the dimension of
	the tensor
"""
function dim2cudim_col(dim) 
	cudim = Vector{Int}(undef, length(dim))
	cudim[1] = 1
	temp = 1
	for i in 2:length(dim)
		temp *= dim[i-1]
		cudim[i] = temp
	end
	return cudim
end

"""
	singleindex is a single number, numtindex and cudim 
	are list. singleindex and cudim are input, multindex 
	are output. This function map the single index to 
	multindex which is useful for general tensor index 
	operation
"""
function sind2mind_col(singleindex::Int128, cudim) 
	L = length(cudim)
	multindex = Vector{Int}(undef, L)
	for i in L:-1:2
		multindex[i] = div(singleindex, cudim[i])
		singleindex %= cudim[i]
	end
	multindex[1] = div(singleindex, cudim[1])
	return multindex
end

"""
	map multindex to singleindex
"""
function mind2sind_col(multindex, cudim) 
	L = length(cudim)
	(length(multindex)==L) || error("wrong multindex size.")
	singleindex = Int128(multindex[1])
	for i in 2:L
		singleindex += multindex[i]*cudim[i]
	end
	return singleindex
end