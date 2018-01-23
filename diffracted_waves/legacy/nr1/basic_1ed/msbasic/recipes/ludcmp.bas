SUB LUDCMP (A(), N, NP, INDX(), D)
TINY = 1E-20
DIM VV(N)
D = 1!
FOR I = 1 TO N
  AAMAX = 0!
  FOR J = 1 TO N
    IF ABS(A(I, J)) > AAMAX THEN AAMAX = ABS(A(I, J))
  NEXT J
  IF AAMAX = 0! THEN PRINT "Singular matrix.": EXIT SUB
  VV(I) = 1! / AAMAX
NEXT I
FOR J = 1 TO N
  FOR I = 1 TO J - 1
    SUM = A(I, J)
    FOR K = 1 TO I - 1
      SUM = SUM - A(I, K) * A(K, J)
    NEXT K
    A(I, J) = SUM
  NEXT I
  AAMAX = 0!
  FOR I = J TO N
    SUM = A(I, J)
    FOR K = 1 TO J - 1
      SUM = SUM - A(I, K) * A(K, J)
    NEXT K
    A(I, J) = SUM
    DUM = VV(I) * ABS(SUM)
    IF DUM >= AAMAX THEN
      IMAX = I
      AAMAX = DUM
    END IF
  NEXT I
  IF J <> IMAX THEN
    FOR K = 1 TO N
      DUM = A(IMAX, K)
      A(IMAX, K) = A(J, K)
      A(J, K) = DUM
    NEXT K
    D = -D
    VV(IMAX) = VV(J)
  END IF
  INDX(J) = IMAX
  IF A(J, J) = 0! THEN A(J, J) = TINY
  IF J <> N THEN
    DUM = 1! / A(J, J)
    FOR I = J + 1 TO N
      A(I, J) = A(I, J) * DUM
    NEXT I
  END IF
NEXT J
ERASE VV
END SUB

