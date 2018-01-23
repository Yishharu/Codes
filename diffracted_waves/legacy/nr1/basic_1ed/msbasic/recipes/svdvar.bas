
SUB SVDVAR (V(), MA, NP, W(), CVM(), NCVM)
DIM WTI(MA)
FOR I = 1 TO MA
  WTI(I) = 0!
  IF W(I) <> 0! THEN WTI(I) = 1! / (W(I) * W(I))
NEXT I
FOR I = 1 TO MA
  FOR J = 1 TO I
    SUM = 0!
    FOR K = 1 TO MA
      SUM = SUM + V(I, K) * V(J, K) * WTI(K)
    NEXT K
    CVM(I, J) = SUM
    CVM(J, I) = SUM
  NEXT J
NEXT I
ERASE WTI
END SUB

