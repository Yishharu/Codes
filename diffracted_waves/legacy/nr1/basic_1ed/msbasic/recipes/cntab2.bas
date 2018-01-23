
SUB CNTAB2 (NN(), NI, NJ, H, HX, HY, HYGX, HXGY, UYGX, UXGY, UXY)
TINY = 1E-30
DIM SUMI(NI), SUMJ(NJ)
SUM = 0
FOR I = 1 TO NI
  SUMI(I) = 0!
  FOR J = 1 TO NJ
    SUMI(I) = SUMI(I) + NN(I, J)
    SUM = SUM + NN(I, J)
  NEXT J
NEXT I
FOR J = 1 TO NJ
  SUMJ(J) = 0!
  FOR I = 1 TO NI
    SUMJ(J) = SUMJ(J) + NN(I, J)
  NEXT I
NEXT J
HX = 0!
FOR I = 1 TO NI
  IF SUMI(I) <> 0! THEN
    P = SUMI(I) / SUM
    HX = HX - P * LOG(P)
  END IF
NEXT I
HY = 0!
FOR J = 1 TO NJ
  IF SUMJ(J) <> 0! THEN
    P = SUMJ(J) / SUM
    HY = HY - P * LOG(P)
  END IF
NEXT J
H = 0!
FOR I = 1 TO NI
  FOR J = 1 TO NJ
    IF NN(I, J) <> 0 THEN
      P = NN(I, J) / SUM
      H = H - P * LOG(P)
    END IF
  NEXT J
NEXT I
HYGX = H - HX
HXGY = H - HY
UYGX = (HY - HYGX) / (HY + TINY)
UXGY = (HX - HXGY) / (HX + TINY)
UXY = 2! * (HX + HY - H) / (HX + HY + TINY)
ERASE SUMJ, SUMI
END SUB

