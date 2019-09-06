module VQC

using Zygote
using Zygote: @adjoint

import Base.+, Base.-, Base.*, Base./
import LinearAlgebra: dot, norm
using Logging: @warn



include("misc/misc.jl")

include("defs.jl")
include("state.jl")
include("gate/gate.jl")

include("circuit/circuit.jl")
include("circuit/parallel.jl")
include("measure.jl")

# differentiation
include("diff/complex.jl")
include("diff/differentiation.jl")
include("diff/autodiff.jl")

# utility functions
include("utility/utility.jl")

end