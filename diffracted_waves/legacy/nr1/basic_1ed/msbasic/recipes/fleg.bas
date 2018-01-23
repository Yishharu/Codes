SUB FLEG (X, PL(), NL)
PL(1) = 1!
PL(2) = X
IF NL > 2 THEN
  TWOX = 2! * X
  F2 = X
  D = 1!
  FOR J = 3 TO NL
    F1 = D
    F2 = F2 + TWOX
    D = D + 1!
    PL(J) = (F2 * PL(J - 1) - F1 * PL(J - 2)) / D
  NEXT J
END IF
END SUB

