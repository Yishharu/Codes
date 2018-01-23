
SUB JACOBI (A(), N, NP, D(), V(), NROT)
DIM B(N), Z(N)
FOR IP = 1 TO N
  FOR IQ = 1 TO N
    V(IP, IQ) = 0!
  NEXT IQ
  V(IP, IP) = 1!
NEXT IP
FOR IP = 1 TO N
  B(IP) = A(IP, IP)
  D(IP) = B(IP)
  Z(IP) = 0!
NEXT IP
NROT = 0
FOR I = 1 TO 50
  SM = 0!
  FOR IP = 1 TO N - 1
    FOR IQ = IP + 1 TO N
      SM = SM + ABS(A(IP, IQ))
    NEXT IQ
  NEXT IP
  IF SM = 0 THEN ERASE Z, B: EXIT SUB
  IF I < 4 THEN
    TRESH = .2 * SM / N ^ 2
  ELSE
    TRESH = 0!
  END IF
  FOR IP = 1 TO N - 1
    FOR IQ = IP + 1 TO N
      G = 100! * ABS(A(IP, IQ))
      DUM = ABS(D(IP))
      IF I > 4 AND DUM + G = DUM AND ABS(D(IQ)) + G = ABS(D(IQ)) THEN
        A(IP, IQ) = 0!
      ELSEIF ABS(A(IP, IQ)) > TRESH THEN
        H = D(IQ) - D(IP)
        IF ABS(H) + G = ABS(H) THEN
          T = A(IP, IQ) / H
        ELSE
          THETA = .5 * H / A(IP, IQ)
          T = 1! / (ABS(THETA) + SQR(1! + THETA ^ 2))
          IF THETA < 0! THEN T = -T
        END IF
        C = 1! / SQR(1 + T ^ 2)
        S = T * C
        TAU = S / (1! + C)
        H = T * A(IP, IQ)
        Z(IP) = Z(IP) - H
        Z(IQ) = Z(IQ) + H
        D(IP) = D(IP) - H
        D(IQ) = D(IQ) + H
        A(IP, IQ) = 0!
        FOR J = 1 TO IP - 1
          G = A(J, IP)
          H = A(J, IQ)
          A(J, IP) = G - S * (H + G * TAU)
          A(J, IQ) = H + S * (G - H * TAU)
        NEXT J
        FOR J = IP + 1 TO IQ - 1
          G = A(IP, J)
          H = A(J, IQ)
          A(IP, J) = G - S * (H + G * TAU)
          A(J, IQ) = H + S * (G - H * TAU)
        NEXT J
        FOR J = IQ + 1 TO N
          G = A(IP, J)
          H = A(IQ, J)
          A(IP, J) = G - S * (H + G * TAU)
          A(IQ, J) = H + S * (G - H * TAU)
        NEXT J
        FOR J = 1 TO N
          G = V(J, IP)
          H = V(J, IQ)
          V(J, IP) = G - S * (H + G * TAU)
          V(J, IQ) = H + S * (G - H * TAU)
        NEXT J
        NROT = NROT + 1
      END IF
    NEXT IQ
  NEXT IP
  FOR IP = 1 TO N
    B(IP) = B(IP) + Z(IP)
    D(IP) = B(IP)
    Z(IP) = 0!
  NEXT IP
NEXT I
PRINT "50 iterations should never happen"
END SUB

