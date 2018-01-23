SUB SVDCMP (A(), M, N, MP, NP, W(), V())
DIM RV1(N)
IF M < N THEN PRINT "You must augment A with extra zero rows.": EXIT SUB
G = 0!
SCALE = 0!
ANORM = 0!
FOR I = 1 TO N
  L = I + 1
  RV1(I) = SCALE * G
  G = 0!
  S = 0!
  SCALE = 0!
  IF I <= M THEN
    FOR K = I TO M
      SCALE = SCALE + ABS(A(K, I))
    NEXT K
    IF SCALE <> 0! THEN
      FOR K = I TO M
        A(K, I) = A(K, I) / SCALE
        S = S + A(K, I) * A(K, I)
      NEXT K
      F = A(I, I)
      G = -ABS(SQR(S)) * SGN(F)
      H = F * G - S
      A(I, I) = F - G
      IF I <> N THEN
        FOR J = L TO N
          S = 0!
          FOR K = I TO M
            S = S + A(K, I) * A(K, J)
          NEXT K
          F = S / H
          FOR K = I TO M
            A(K, J) = A(K, J) + F * A(K, I)
          NEXT K
        NEXT J
      END IF
      FOR K = I TO M
        A(K, I) = SCALE * A(K, I)
      NEXT K
    END IF
  END IF
  W(I) = SCALE * G
  G = 0!
  S = 0!
  SCALE = 0!
  IF I <= M AND I <> N THEN
    FOR K = L TO N
      SCALE = SCALE + ABS(A(I, K))
    NEXT K
    IF SCALE <> 0! THEN
      FOR K = L TO N
        A(I, K) = A(I, K) / SCALE
        S = S + A(I, K) * A(I, K)
      NEXT K
      F = A(I, L)
      G = -ABS(SQR(S)) * SGN(F)
      H = F * G - S
      A(I, L) = F - G
      FOR K = L TO N
        RV1(K) = A(I, K) / H
      NEXT K
      IF I <> M THEN
        FOR J = L TO M
          S = 0!
          FOR K = L TO N
            S = S + A(J, K) * A(I, K)
          NEXT K
          FOR K = L TO N
            A(J, K) = A(J, K) + S * RV1(K)
          NEXT K
        NEXT J
      END IF
      FOR K = L TO N
        A(I, K) = SCALE * A(I, K)
      NEXT K
    END IF
  END IF
  IF ABS(W(I)) + ABS(RV1(I)) > ANORM THEN ANORM = ABS(W(I)) + ABS(RV1(I))
NEXT I
FOR I = N TO 1 STEP -1
  IF I < N THEN
    IF G <> 0! THEN
      FOR J = L TO N
        V(J, I) = (A(I, J) / A(I, L)) / G
      NEXT J
      FOR J = L TO N
        S = 0!
        FOR K = L TO N
          S = S + A(I, K) * V(K, J)
        NEXT K
        FOR K = L TO N
          V(K, J) = V(K, J) + S * V(K, I)
        NEXT K
      NEXT J
    END IF
    FOR J = L TO N
      V(I, J) = 0!
      V(J, I) = 0!
    NEXT J
  END IF
  V(I, I) = 1!
  G = RV1(I)
  L = I
NEXT I
FOR I = N TO 1 STEP -1
  L = I + 1
  G = W(I)
  IF I < N THEN
    FOR J = L TO N
      A(I, J) = 0!
    NEXT J
  END IF
  IF G <> 0! THEN
    G = 1! / G
    IF I <> N THEN
      FOR J = L TO N
        S = 0!
        FOR K = L TO M
          S = S + A(K, I) * A(K, J)
        NEXT K
        F = (S / A(I, I)) * G
        FOR K = I TO M
          A(K, J) = A(K, J) + F * A(K, I)
        NEXT K
      NEXT J
    END IF
    FOR J = I TO M
      A(J, I) = A(J, I) * G
    NEXT J
  ELSE
    FOR J = I TO M
      A(J, I) = 0!
    NEXT J
  END IF
  A(I, I) = A(I, I) + 1!
NEXT I
FOR K = N TO 1 STEP -1
  FOR ITS = 1 TO 30
    FOR L = K TO 1 STEP -1
      NM = L - 1
      IF ABS(RV1(L)) + ANORM = ANORM THEN EXIT FOR
      IF ABS(W(NM)) + ANORM = ANORM THEN EXIT FOR
    NEXT L
    IF ABS(RV1(L)) + ANORM <> ANORM THEN
      C = 0!
      S = 1!
      FOR I = L TO K
        F = S * RV1(I)
        RV1(I) = C * RV1(I)
        IF ABS(F) + ANORM <> ANORM THEN
          G = W(I)
          H = SQR(F * F + G * G)
          W(I) = H
          H = 1! / H
          C = G * H
          S = -F * H
          FOR J = 1 TO M
            Y = A(J, NM)
            Z = A(J, I)
            A(J, NM) = Y * C + Z * S
            A(J, I) = -Y * S + Z * C
          NEXT J
        END IF
      NEXT I
    END IF
    Z = W(K)
    IF L = K THEN
      IF Z < 0! THEN
        W(K) = -Z
        FOR J = 1 TO N
          V(J, K) = -V(J, K)
        NEXT J
      END IF
      EXIT FOR
    END IF
    IF ITS = 30 THEN PRINT "No convergence in 30 iterations": ERASE RV1: END
    X = W(L)
    NM = K - 1
    Y = W(NM)
    G = RV1(NM)
    H = RV1(K)
    F = ((Y - Z) * (Y + Z) + (G - H) * (G + H)) / (2! * H * Y)
    G = SQR(F * F + 1!)
    F = ((X - Z) * (X + Z) + H * ((Y / (F + ABS(G) * SGN(F))) - H)) / X
    C = 1!
    S = 1!
    FOR J = L TO NM
      I = J + 1
      G = RV1(I)
      Y = W(I)
      H = S * G
      G = C * G
      Z = SQR(F * F + H * H)
      RV1(J) = Z
      C = F / Z
      S = H / Z
      F = X * C + G * S
      G = -X * S + G * C
      H = Y * S
      Y = Y * C
      FOR JJ = 1 TO N
        X = V(JJ, J)
        Z = V(JJ, I)
        V(JJ, J) = X * C + Z * S
        V(JJ, I) = -X * S + Z * C
      NEXT JJ
      Z = SQR(F * F + H * H)
      W(J) = Z
      IF Z <> 0! THEN
        Z = 1! / Z
        C = F * Z
        S = H * Z
      END IF
      F = C * G + S * Y
      X = -S * G + C * Y
      FOR JJ = 1 TO M
        Y = A(JJ, J)
        Z = A(JJ, I)
        A(JJ, J) = Y * C + Z * S
        A(JJ, I) = -Y * S + Z * C
      NEXT JJ
    NEXT J
    RV1(L) = 0!
    RV1(K) = F
    W(K) = X
  NEXT ITS
NEXT K
ERASE RV1
END SUB

