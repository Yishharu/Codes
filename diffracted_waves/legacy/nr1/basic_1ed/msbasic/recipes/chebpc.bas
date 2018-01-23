SUB CHEBPC (C(), D(), N)
DIM DD(N)
FOR J = 1 TO N
  D(J) = 0!
  DD(J) = 0!
NEXT J
D(1) = C(N)
FOR J = N - 1 TO 2 STEP -1
  FOR K = N - J + 1 TO 2 STEP -1
    SV = D(K)
    D(K) = 2! * D(K - 1) - DD(K)
    DD(K) = SV
  NEXT K
  SV = D(1)
  D(1) = -DD(1) + C(J)
  DD(1) = SV
NEXT J
FOR J = N TO 2 STEP -1
  D(J) = D(J - 1) - DD(J)
NEXT J
D(1) = -DD(1) + .5 * C(1)
ERASE DD
END SUB

