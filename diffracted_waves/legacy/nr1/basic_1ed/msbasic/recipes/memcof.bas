SUB MEMCOF (DATQ(), N, M, PM, COF(), WK1(), WK2(), WKM())
P = 0!
FOR J = 1 TO N
  P = P + DATQ(J) ^ 2
NEXT J
PM = P / N
WK1(1) = DATQ(1)
WK2(N - 1) = DATQ(N)
FOR J = 2 TO N - 1
  WK1(J) = DATQ(J)
  WK2(J - 1) = DATQ(J)
NEXT J
FOR K = 1 TO M
  PNEUM = 0!
  DENOM = 0!
  FOR J = 1 TO N - K
    PNEUM = PNEUM + WK1(J) * WK2(J)
    DENOM = DENOM + WK1(J) ^ 2 + WK2(J) ^ 2
  NEXT J
  COF(K) = 2! * PNEUM / DENOM
  PM = PM * (1! - COF(K) ^ 2)
  FOR I = 1 TO K - 1
    COF(I) = WKM(I) - COF(K) * WKM(K - I)
  NEXT I
  IF K = M THEN EXIT SUB
  FOR I = 1 TO K
    WKM(I) = COF(I)
  NEXT I
  FOR J = 1 TO N - K - 1
    WK1(J) = WK1(J) - WKM(K) * WK2(J)
    WK2(J) = WK2(J + 1) - WKM(K) * WK1(J + 1)
  NEXT J
NEXT K
PRINT "never get here"
END SUB

