SUB VANDER (X(), W(), Q(), N)
ZERO = 0!
ONE = 1!
DIM C(N)
IF N = 1 THEN
  W(1) = Q(1)
ELSE
  FOR I = 1 TO N
    C(I) = ZERO
  NEXT I
  C(N) = -X(1)
  FOR I = 2 TO N
    XX = -X(I)
    FOR J = N + 1 - I TO N - 1
      C(J) = C(J) + XX * C(J + 1)
    NEXT J
    C(N) = C(N) + XX
  NEXT I
  FOR I = 1 TO N
    XX = X(I)
    T = ONE
    B = ONE
    S = Q(N)
    K = N
    FOR J = 2 TO N
      K1 = K - 1
      B = C(K) + XX * B
      S = S + Q(K1) * B
      T = XX * T + B
      K = K1
    NEXT J
    W(I) = S / T
  NEXT I
END IF
ERASE C
END SUB

