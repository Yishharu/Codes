
SUB TRED2 (A(), N, NP, D(), E())
FOR I = N TO 2 STEP -1
  L = I - 1
  H = 0!
  SCALE = 0!
  IF L > 1 THEN
    FOR K = 1 TO L
      SCALE = SCALE + ABS(A(I, K))
    NEXT K
    IF SCALE = 0! THEN
      E(I) = A(I, L)
    ELSE
      FOR K = 1 TO L
        A(I, K) = A(I, K) / SCALE
        H = H + A(I, K) ^ 2
      NEXT K
      F = A(I, L)
      G = -ABS(SQR(H)) * SGN(F)
      E(I) = SCALE * G
      H = H - F * G
      A(I, L) = F - G
      F = 0!
      FOR J = 1 TO L
' Omit following line if finding only eigenvalues
        A(J, I) = A(I, J) / H
        G = 0!
        FOR K = 1 TO J
          G = G + A(J, K) * A(I, K)
        NEXT K
        FOR K = J + 1 TO L
          G = G + A(K, J) * A(I, K)
        NEXT K
        E(J) = G / H
        F = F + E(J) * A(I, J)
      NEXT J
      HH = F / (H + H)
      FOR J = 1 TO L
        F = A(I, J)
        G = E(J) - HH * F
        E(J) = G
        FOR K = 1 TO J
          A(J, K) = A(J, K) - F * E(K) - G * A(I, K)
        NEXT K
      NEXT J
    END IF
  ELSE
    E(I) = A(I, L)
  END IF
  D(I) = H
NEXT I
' Omit following line if finding only eigenvalues
D(1) = 0!
E(1) = 0!
FOR I = 1 TO N
' Delete lines from here ...
  L = I - 1
  IF D(I) <> 0! THEN
    FOR J = 1 TO L
      G = 0!
      FOR K = 1 TO L
        G = G + A(I, K) * A(K, J)
      NEXT K
      FOR K = 1 TO L
        A(K, J) = A(K, J) - G * A(K, I)
      NEXT K
    NEXT J
  END IF
' ... to here when finding only eigenvalues.
  D(I) = A(I, I)
' Also delete lines from here ...
  A(I, I) = 1!
  FOR J = 1 TO L
    A(I, J) = 0!
    A(J, I) = 0!
  NEXT J
' ... to here when finding only eigenvalues.
NEXT I
END SUB

