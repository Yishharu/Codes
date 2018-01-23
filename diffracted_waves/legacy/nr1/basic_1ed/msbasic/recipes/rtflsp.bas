DECLARE FUNCTION RTFLSP! (DUM!, X1!, X2!, XACC!)
DECLARE FUNCTION FUNC! (X!)

FUNCTION RTFLSP (DUM, X1, X2, XACC)
MAXIT = 30
FL = FUNC(X1)
FH = FUNC(X2)
IF FL * FH > 0! THEN
  PRINT "Root must be bracketed for false position."
  EXIT FUNCTION
END IF
IF FL < 0! THEN
  XL = X1
  XH = X2
ELSE
  XL = X2
  XH = X1
  SWAP FL, FH
END IF
DX = XH - XL
FOR J = 1 TO MAXIT
  TRTFLSP = XL + DX * FL / (FL - FH)
  F = FUNC(TRTFLSP)
  IF F < 0! THEN
    DEL = XL - TRTFLSP
    XL = TRTFLSP
    FL = F
  ELSE
    DEL = XH - TRTFLSP
    XH = TRTFLSP
    FH = F
  END IF
  DX = XH - XL
  RTFLSP = TRTFLSP
  IF ABS(DEL) < XACC OR F = 0! THEN EXIT FUNCTION
NEXT J
PRINT "RTFLSP exceed maximum iterations"
END FUNCTION

