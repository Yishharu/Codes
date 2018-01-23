SUB EIGSRT (D(), V(), N, NP)
FOR I = 1 TO N - 1
  K = I
  P = D(I)
  FOR J = I + 1 TO N
    IF D(J) >= P THEN
      K = J
      P = D(J)
    END IF
  NEXT J
  IF K <> I THEN
    D(K) = D(I)
    D(I) = P
    FOR J = 1 TO N
      P = V(J, I)
      V(J, I) = V(J, K)
      V(J, K) = P
    NEXT J
  END IF
NEXT I
END SUB

