DECLARE SUB BCUCOF (Y!(), Y1!(), Y2!(), Y12!(), D1!, D2!, C!())

SUB BCUINT (Y(), Y1(), Y2(), Y12(), X1L, X1U, X2L, X2U, X1, X2, ANSY, ANSY1, ANSY2)
DIM C(4, 4)
CALL BCUCOF(Y(), Y1(), Y2(), Y12(), X1U - X1L, X2U - X2L, C())
IF X1U = X1L OR X2U = X2L THEN PRINT "bad input": EXIT SUB
T = (X1 - X1L) / (X1U - X1L)
U = (X2 - X2L) / (X2U - X2L)
ANSY = 0!
ANSY2 = 0!
ANSY1 = 0!
FOR I = 4 TO 1 STEP -1
  ANSY = T * ANSY + ((C(I, 4) * U + C(I, 3)) * U + C(I, 2)) * U + C(I, 1)
  ANSY2 = T * ANSY2 + (3! * C(I, 4) * U + 2! * C(I, 3)) * U + C(I, 2)
  ANSY1 = U * ANSY1 + (3! * C(4, I) * T + 2! * C(3, I)) * T + C(2, I)
NEXT I
ANSY1 = ANSY1 / (X1U - X1L)
ANSY2 = ANSY2 / (X2U - X2L)
ERASE C
END SUB

