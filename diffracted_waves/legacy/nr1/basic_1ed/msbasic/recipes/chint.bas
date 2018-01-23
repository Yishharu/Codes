SUB CHINT (A, B, C(), CINQ(), N)
CON = .25 * (B - A)
SUM = 0!
FAC = 1!
FOR J = 2 TO N - 1
  CINQ(J) = CON * (C(J - 1) - C(J + 1)) / (J - 1)
  SUM = SUM + FAC * CINQ(J)
  FAC = -FAC
NEXT J
CINQ(N) = CON * C(N - 1) / (N - 1)
SUM = SUM + FAC * CINQ(N)
CINQ(1) = 2! * SUM
END SUB

