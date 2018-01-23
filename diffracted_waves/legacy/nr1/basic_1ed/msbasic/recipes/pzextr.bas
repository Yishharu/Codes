COMMON SHARED X(), QCOL()

SUB PZEXTR (IEST, XEST, YEST(), YZ(), DY(), NV, NUSE)
DIM D(NV)
X(IEST) = XEST
FOR J = 1 TO NV
  DY(J) = YEST(J)
  YZ(J) = YEST(J)
NEXT J
IF IEST = 1 THEN
  FOR J = 1 TO NV
    QCOL(J, 1) = YEST(J)
  NEXT J
ELSE
  M1 = IEST
  IF NUSE < IEST THEN M1 = NUSE
  FOR J = 1 TO NV
    D(J) = YEST(J)
  NEXT J
  FOR K1 = 1 TO M1 - 1
    DELTA = 1! / (X(IEST - K1) - XEST)
    F1 = XEST * DELTA
    F2 = X(IEST - K1) * DELTA
    FOR J = 1 TO NV
      Q = QCOL(J, K1)
      QCOL(J, K1) = DY(J)
      DELTA = D(J) - Q
      DY(J) = F1 * DELTA
      D(J) = F2 * DELTA
      YZ(J) = YZ(J) + DY(J)
    NEXT J
  NEXT K1
  FOR J = 1 TO NV
    QCOL(J, M1) = DY(J)
  NEXT J
END IF
ERASE D
END SUB

