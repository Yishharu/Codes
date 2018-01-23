DECLARE FUNCTION FUNC! (X!)

SUB ZBRAC (DUM, X1, X2, SUCCES%)
FACTOR = 1.6
NTRY = 50
IF X1 = X2 THEN PRINT "You have to guess an initial range": EXIT SUB
F1 = FUNC(X1)
F2 = FUNC(X2)
SUCCES% = -1
FOR J = 1 TO NTRY
  IF F1 * F2 < 0! THEN EXIT SUB
  IF ABS(F1) < ABS(F2) THEN
    X1 = X1 + FACTOR * (X1 - X2)
    F1 = FUNC(X1)
  ELSE
    X2 = X2 + FACTOR * (X2 - X1)
    F2 = FUNC(X2)
  END IF
NEXT J
SUCCES% = 0
END SUB

