COMMON SHARED X(), D()

SUB RZEXTR (IEST, XEST, YEST(), YZ(), DY(), NV, NUSE)
DIM FX(NUSE)
X(IEST) = XEST
IF IEST = 1 THEN
  FOR J = 1 TO NV
    YZ(J) = YEST(J)
    D(J, 1) = YEST(J)
    DY(J) = YEST(J)
  NEXT J
ELSE
  M1 = IEST
  IF NUSE < IEST THEN M1 = NUSE
  FOR K = 1 TO M1 - 1
    FX(K + 1) = X(IEST - K) / XEST
  NEXT K
  FOR J = 1 TO NV
    YY = YEST(J)
    V = D(J, 1)
    C = YY
    D(J, 1) = YY
    FOR K = 2 TO M1
      B1 = FX(K) * V
      B = B1 - C
      IF B <> 0! THEN
        B = (C - V) / B
        DDY = C * B
        C = B1 * B
      ELSE
        DDY = V
      END IF
      IF K <> M1 THEN V = D(J, K)
      D(J, K) = DDY
      YY = YY + DDY
    NEXT K
    DY(J) = DDY
    YZ(J) = YY
  NEXT J
END IF
ERASE FX
END SUB

