DECLARE SUB FPOLY (X!, P!(), NP!)
DECLARE SUB FLEG (X!, PL!(), NL!)
DECLARE SUB SVDCMP (A!(), M!, N!, MP!, NP!, W!(), V!())
DECLARE SUB SVBKSB (U!(), W!(), V!(), M!, N!, MP!, NP!, B!(), X!())

SUB SVDFIT (X(), Y(), SIG(), NDATA, A(), MA, U(), V(), W(), MP, NP, CHISQ, FUNCS$)
TOL = .00001
DIM B(NDATA), AFUNC(MA)
FOR I = 1 TO NDATA
  IF FUNCS$ = "FPOLY" THEN CALL FPOLY(X(I), AFUNC(), MA)
  IF FUNCS$ = "FLEG" THEN CALL FLEG(X(I), AFUNC(), MA)
  TMP = 1! / SIG(I)
  FOR J = 1 TO MA
    U(I, J) = AFUNC(J) * TMP
  NEXT J
  B(I) = Y(I) * TMP
NEXT I
CALL SVDCMP(U(), NDATA, MA, MP, NP, W(), V())
WMAX = 0!
FOR J = 1 TO MA
  IF W(J) > WMAX THEN WMAX = W(J)
NEXT J
THRESH = TOL * WMAX
FOR J = 1 TO MA
  IF W(J) < THRESH THEN W(J) = 0!
NEXT J
CALL SVBKSB(U(), W(), V(), NDATA, MA, MP, NP, B(), A())
CHISQ = 0!
FOR I = 1 TO NDATA
  IF FUNCS$ = "FPOLY" THEN CALL FPOLY(X(I), AFUNC(), MA)
  IF FUNCS$ = "FLEG" THEN CALL FLEG(X(I), AFUNC(), MA)
  SUM = 0!
  FOR J = 1 TO MA
    SUM = SUM + A(J) * AFUNC(J)
  NEXT J
  CHISQ = CHISQ + ((Y(I) - SUM) / SIG(I)) ^ 2
NEXT I
ERASE AFUNC, B
END SUB

