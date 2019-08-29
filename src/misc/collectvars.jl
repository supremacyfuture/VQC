export collect_variables


_collect_variables_impl!(a::Vector, b) = _collect_gradients_impl!(a, b)

collect_variables(args...) = collect_gradients(args...)
