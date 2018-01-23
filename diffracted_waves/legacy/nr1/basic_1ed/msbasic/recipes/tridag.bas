SUB TRIDAG (A(), B(), C(), R(), U(), N)
DIM GAM(N)
IF B(1) = 0! THEN PRINT "Abnormal exit": EXIT SUB
BET = B(1)
U(1) = R(1) / BET
FOR J = 2 TO N
  GAM(J) = C(J - 1) / BET
  BET = B(J) - A(J) * GAM(J)
  IF BET = 0! THEN PRINT "Abnormal exit": EXIT SUB
  U(J) = (R(J) - A(J) * U(J - 1)) / BET
NEXT J
FOR J = N - 1 TO 1 STEP -1
  U(J) = U(J) - GAM(J + 1) * U(J + 1)
NEXT J
ERASE GAM
END SUB

