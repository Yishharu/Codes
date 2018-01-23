
SUB TQLI (D(), E(), N, NP, Z())
FOR I = 2 TO N
  E(I - 1) = E(I)
NEXT I
E(N) = 0!
FOR L = 1 TO N
  ITER = 0
  DO
    DONE% = -1
    FOR M = L TO N - 1
      DD = ABS(D(M)) + ABS(D(M + 1))
      IF ABS(E(M)) + DD = DD THEN EXIT FOR
    NEXT M
    IF ABS(E(M)) + DD <> DD THEN M = N
    IF M <> L THEN
      IF ITER = 30 THEN PRINT "too many iterations": EXIT SUB
      ITER = ITER + 1
      G = (D(L + 1) - D(L)) / (2! * E(L))
      R = SQR(G ^ 2 + 1!)
      G = D(M) - D(L) + E(L) / (G + ABS(R) * SGN(G))
      S = 1!
      C = 1!
      P = 0!
      FOR I = M - 1 TO L STEP -1
        F = S * E(I)
        B = C * E(I)
        IF ABS(F) >= ABS(G) THEN
          C = G / F
          R = SQR(C ^ 2 + 1!)
          E(I + 1) = F * R
          S = 1! / R
          C = C * S
        ELSE
          S = F / G
          R = SQR(S ^ 2 + 1!)
          E(I + 1) = G * R
          C = 1! / R
          S = S * C
        END IF
        G = D(I + 1) - P
        R = (D(I) - G) * S + 2! * C * B
        P = S * R
        D(I + 1) = G + P
        G = C * R - B
' Omit lines from here ...
        FOR K = 1 TO N
          F = Z(K, I + 1)
          Z(K, I + 1) = S * Z(K, I) + C * F
          Z(K, I) = C * Z(K, I) - S * F
        NEXT K
' ... to here when finding only eigenvalues.
      NEXT I
      D(L) = D(L) - P
      E(L) = G
      E(M) = 0!
      DONE% = 0
    END IF
  LOOP WHILE NOT DONE%
NEXT L
END SUB

