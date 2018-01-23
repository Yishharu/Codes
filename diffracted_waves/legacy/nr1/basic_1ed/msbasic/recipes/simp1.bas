SUB SIMP1 (A(), MP, NP, MM, LL(), NLL, IABF, KP, BMAX)
KP = LL(1)
BMAX = A(MM + 1, KP + 1)
FOR K = 2 TO NLL
  IF IABF = 0 THEN
    TEST = A(MM + 1, LL(K) + 1) - BMAX
  ELSE
    TEST = ABS(A(MM + 1, LL(K) + 1)) - ABS(BMAX)
  END IF
  IF TEST > 0! THEN
    BMAX = A(MM + 1, LL(K) + 1)
    KP = LL(K)
  END IF
NEXT K
END SUB

