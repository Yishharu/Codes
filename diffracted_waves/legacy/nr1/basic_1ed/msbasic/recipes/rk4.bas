DECLARE SUB DERIVS (X!, Y!(), DYDX!())

SUB RK4 (Y(), DYDX(), N, X, H, YOUT(), DUM)
DIM YT(N), DYT(N), DYM(N)
HH = H * .5
H6 = H / 6!
XH = X + HH
FOR I = 1 TO N
  YT(I) = Y(I) + HH * DYDX(I)
NEXT I
CALL DERIVS(XH, YT(), DYT())
FOR I = 1 TO N
  YT(I) = Y(I) + HH * DYT(I)
NEXT I
CALL DERIVS(XH, YT(), DYM())
FOR I = 1 TO N
  YT(I) = Y(I) + H * DYM(I)
  DYM(I) = DYT(I) + DYM(I)
NEXT I
CALL DERIVS(X + H, YT(), DYT())
FOR I = 1 TO N
  YOUT(I) = Y(I) + H6 * (DYDX(I) + DYT(I) + 2! * DYM(I))
NEXT I
ERASE DYM, DYT, YT
END SUB

