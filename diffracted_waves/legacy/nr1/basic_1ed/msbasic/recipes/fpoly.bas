SUB FPOLY (X, P(), NP)
P(1) = 1!
FOR J = 2 TO NP
  P(J) = P(J - 1) * X
NEXT J
END SUB

