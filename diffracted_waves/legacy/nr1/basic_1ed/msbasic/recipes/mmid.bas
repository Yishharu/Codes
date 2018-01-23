DECLARE SUB DERIVS (X!, Y!(), DYDX!())

SUB MMID (Y(), DYDX(), NVAR, XS, HTOT, NSTEP, YOUT(), DUM)
DIM YM(NVAR), YN(NVAR)
H = HTOT / NSTEP
FOR I = 1 TO NVAR
  YM(I) = Y(I)
  YN(I) = Y(I) + H * DYDX(I)
NEXT I
X = XS + H
CALL DERIVS(X, YN(), YOUT())
H2 = 2! * H
FOR N = 2 TO NSTEP
  FOR I = 1 TO NVAR
    SWAQ = YM(I) + H2 * YOUT(I)
    YM(I) = YN(I)
    YN(I) = SWAQ
  NEXT I
  X = X + H
  CALL DERIVS(X, YN(), YOUT())
NEXT N
FOR I = 1 TO NVAR
  YOUT(I) = .5 * (YM(I) + YN(I) + H * YOUT(I))
NEXT I
ERASE YN, YM
END SUB

