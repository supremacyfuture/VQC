<div align="left"> <img
src="https://github.com/supremacyfuture/VQC/blob/master/docs/assets/VQC.svg"
alt="VQC Logo" width="210"></img>
</div>
<br>

[![Build Status](https://travis-ci.org/supremacyfuture/VQC.svg?branch=master)](https://travis-ci.org/supremacyfuture/VQC)
[![Coverage Status](https://coveralls.io/repos/github/supremacyfuture/VQC/badge.svg?branch=master)](https://coveralls.io/github/supremacyfuture/VQC?branch=master)
[![GitHub issues](https://img.shields.io/github/issues/supremacyfuture/VQC)](https://github.com/supremacyfuture/VQC/issues)
[![Contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![License: MIT](https://img.shields.io/badge/License-GPLv3-brightgreen.svg)](https://www.gnu.org/licenses/quick-guide-gplv3.pdf)

Variational Quantum Circuit simulator in Julia, under GPLv3, developed with <3 by [Supremacy Future Technologies](https://supremacyfuture.com).

---

## Introduction:
  VQC is an open source framework that can simulate variational quantum circuits and used for quantum machine learning tasks.
  * **Simple but powerful.** VQC supports any single-qubit, two-qubit, three-qubit gate operations, as well as measurements. The same quantum circuit can be used as variational quantum circuits almost for free. 

  * **Everything is differentiable.** Not only the quantum circuit, the quantum state itself is also differentiable, almost without any changing of code. In most of the cases, user can write a very complex expression built on top of the quantum circuit and the quantum state, and the whole expression will be differentiable.

  * **Flexiable operations on quantum gates and quantum circuits.** Quantum circuit and quantum gates suport operations such as adjoint, transpose, conjugate, shift to make life easier when building very complex circuits.

  * **Zygote as backend for auto differentiation.** VQC use Zygote as backend for auto differentiation.
## Comparisons between VQC and existing technologies:
Now at [version 0.1.0](https://github.com/supremacyfuture/VQC)!

## Installation

VQC is a [Julia](https://julialang.org/) language package. To install VQC, please [open Julia's interactive session (known as REPL)](https://docs.julialang.org/en/v1/manual/getting-started/) and type

```julia
pkg> import Pkg; Pkg.add("VQC")
```
## Example:

```julia
# Using functions from VQC
julia> using VQC

# Create a two qubit quantum state |00>
julia> state = qstate([0,0])
StateVector{Complex{Float64}}(Complex{Float64}[1.0 + 0.0im, 0.0 + 0.0im, 0.0 + 0.0im, 0.0 + 0.0im])

# Create and empty quantum circuit
julia> circuit = QCircuit()
QCircuit(VQC.AbstractQuantumOperation[])

# pushing gate operations into the quantum circuit
julia> push!(circuit, HGate(1))
1-element Array{VQC.AbstractQuantumOperation,1}:
 OneBodyGate{Array{Float64,2}}(1, [0.7071067811865475 0.7071067811865475; 0.7071067811865475 -0.7071067811865475])

# pushing measure operation into the quantum circuit
julia> push!(circuit, QMeasure(1)))
2-element Array{VQC.AbstractQuantumOperation,1}:
OneBodyGate{Array{Float64,2}}(1, [0.7071067811865475 0.7071067811865475; 0.7071067811865475 -0.7071067811865475])
QMeasure(1, true, true, [1.0 0.0; 0.0 1.0]) 

# apply quantum circuit to quantum state
julia> results = apply!(circuit, state)
2-element Observables:
 ("Q:Z1", 1)                    
 ("C:Z1->1", 0.4999999999999999)

# In "Q:Z1", Q means quantum observable, Z refer to the basis, 1 is the qubit label
# Similarly, in "C:Z1->1", C means classical observables, 0.4999.. means the probability
# Obtain all the measurement outcomes.
julia> qvalues(results)
1-element Array{Int64,1}:
 1

# Obtain all the measurement probabilities
julia> cvalues(results)
1-element Array{Float64,1}:
 0.4999999999999999
```

## Tutorials
 1. [Tutorial 1: Basic operations](example/variational_quantum_circuit_simulator.ipynb)

## Contact 

You are welcome to leave your comment or suggestions as an [issues](https://github.com/supremacyfuture/VQC/issues). For commercial purpose, please email us at support [at] supremacyfuture.com

## Citing VQC

Please cite the following paper when using VQC: 

```
@misc{liu2019qccnn,
    title={Hybrid Quantum-Classical Convolutional Neural Networks},
    author={Liu, Junhua and Lim, Kwan Hui and Wood, Kristin L and Huang, Wei and Guo, Chu and Huang, He-Liang},
    year={2019},
    eprint={1911.02998},
    archivePrefix={arXiv},
    primaryClass={quant-ph}
}
```


## License

VQC is published under [GPLv3](https://github.com/supremacyfuture/VQC/LICENSE)

Copyright (C) 2019 [Supremacy Future Technologies](https://supremacyfuture.com)

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see [here](https://www.gnu.org/licenses/gpl-3.0.html).
