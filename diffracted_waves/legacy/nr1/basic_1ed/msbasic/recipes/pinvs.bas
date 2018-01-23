
SUB PINVS (IE1, IE2, JE1, JSF, JC1, K, C(), NCI, NCJ, NCK, S(), NSI, NSJ)
ZERO = 0!
ONE = 1!
NMAX = 10
DIM PSCL(NMAX), INDXR(NMAX)
JE2 = JE1 + IE2 - IE1
JS1 = JE2 + 1
FOR I = IE1 TO IE2
  BIG = ZERO
  FOR J = JE1 TO JE2
    IF ABS(S(I, J)) > BIG THEN BIG = ABS(S(I, J))
  NEXT J
  IF BIG = ZERO THEN PRINT "Singular matrix, row all 0": EXIT SUB
  PSCL(I) = ONE / BIG
  INDXR(I) = 0
NEXT I
FOR ID = IE1 TO IE2
  PIV = ZERO
  FOR I = IE1 TO IE2
    IF INDXR(I) = 0 THEN
      BIG = ZERO
      FOR J = JE1 TO JE2
        IF ABS(S(I, J)) > BIG THEN
          JP = J
          BIG = ABS(S(I, J))
        END IF
      NEXT J
      IF BIG * PSCL(I) > PIV THEN
        IPIV = I
        JPIV = JP
        PIV = BIG * PSCL(I)
      END IF
    END IF
  NEXT I
  IF S(IPIV, JPIV) = ZERO THEN PRINT "Singular matrix": EXIT SUB
  INDXR(IPIV) = JPIV
  PIVINV = ONE / S(IPIV, JPIV)
  FOR J = JE1 TO JSF
    S(IPIV, J) = S(IPIV, J) * PIVINV
  NEXT J
  S(IPIV, JPIV) = ONE
  FOR I = IE1 TO IE2
    IF INDXR(I) <> JPIV THEN
      IF S(I, JPIV) <> ZERO THEN
        DUM = S(I, JPIV)
        FOR J = JE1 TO JSF
          S(I, J) = S(I, J) - DUM * S(IPIV, J)
        NEXT J
        S(I, JPIV) = ZERO
      END IF
    END IF
  NEXT I
NEXT ID
JCOFF = JC1 - JS1
ICOFF = IE1 - JE1
FOR I = IE1 TO IE2
  IROW = INDXR(I) + ICOFF
  FOR J = JS1 TO JSF
    C(IROW, J + JCOFF, K) = S(I, J)
  NEXT J
NEXT I
ERASE INDXR, PSCL
END SUB

