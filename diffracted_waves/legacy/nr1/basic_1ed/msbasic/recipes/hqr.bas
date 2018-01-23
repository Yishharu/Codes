SUB HQR (A(), N, NP, WR(), WI())
ANORM = ABS(A(1, 1))
FOR I = 2 TO N
  FOR J = I - 1 TO N
    ANORM = ANORM + ABS(A(I, J))
  NEXT J
NEXT I
NN = N
T = 0!
WHILE NN >= 1
  ITS = 0
  DO
    DONE% = -1
    FOR L = NN TO 2 STEP -1
      S = ABS(A(L - 1, L - 1)) + ABS(A(L, L))
      IF S = 0! THEN S = ANORM
      IF ABS(A(L, L - 1)) + S = S THEN EXIT FOR
    NEXT L
    IF ABS(A(L, L - 1)) + S <> S THEN L = 1
    X = A(NN, NN)
    IF L = NN THEN
      WR(NN) = X + T
      WI(NN) = 0!
      NN = NN - 1
    ELSE
      Y = A(NN - 1, NN - 1)
      W = A(NN, NN - 1) * A(NN - 1, NN)
      IF L = NN - 1 THEN
        P = .5 * (Y - X)
        Q = P ^ 2 + W
        Z = SQR(ABS(Q))
        X = X + T
        IF Q >= 0! THEN
          Z = P + ABS(Z) * SGN(P)
          WR(NN) = X + Z
          WR(NN - 1) = WR(NN)
          IF Z <> 0! THEN WR(NN) = X - W / Z
          WI(NN) = 0!
          WI(NN - 1) = 0!
        ELSE
          WR(NN) = X + P
          WR(NN - 1) = WR(NN)
          WI(NN) = Z
          WI(NN - 1) = -Z
        END IF
        NN = NN - 2
      ELSE
        IF ITS = 30 THEN PRINT "too many iterations": EXIT SUB
        IF ITS = 10 OR ITS = 20 THEN
          T = T + X
          FOR I = 1 TO NN
            A(I, I) = A(I, I) - X
          NEXT I
          S = ABS(A(NN, NN - 1)) + ABS(A(NN - 1, NN - 2))
          X = .75 * S
          Y = X
          W = -.4375 * S ^ 2
        END IF
        ITS = ITS + 1
        FOR M = NN - 2 TO L STEP -1
          Z = A(M, M)
          R = X - Z
          S = Y - Z
          P = (R * S - W) / A(M + 1, M) + A(M, M + 1)
          Q = A(M + 1, M + 1) - Z - R - S
          R = A(M + 2, M + 1)
          S = ABS(P) + ABS(Q) + ABS(R)
          P = P / S
          Q = Q / S
          R = R / S
          IF M = L THEN EXIT FOR
          U = ABS(A(M, M - 1)) * (ABS(Q) + ABS(R))
          V = ABS(P) * (ABS(A(M - 1, M - 1)) + ABS(Z) + ABS(A(M + 1, M + 1)))
          IF U + V = V THEN EXIT FOR
        NEXT M
        FOR I = M + 2 TO NN
          A(I, I - 2) = 0!
          IF I <> M + 2 THEN A(I, I - 3) = 0!
        NEXT I
        FOR K = M TO NN - 1
          IF K <> M THEN
            P = A(K, K - 1)
            Q = A(K + 1, K - 1)
            R = 0!
            IF K <> NN - 1 THEN R = A(K + 2, K - 1)
            X = ABS(P) + ABS(Q) + ABS(R)
            IF X <> 0! THEN
              P = P / X
              Q = Q / X
              R = R / X
            END IF
          END IF
          S = ABS(SQR(P ^ 2 + Q ^ 2 + R ^ 2)) * SGN(P)
          IF S <> 0! THEN
            IF K = M THEN
              IF L <> M THEN A(K, K - 1) = -A(K, K - 1)
            ELSE
              A(K, K - 1) = -S * X
            END IF
            P = P + S
            X = P / S
            Y = Q / S
            Z = R / S
            Q = Q / P
            R = R / P
            FOR J = K TO NN
              P = A(K, J) + Q * A(K + 1, J)
              IF K <> NN - 1 THEN
                P = P + R * A(K + 2, J)
                A(K + 2, J) = A(K + 2, J) - P * Z
              END IF
              A(K + 1, J) = A(K + 1, J) - P * Y
              A(K, J) = A(K, J) - P * X
            NEXT J
            NTMP = NN
            IF K + 3 < NN THEN NTMP = K + 3
            FOR I = L TO NTMP
              P = X * A(I, K) + Y * A(I, K + 1)
              IF K <> NN - 1 THEN
                P = P + Z * A(I, K + 2)
                A(I, K + 2) = A(I, K + 2) - P * R
              END IF
              A(I, K + 1) = A(I, K + 1) - P * Q
              A(I, K) = A(I, K) - P
            NEXT I
          END IF
        NEXT K
        DONE% = 0
      END IF
    END IF
  LOOP WHILE NOT DONE%
WEND
END SUB

