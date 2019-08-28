

abstract type AbstractQuantumOperation end
abstract type AbstractCircuit <: AbstractQuantumOperation end
abstract type AbstractGate <: AbstractQuantumOperation end
abstract type AbstractTransformedGate <: AbstractGate end


