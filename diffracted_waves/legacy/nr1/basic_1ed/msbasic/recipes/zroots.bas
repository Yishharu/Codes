DECLARE SUB LAGUER (A!(), M!, X!(), EPS!, POLISH%)

SUB ZROOTS (A(), M, ROOTS(), POLISH%)
EPS = .000001
MAXM = 101
DIM AD(2, MAXM), X(2), B(2), C(2), DUM(2)
FOR J = 1 TO M + 1
  AD(1, J) = A(1, J)
  AD(2, J) = A(2, J)
NEXT J
FOR J = M TO 1 STEP -1
  X(1) = 0!
  X(2) = 0!
  CALL LAGUER(AD(), J, X(), EPS, 0)
  IF ABS(X(2)) <= 2! * EPS ^ 2 * ABS(X(1)) THEN X(2) = 0!
  ROOTS(1, J) = X(1)
  ROOTS(2, J) = X(2)
  B(1) = AD(1, J + 1)
  B(2) = AD(2, J + 1)
  FOR JJ = J TO 1 STEP -1
    C(1) = AD(1, JJ)
    C(2) = AD(2, JJ)
    AD(1, JJ) = B(1)
    AD(2, JJ) = B(2)
    DUM = B(1)
    B(1) = X(1) * DUM - X(2) * B(2) + C(1)
    B(2) = X(2) * DUM + X(1) * B(2) + C(2)
  NEXT JJ
NEXT J
IF POLISH% THEN
  FOR J = 1 TO M
    DUM(1) = ROOTS(1, J)
    DUM(2) = ROOTS(2, J)
    CALL LAGUER(A(), M, DUM(), EPS, -1)
  NEXT J
END IF
FOR J = 2 TO M
  X(1) = ROOTS(1, J)
  X(2) = ROOTS(2, J)
  FOR I = J - 1 TO 1 STEP -1
    IF ROOTS(1, I) <= X(1) THEN EXIT FOR
    ROOTS(1, I + 1) = ROOTS(1, I)
    ROOTS(2, I + 1) = ROOTS(2, I)
  NEXT I
  IF ROOTS(1, I) > X(1) THEN I = 0
  ROOTS(1, I + 1) = X(1)
  ROOTS(2, I + 1) = X(2)
NEXT J
ERASE DUM, C, B, X, AD
END SUB

