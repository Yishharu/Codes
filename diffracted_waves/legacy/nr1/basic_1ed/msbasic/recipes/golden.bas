DECLARE FUNCTION GOLDEN! (AX!, BX!, CX!, DUM!, TOL!, XMIN!)
DECLARE FUNCTION FUNC! (X!)

FUNCTION GOLDEN (AX, BX, CX, DUM, TOL, XMIN)
R = .61803399#
C = .38196602#
X0 = AX
X3 = CX
IF ABS(CX - BX) > ABS(BX - AX) THEN
  X1 = BX
  X2 = BX + C * (CX - BX)
ELSE
  X2 = BX
  X1 = BX - C * (BX - AX)
END IF
F1 = FUNC(X1)
F2 = FUNC(X2)
WHILE ABS(X3 - X0) > TOL * (ABS(X1) + ABS(X2))
  IF F2 < F1 THEN
    X0 = X1
    X1 = X2
    X2 = R * X1 + C * X3
    F1 = F2
    F2 = FUNC(X2)
  ELSE
    X3 = X2
    X2 = X1
    X1 = R * X2 + C * X0
    F2 = F1
    F1 = FUNC(X1)
  END IF
WEND
IF F1 < F2 THEN
  GOLDEN = F1
  XMIN = X1
ELSE
  GOLDEN = F2
  XMIN = X2
END IF
END FUNCTION

