module VQC

using Zygote
using Zygote: @adjoint

import Base.+, Base.-, Base.*, Base./
using LinearAlgebra: norm
import LinearAlgebra: dot
using Logging: @warn



include("src/util/util.jl")

include("src/defs.jl")
include("src/state.jl")
include("src/gates.jl")
include("src/gateops.jl")
include("src/apply_gates.jl")
include("src/measure.jl")
include("src/circuit.jl")
include("src/qalgs.jl")
include("src/differentiation.jl")
include("src/autodiff.jl")
include("src/utility.jl")
include("src/naive_gradient.jl")

include("src/parallel.jl")

end