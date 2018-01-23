DECLARE FUNCTION DBRENT! (AX!, BX!, CX!, DUM!, DUM!, TOL!, XMIN!)
DECLARE FUNCTION FUNC! (X!)
DECLARE FUNCTION DF! (X!)

FUNCTION DBRENT (AX, BX, CX, DUM1, DUM2, TOL, XMIN)
ITMAX = 100
ZEPS = 1E-10
A = AX
IF CX < AX THEN A = CX
B = AX
IF CX > AX THEN B = CX
V = BX
W = V
X = V
E = 0!
FX = FUNC(X)
FV = FX
FW = FX
DX = DF(X)
DV = DX
DW = DX
FOR ITER = 1 TO ITMAX
  XM = .5 * (A + B)
  TOL1 = TOL * ABS(X) + ZEPS
  TOL2 = 2! * TOL1
  IF ABS(X - XM) <= TOL2 - .5 * (B - A) THEN
    DONE% = -1
    EXIT FOR
  ELSE
    DONE% = 0
  END IF
  IF ABS(E) > TOL1 THEN
    D1 = 2! * (B - A)
    D2 = D1
    IF DW <> DX THEN D1 = (W - X) * DX / (DX - DW)
    IF DV <> DX THEN D2 = (V - X) * DX / (DX - DV)
    U1 = X + D1
    U2 = X + D2
    OK1% = ((A - U1) * (U1 - B) > 0!) AND (DX * D1 <= 0!)
    OK2% = ((A - U2) * (U2 - B) > 0!) AND (DX * D2 <= 0!)
    OLDE = E
    E = D
    IF OK1% OR OK2% THEN
      IF OK1% AND OK2% THEN
        IF ABS(D1) < ABS(D2) THEN
          D = D1
        ELSE
          D = D2
        END IF
      ELSEIF OK1% THEN
        D = D1
      ELSE
        D = D2
      END IF
      IF ABS(D) <= ABS(.5 * OLDE) THEN
        U = X + D
        IF U - A < TOL2 OR B - U < TOL2 THEN D = ABS(TOL1) * SGN(XM - X)
      END IF
    END IF
  END IF
  IF DX >= 0! THEN
    E = A - X
  ELSE
    E = B - X
  END IF
  D = .5 * E
  IF ABS(D) >= TOL1 THEN
    U = X + D
    FU = FUNC(U)
  ELSE
    U = X + ABS(TOL1) * SGN(D)
    FU = FUNC(U)
    IF FU > FX THEN
      DONE% = -1
      EXIT FOR
    ELSE
      DONE% = 0
    END IF
  END IF
  DU = DF(U)
  IF FU <= FX THEN
    IF U >= X THEN
      A = X
    ELSE
      B = X
    END IF
    V = W
    FV = FW
    DV = DW
    W = X
    FW = FX
    DW = DX
    X = U
    FX = FU
    DX = DU
  ELSE
    IF U < X THEN
      A = U
    ELSE
      B = U
    END IF
    IF FU <= FW OR W = X THEN
      V = W
      FV = FW
      DV = DW
      W = U
      FW = FU
      DW = DU
    ELSEIF FU <= FV OR V = X OR V = W THEN
      V = U
      FV = FU
      DV = DU
    END IF
  END IF
NEXT ITER
IF NOT DONE% THEN
  PRINT "DBRENT exceeded maximum iterations."
ELSE
  XMIN = X
  DBRENT = FX
END IF
END FUNCTION

