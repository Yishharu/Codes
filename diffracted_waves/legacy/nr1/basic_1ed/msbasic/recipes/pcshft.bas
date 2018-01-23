SUB PCSHFT (A, B, D(), N)
CONSQ = 2! / (B - A)
FAC = CONSQ
FOR J = 2 TO N
  D(J) = D(J) * FAC
  FAC = FAC * CONSQ
NEXT J
CONSQ = .5 * (A + B)
FOR J = 1 TO N - 1
  FOR K = N - 1 TO J STEP -1
    D(K) = D(K) - CONSQ * D(K + 1)
  NEXT K
NEXT J
END SUB

