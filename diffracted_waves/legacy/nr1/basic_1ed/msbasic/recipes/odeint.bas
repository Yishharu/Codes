DECLARE SUB DERIVS (X!, Y!(), DYDX!())
DECLARE SUB RKQC (Y!(), DYDX!(), N!, X!, HTRY!, EPS!, YSCAL!(), HDID!, HNEXT!, DUM!)
COMMON SHARED KMAX, KOUNT, DXSAV, XP(), YP()

SUB ODEINT (YSTART(), NVAR, X1, X2, EPS, H1, HMIN, NOK, NBAD, DUM1, DUM2)
MAXSTP = 10000
TWO = 2!
ZERO = 0!
TINY = 1E-30
DIM YSCAL(NVAR), Y(NVAR), DYDX(NVAR)
X = X1
H = ABS(H1) * SGN(X2 - X1)
NOK = 0
NBAD = 0
KOUNT = 0
FOR I = 1 TO NVAR
  Y(I) = YSTART(I)
NEXT I
IF KMAX > 0 THEN XSAV = X - DXSAV * TWO
FOR NSTP = 1 TO MAXSTP
  CALL DERIVS(X, Y(), DYDX())
  FOR I = 1 TO NVAR
    YSCAL(I) = ABS(Y(I)) + ABS(H * DYDX(I)) + TINY
  NEXT I
  IF KMAX > 0 THEN
    IF ABS(X - XSAV) > ABS(DXSAV) THEN
      IF KOUNT < KMAX - 1 THEN
        KOUNT = KOUNT + 1
        XP(KOUNT) = X
        FOR I = 1 TO NVAR
          YP(I, KOUNT) = Y(I)
        NEXT I
        XSAV = X
      END IF
    END IF
  END IF
  IF (X + H - X2) * (X + H - X1) > ZERO THEN H = X2 - X
  CALL RKQC(Y(), DYDX(), NVAR, X, H, EPS, YSCAL(), HDID, HNEXT, DUM)
  IF HDID = H THEN
    NOK = NOK + 1
  ELSE
    NBAD = NBAD + 1
  END IF
  IF (X - X2) * (X2 - X1) >= ZERO THEN
    FOR I = 1 TO NVAR
      YSTART(I) = Y(I)
    NEXT I
    IF KMAX <> 0 THEN
      KOUNT = KOUNT + 1
      XP(KOUNT) = X
      FOR I = 1 TO NVAR
        YP(I, KOUNT) = Y(I)
      NEXT I
    END IF
    ERASE DYDX, Y, YSCAL
    EXIT SUB
  END IF
  IF ABS(HNEXT) < HMIN THEN PRINT "Stepsize smaller than minimum.": EXIT SUB
  H = HNEXT
NEXT NSTP
PRINT "Too many steps."
END SUB

