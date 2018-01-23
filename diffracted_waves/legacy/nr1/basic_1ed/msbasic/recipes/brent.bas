DECLARE FUNCTION BRENT! (AX!, BX!, CX!, DUM!, TOL!, XMIN!)
DECLARE FUNCTION FUNC! (X!)

FUNCTION BRENT (AX, BX, CX, DUM, TOL, XMIN)
ITMAX = 100
CGOLD = .381966#
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
FOR ITER = 1 TO ITMAX
  XM = .5 * (A + B)
  TOL1 = TOL * ABS(X) + ZEPS
  TOL2 = 2! * TOL1
  IF ABS(X - XM) <= TOL2 - .5 * (B - A) THEN EXIT FOR
  DONE% = -1
  IF ABS(E) > TOL1 THEN
    R = (X - W) * (FX - FV)
    Q = (X - V) * (FX - FW)
    P = (X - V) * Q - (X - W) * R
    Q = 2! * (Q - R)
    IF Q > 0! THEN P = -P
    Q = ABS(Q)
    ETEMP = E
    E = D
    DUM = ABS(.5 * Q * ETEMP)
    IF ABS(P) < DUM AND P > Q * (A - X) AND P < Q * (B - X) THEN
      D = P / Q
      U = X + D
      IF U - A < TOL2 OR B - U < TOL2 THEN D = ABS(TOL1) * SGN(XM - X)
      DONE% = 0
    END IF
  END IF
  IF DONE% THEN
    IF X >= XM THEN
      E = A - X
    ELSE
      E = B - X
    END IF
    D = CGOLD * E
  END IF
  IF ABS(D) >= TOL1 THEN
    U = X + D
  ELSE
    U = X + ABS(TOL1) * SGN(D)
  END IF
  FU = FUNC(U)
  IF FU <= FX THEN
    IF U >= X THEN
      A = X
    ELSE
      B = X
    END IF
    V = W
    FV = FW
    W = X
    FW = FX
    X = U
    FX = FU
  ELSE
    IF U < X THEN
      A = U
    ELSE
      B = U
    END IF
    IF FU <= FW OR W = X THEN
      V = W
      FV = FW
      W = U
      FW = FU
    ELSEIF FU <= FV OR V = X OR V = W THEN
      V = U
      FV = FU
    END IF
  END IF
NEXT ITER
IF ITER > ITMAX THEN PRINT "Brent exceed maximum iterations.": END
XMIN = X
BRENT = FX
END FUNCTION

