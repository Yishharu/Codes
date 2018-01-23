DECLARE SUB TRAPZD (DUM!, A!, B!, S!, N!)
DECLARE SUB POLINT (XA!(), YA!(), N!, X!, Y!, DY!)

SUB QROMB (DUM, A, B, SS)
EPS = .000001
JMAX = 20
JMAXP = JMAX + 1
K = 5
KM = K - 1
DIM S(JMAXP), H(JMAXP)
H(1) = 1!
FOR J = 1 TO JMAX
  CALL TRAPZD(DUM, A, B, S(J), J)
  IF J >= K THEN
    CALL POLINT(H(), S(), K, 0!, SS, DSS)
    IF ABS(DSS) < EPS * ABS(SS) THEN ERASE H, S: EXIT SUB
  END IF
  S(J + 1) = S(J)
  H(J + 1) = .25 * H(J)
NEXT J
PRINT "Too many steps."
END SUB

