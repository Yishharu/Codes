SUB CHDER (A, B, C(), CDER(), N)
CDER(N) = 0!
CDER(N - 1) = 2 * (N - 1) * C(N)
IF N >= 3 THEN
  FOR J = N - 2 TO 1 STEP -1
    CDER(J) = CDER(J + 2) + 2 * J * C(J + 1)
  NEXT J
END IF
CON = 2! / (B - A)
FOR J = 1 TO N
  CDER(J) = CDER(J) * CON
NEXT J
END SUB

