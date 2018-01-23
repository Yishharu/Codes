SUB ELMHES (A(), N, NP)
FOR M = 2 TO N - 1
  X = 0!
  I = M
  FOR J = M TO N
    IF ABS(A(J, M - 1)) > ABS(X) THEN
      X = A(J, M - 1)
      I = J
    END IF
  NEXT J
  IF I <> M THEN
    FOR J = M - 1 TO N
      Y = A(I, J)
      A(I, J) = A(M, J)
      A(M, J) = Y
    NEXT J
    FOR J = 1 TO N
      Y = A(J, I)
      A(J, I) = A(J, M)
      A(J, M) = Y
    NEXT J
  END IF
  IF X <> 0! THEN
    FOR I = M + 1 TO N
      Y = A(I, M - 1)
      IF Y <> 0! THEN
        Y = Y / X
        A(I, M - 1) = Y
        FOR J = M TO N
          A(I, J) = A(I, J) - Y * A(M, J)
        NEXT J
        FOR J = 1 TO N
          A(J, M) = A(J, M) + Y * A(J, I)
        NEXT J
      END IF
    NEXT I
  END IF
NEXT M
END SUB

