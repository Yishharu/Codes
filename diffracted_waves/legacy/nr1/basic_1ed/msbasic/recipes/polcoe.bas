SUB POLCOE (X(), Y(), N, COF())
DIM S(N)
FOR I = 1 TO N
  S(I) = 0!
  COF(I) = 0!
NEXT I
S(N) = -X(1)
FOR I = 2 TO N
  FOR J = N + 1 - I TO N - 1
    S(J) = S(J) - X(I) * S(J + 1)
  NEXT J
  S(N) = S(N) - X(I)
NEXT I
FOR J = 1 TO N
  PHI = N
  FOR K = N - 1 TO 1 STEP -1
    PHI = K * S(K + 1) + X(J) * PHI
  NEXT K
  FF = Y(J) / PHI
  B = 1!
  FOR K = N TO 1 STEP -1
    COF(K) = COF(K) + B * FF
    B = S(K) + X(J) * B
  NEXT K
NEXT J
ERASE S
END SUB

