SUB GAUSSJ (A(), N, NP, B(), M, MP)
DIM IPIV(N), INDXR(N), INDXC(N)
FOR J = 1 TO N
  IPIV(J) = 0
NEXT J
FOR I = 1 TO N
  BIG = 0!
  FOR J = 1 TO N
    IF IPIV(J) <> 1 THEN
      FOR K = 1 TO N
        IF IPIV(K) = 0 THEN
          IF ABS(A(J, K)) >= BIG THEN
            BIG = ABS(A(J, K))
            IROW = J
            ICOL = K
          END IF
        ELSEIF IPIV(K) > 1 THEN
          PRINT "Singular matrix"
          EXIT SUB
        END IF
      NEXT K
    END IF
  NEXT J
  IPIV(ICOL) = IPIV(ICOL) + 1
  IF IROW <> ICOL THEN
    FOR L = 1 TO N
      DUM = A(IROW, L)
      A(IROW, L) = A(ICOL, L)
      A(ICOL, L) = DUM
    NEXT L
    FOR L = 1 TO M
      DUM = B(IROW, L)
      B(IROW, L) = B(ICOL, L)
      B(ICOL, L) = DUM
    NEXT L
  END IF
  INDXR(I) = IROW
  INDXC(I) = ICOL
  IF A(ICOL, ICOL) = 0! THEN PRINT "Singular matrix.": EXIT SUB
  PIVINV = 1! / A(ICOL, ICOL)
  A(ICOL, ICOL) = 1!
  FOR L = 1 TO N
    A(ICOL, L) = A(ICOL, L) * PIVINV
  NEXT L
  FOR L = 1 TO M
    B(ICOL, L) = B(ICOL, L) * PIVINV
  NEXT L
  FOR LL = 1 TO N
    IF LL <> ICOL THEN
      DUM = A(LL, ICOL)
      A(LL, ICOL) = 0!
      FOR L = 1 TO N
        A(LL, L) = A(LL, L) - A(ICOL, L) * DUM
      NEXT L
      FOR L = 1 TO M
        B(LL, L) = B(LL, L) - B(ICOL, L) * DUM
      NEXT L
    END IF
  NEXT LL
NEXT I
FOR L = N TO 1 STEP -1
  IF INDXR(L) <> INDXC(L) THEN
    FOR K = 1 TO N
      DUM = A(K, INDXR(L))
      A(K, INDXR(L)) = A(K, INDXC(L))
      A(K, INDXC(L)) = DUM
    NEXT K
  END IF
NEXT L
ERASE INDXC, INDXR, IPIV
END SUB

