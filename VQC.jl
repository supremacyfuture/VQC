module VQC

using Zygote
using Zygote: @adjoint

import Base.+, Base.-, Base.*, Base./
import LinearAlgebra: dot, norm
using Logging: @warn



include("src/misc/misc.jl")

include("src/defs.jl")
include("src/state.jl")
include("src/gate/gate.jl")

include("src/circuit/circuit.jl")
include("src/circuit/parallel.jl")
include("src/measure.jl")

# differentiation
include("src/diff/complex.jl")
include("src/diff/differentiation.jl")
include("src/diff/autodiff.jl")

# utility functions
include("src/utility/utility.jl")

end