export set_parameters!

_reset_parameters_impl!(s, coeff::AbstractVector{<:Number}, start_pos::Int) = error("
	_reset_parameter_impl! not implemented for type $(typeof(s))")

_reset_parameters_impl!(a::AbstractArray{<:Number, N}, coeff::AbstractVector{<:Number}, start_pos::Int=1) where N = begin
    for j in 1:length(a)
        a[j] = coeff[start_pos] 
        start_pos += 1
    end
    return start_pos
end

_reset_parameters_impl!(a::AbstractArray{T, N}, coeff::AbstractVector{<:Number}, start_pos::Int=1) where {T, N} = begin
    for j in 1:length(a)
    	start_pos = _reset_parameters_impl!(a, coeff, start_pos)
    end
    return start_pos   
end

function set_parameters!(coeff::AbstractVector{<:Number}, args...)
    start_pos = 1
    for item in args
        start_pos = _reset_parameters_impl!(item, coeff, start_pos)
    end
end