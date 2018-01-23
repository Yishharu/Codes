DECLARE SUB DERIVS (X!, Y!(), DYDX!())
DECLARE SUB RK4 (Y!(), DYDX!(), N!, X!, H!, YOUT!(), DUM!)
COMMON SHARED XX(), Y()

SUB RKDUMB (VSTART(), NVAR, X1, X2, NSTEP, DUM)
DIM V(NVAR), DV(NVAR)
FOR I = 1 TO NVAR
  V(I) = VSTART(I)
  Y(I, 1) = V(I)
NEXT I
XX(1) = X1
X = X1
H = (X2 - X1) / CSNG(NSTEP)
FOR K = 1 TO NSTEP
  CALL DERIVS(X, V(), DV())
  CALL RK4(V(), DV(), NVAR, X, H, V(), DUM)
  IF X + H = X THEN PRINT "Stepsize not significant in RKDUMB.": EXIT SUB
  X = X + H
  XX(K + 1) = X
  FOR I = 1 TO NVAR
    Y(I, K + 1) = V(I)
  NEXT I
NEXT K
ERASE DV, V
END SUB

