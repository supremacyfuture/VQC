# VQC
[![GitHub issues](https://img.shields.io/github/issues/supremacyfuture/VQC)](https://github.com/supremacyfuture/VQC/issues)
[![Build Status](https://travis-ci.org/supremacyfuture/VQC.svg?branch=master)](https://travis-ci.org/supremacyfuture/VQC)
[![Coverage Status](https://coveralls.io/repos/github/supremacyfuture/VQC/badge.svg?branch=master)](https://coveralls.io/github/supremacyfuture/VQC?branch=master)
[![Contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg)](CONTRIBUTING.md)

Variational Quantum Circuit simulator in Julia, under GPLv3

---

## Introduction:
  VQC is an open source framework that can simulate variational quantum circuits and used for quantum machine learning tasks.
  * **Simple but powerful.** VQC suports any single-qubit, two-qubit, three-qubit gate operations, as well as measurements. The same quantum circuit can be used as variational quantum circuits almost for free. 

  * **Everything is differentiable.** Not only the quantum circuit, the quantum state itself is also differentiable, almost without any changing of code. In most of the cases, user can write very complex expression built on top of the quantum circuit and the quantum state and the whole expression will be differentiable.

  * **Flexiable operations on quantum gates and quantum circuits.** Quantum circuit and quantum gates all suport operations such as adjoint, transpose, conjugate, shift to make life easier when building very complex circuits.

  * **Zygote as backend for auto differentiation.** VQC use Zygote as backend for auto differentiation.
## Comparisons between VQC and existing technologies:
Now at [version 0.1.0](https://baidu.com)!

## Installation

VQC is a [julia](https://julialang.org/) language package. To install VQC, please [open Julia's interactive session (known as REPL)](https://docs.julialang.org/en/v1/manual/getting-started/) and type `]` in the REPL to use the package mode, then type this command:

```julia
pkg> add ("VQC")
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
```
## Contact 

Please email your questions or comments to [supremacyfuture](https://github.com/supremacyfuture/VQC).

## Code Style

xxx..
## License

VQC is published under GNUv3 [license](https://github.com/supremacyfuture/VQC/LICENSE)

