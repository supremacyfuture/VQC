export QFT

function _nnqft_one_block(L::Int)
	(L<=0) && error("input size can not be 0")
	r = QCircuit()
	if L==1
		push!(r, (1, H))
		return r
	else
		append!(r, _nnqft_one_block(L-1))
		push!(r, (((L,L-1), CONTROL(R(L)) * SWAP)))
		return r
	end
end

"""
	efficient QFT which only contains nearest neighbour gates.
"""
function QFT(L::Int)
	r = QCircuit()
	for i = L:-1:1
		append!(r, _nnqft_one_block(i))
	end
	return r
end