
scalar_type(x::AbstractArray{T, N}) where {T<:Number, N} = T
scalar_type(x::AbstractArray{T, N}) where {T, N} = scalar_type(T)
scalar_type(::Type{S}) where {T<:Number, N, S<:AbstractArray{T, N}} = T

const TOrNothing{T} = Union{T, Nothing}
