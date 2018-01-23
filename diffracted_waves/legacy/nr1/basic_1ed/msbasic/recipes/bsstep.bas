DECLARE SUB MMID (Y!(), DYDX!(), NVAR!, XS!, HTOT!, NSTEP!, YOUT!(), DUM!)
DECLARE SUB RZEXTR (IEST!, XEST!, YEST!(), YZ!(), DY!(), NV!, NUSE!)
COMMON SHARED X(), D()
DATA 2,4,6,8,12,16,24,32,48,64,96

SUB BSSTEP (Y(), DYDX(), NV, X, HTRY, EPS, YSCAL(), HDID, HNEXT, DUM)
IMAX = 11
NUSE = 7
ONE = 1!
SHRINK = .95
GROW = 1.2
DIM YERR(NV), YSAV(NV), DYSAV(NV), YSEQ(NV), NSEQ(IMAX)
RESTORE
FOR I = 1 TO IMAX
  READ NSEQ(I)
NEXT I
H = HTRY
XSAV = X
FOR I = 1 TO NV
  YSAV(I) = Y(I)
  DYSAV(I) = DYDX(I)
NEXT I
DO
  FOR I = 1 TO IMAX
    CALL MMID(YSAV(), DYSAV(), NV, XSAV, H, NSEQ(I), YSEQ(), DUM)
    XEST = (H / NSEQ(I)) ^ 2
    CALL RZEXTR(I, XEST, YSEQ(), Y(), YERR(), NV, NUSE)
    IF I > 3 THEN
      ERRMAX = 0!
      FOR J = 1 TO NV
        IF ABS(YERR(J) / YSCAL(J)) > ERRMAX THEN ERRMAX = ABS(YERR(J) / YSCAL(J))
      NEXT J
      ERRMAX = ERRMAX / EPS
      IF ERRMAX < ONE THEN
        X = X + H
        HDID = H
        IF I = NUSE THEN
          HNEXT = H * SHRINK
        ELSEIF I = NUSE - 1 THEN
          HNEXT = H * GROW
        ELSE
          HNEXT = (H * NSEQ(NUSE - 1)) / NSEQ(I)
        END IF
        ERASE NSEQ, YSEQ, DYSAV, YSAV, YERR
        EXIT SUB
      END IF
    END IF
  NEXT I
  H = .25 * H / 2 ^ ((IMAX - NUSE) / 2)
LOOP UNTIL X + H = X
PRINT "Step size underflow."
END SUB

