
SUB SOR (A#(), B#(), C#(), D#(), E#(), F#(), U#(), JMAX!, RJAC#)
DEFDBL A-H, O-Z
MAXITS = 1000
EPS = .00001#
ZERO = 0#
HALF = .5#
QTR = .25#
ONE = 1#
ANORMF = ZERO
FOR J = 2 TO JMAX - 1
  FOR L = 2 TO JMAX - 1
    ANORMF = ANORMF + ABS(F(J, L))
  NEXT L
NEXT J
OMEGA = ONE
FOR N = 1 TO MAXITS
  ANORM = ZERO
  FOR J = 2 TO JMAX - 1
    FOR L = 2 TO JMAX - 1
      IF (J + L) MOD 2 = N MOD 2 THEN
        RESID = A(J, L) * U(J + 1, L) + B(J, L) * U(J - 1, L)
        RESID = RESID + C(J, L) * U(J, L + 1) + D(J, L) * U(J, L - 1)
        RESID = RESID + E(J, L) * U(J, L) - F(J, L)
        ANORM = ANORM + ABS(RESID)
        U(J, L) = U(J, L) - OMEGA * RESID / E(J, L)
      END IF
    NEXT L
  NEXT J
  IF N = 1 THEN
    OMEGA = ONE / (ONE - HALF * RJAC ^ 2)
  ELSE
    OMEGA = ONE / (ONE - QTR * RJAC ^ 2 * OMEGA)
  END IF
  IF N > 1 AND ANORM < EPS * ANORMF THEN EXIT SUB
NEXT N
PRINT "MAXITS exceeded"
END SUB

