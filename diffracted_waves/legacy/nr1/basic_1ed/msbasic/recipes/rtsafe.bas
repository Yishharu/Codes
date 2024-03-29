DECLARE SUB FUNCD (X!, FQ!, DF!)
DECLARE FUNCTION RTSAFE! (FUNCD!, X1!, X2!, XACC!)

FUNCTION RTSAFE (DUM, X1, X2, XACC)
MAXIT = 100
CALL FUNCD(X1, FL, DF)
CALL FUNCD(X2, FH, DF)
IF FL * FH >= 0! THEN PRINT "root must be bracketed": EXIT FUNCTION
IF FL < 0! THEN
  XL = X1
  XH = X2
ELSE
  XH = X1
  XL = X2
END IF
TRTSAFE = .5 * (X1 + X2)
DXOLD = ABS(X2 - X1)
DX = DXOLD
CALL FUNCD(TRTSAFE, F, DF)
FOR J = 1 TO MAXIT
  DUM = ((TRTSAFE - XH) * DF - F) * ((TRTSAFE - XL) * DF - F)
  IF DUM >= 0! OR ABS(2! * F) > ABS(DXOLD * DF) THEN
    DXOLD = DX
    DX = .5 * (XH - XL)
    TRTSAFE = XL + DX
    RTSAFE = TRTSAFE
    IF XL = TRTSAFE THEN EXIT FUNCTION
  ELSE
    DXOLD = DX
    DX = F / DF
    TEMP = TRTSAFE
    TRTSAFE = TRTSAFE - DX
    RTSAFE = TRTSAFE
    IF TEMP = TRTSAFE THEN EXIT FUNCTION
  END IF
  RTSAFE = TRTSAFE
  IF ABS(DX) < XACC THEN EXIT FUNCTION
  CALL FUNCD(TRTSAFE, F, DF)
  IF F < 0! THEN
    XL = TRTSAFE
  ELSE
    XH = TRTSAFE
  END IF
NEXT J
PRINT "RTSAFE exceeding maximum iterations"
END FUNCTION

