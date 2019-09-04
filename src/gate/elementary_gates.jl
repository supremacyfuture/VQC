export X, Y, Z, S, H, sqrtX, sqrtY, T, Rx, Ry, Rz, CONTROL, CZ, CNOT, CX, SWAP, iSWAP
export CONTROLCONTROL, TOFFOLI, CCX

ZERO = [1., 0.]

ONE = [0., 1.]


const X = [0. 1. ; 1. 0.]

const Y = [0. -im; im 0.]

const Z = [1. 0. ; 0. -1.]

const S = [1. 0. ;  0. im]

const H = (X + Z) / sqrt(2)

const UP = [1. 0. ; 0. 0.]

const DOWN = [0. 0.; 0. 1.]

const Xh = [1+im 1-im; 1-im 1+im]/2

const sqrtX = Xh

const Yh = [im -im; im im]/sqrt(2*im)

const sqrtY = Yh

const T = [1. 0.; 0. exp(im*pi/4)]

R(k::Int) = [1 0; 0 exp(pi*im/(2^(k-1)))]

Rx(theta::Number) = [cos(theta) -im*sin(theta); -im*sin(theta) cos(theta)]

Ry(theta::Number) = [cos(theta) -sin(theta); sin(theta) cos(theta)]

Rz(theta::Number) = [exp(-im*theta) 0; 0 exp(im*theta)]

function CONTROL(u::AbstractMatrix)
	(size(u, 1) == size(u, 2)) || error("must be a square matrix.")
	(size(u, 1) == 2) || error("input matrix must be 2 by 2")
	return _row_kron(UP, eye(2)) + _row_kron(DOWN, u)
end

const CZ = CONTROL(Z)

const CNOT = CONTROL(X)

const CX = CNOT

const SWAP = [1. 0. 0. 0.; 0. 0. 1. 0.; 0. 1. 0. 0.; 0. 0. 0. 1.]

const iSWAP = [1. 0. 0. 0.; 0. 0. im 0.; 0. im 0. 0.; 0. 0. 0. 1.]

# three body gates
function CONTROLCONTROL(u::AbstractMatrix) 
	(size(u, 1) == size(u, 2)) || error("must be a square matrix.")
	(size(u, 1) == 2) || error("input matrix must be 2 by 2")
	Iu = eye(2)
	return _row_kron(Iu, _row_kron(UP, UP)) + _row_kron(Iu, _row_kron(UP, DOWN)) + 
	_row_kron(Iu, _row_kron(DOWN, UP)) + _row_kron(u, _row_kron(DOWN, DOWN))
end

const TOFFOLI = CONTROLCONTROL(X)

const CCX = TOFFOLI

