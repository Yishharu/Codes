DECLARE SUB ZROOTS (A!(), M!, ROOTS!(), POLISH%)

SUB FIXRTS (D(), NPOLES)
DIM A(2, NPOLES + 1), ROOTS(2, NPOLES + 1) 'Complex numbers
A(1, NPOLES + 1) = 1!
A(2, NPOLES + 1) = 0!
FOR J = NPOLES TO 1 STEP -1
  A(1, J) = -D(NPOLES + 1 - J)
  A(2, J) = 0!
NEXT J
POLISH% = -1
CALL ZROOTS(A(), NPOLES, ROOTS(), POLISH%)
FOR J = 1 TO NPOLES
  IF SQR(ROOTS(1, J) ^ 2 + ROOTS(2, J) ^ 2) > 1! THEN
    DUM = ROOTS(1, J)
    ROOTS(1, J) = DUM / (DUM ^ 2 + ROOTS(2, J) ^ 2)
    ROOTS(2, J) = ROOTS(2, J) / (DUM ^ 2 + ROOTS(2, J) ^ 2)
  END IF
NEXT J
A(1, 1) = -ROOTS(1, 1)
A(2, 1) = -ROOTS(2, 1)
A(1, 2) = 1!
A(2, 2) = 0!
FOR J = 2 TO NPOLES
  A(1, J + 1) = 1!
  A(2, J + 1) = 0!
  FOR I = J TO 2 STEP -1
    DUM = A(1, I)
    A(1, I) = A(1, I - 1) - (ROOTS(1, J) * DUM - ROOTS(2, J) * A(2, I))
    A(2, I) = A(2, I - 1) - (ROOTS(2, J) * DUM + ROOTS(1, J) * A(2, I))
  NEXT I
  DUM = A(1, 1)
  A(1, 1) = -(ROOTS(1, J) * DUM - ROOTS(2, J) * A(2, 1))
  A(2, 1) = -(ROOTS(2, J) * DUM + ROOTS(1, J) * A(2, 1))
NEXT J
FOR J = 1 TO NPOLES
  D(NPOLES + 1 - J) = -A(1, J)
NEXT J
ERASE ROOTS, A
END SUB

