SUB BKSUB (NE, NB, JF, K1, K2, C(), NCI, NCJ, NCK)
NBF = NE - NB
IM = 1
FOR K = K2 TO K1 STEP -1
  IF K = K1 THEN IM = NBF + 1
  KP = K + 1
  FOR J = 1 TO NBF
    XX = C(J, JF, KP)
    FOR I = IM TO NE
      C(I, JF, K) = C(I, JF, K) - C(I, J, K) * XX
    NEXT I
  NEXT J
NEXT K
FOR K = K1 TO K2
  KP = K + 1
  FOR I = 1 TO NB
    C(I, 1, K) = C(I + NBF, JF, K)
  NEXT I
  FOR I = 1 TO NBF
    C(I + NB, 1, K) = C(I, JF, KP)
  NEXT I
NEXT K
END SUB

