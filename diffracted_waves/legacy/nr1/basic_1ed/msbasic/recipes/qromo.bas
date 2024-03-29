DECLARE SUB MIDINF (DUM!, AA!, BB!, S!, N!)
DECLARE SUB MIDSQL (DUM!, AA!, BB!, S!, N!)
DECLARE SUB MIDSQU (DUM!, AA!, BB!, S!, N!)
DECLARE SUB MIDPNT (DUM!, A!, B!, S!, N!)
DECLARE SUB POLINT (XA!(), YA!(), N!, X!, Y!, DY!)

SUB QROMO (DUM, A, B, SS, PICK$)
EPS = .00003
JMAX = 14
JMAXP = JMAX + 1
K = 5
KM = K - 1
DIM S(JMAXP), H(JMAXP)
H(1) = 1!
FOR J = 1 TO JMAX
  IF PICK$ = "MIDPNT" THEN CALL MIDPNT(DUM, A, B, S(J), J)
  IF PICK$ = "MIDINF" THEN CALL MIDINF(DUM, A, B, S(J), J)
  IF PICK$ = "MIDSQL" THEN CALL MIDSQL(DUM, A, B, S(J), J)
  IF PICK$ = "MIDSQU" THEN CALL MIDSQU(DUM, A, B, S(J), J)
  IF J >= K THEN
    CALL POLINT(H(), S(), K, 0!, SS, DSS)
    IF ABS(DSS) < EPS * ABS(SS) THEN ERASE H, S: EXIT SUB
  END IF
  S(J + 1) = S(J)
  H(J + 1) = H(J) / 9!
NEXT J
PRINT "Too many steps."
END SUB

