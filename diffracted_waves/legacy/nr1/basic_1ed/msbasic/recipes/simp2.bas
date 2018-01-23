SUB SIMP2 (A(), M, N, MP, NP, L2(), NL2, IP, KP, Q1)
EPS = .000001
IP = 0
FLAG = 0
FOR I = 1 TO NL2
  IF A(L2(I) + 1, KP + 1) < -EPS THEN FLAG = 1
  IF FLAG = 1 THEN EXIT FOR
NEXT I
IF FLAG = 0 THEN EXIT SUB
Q1 = -A(L2(I) + 1, 1) / A(L2(I) + 1, KP + 1)
IP = L2(I)
FOR I = I + 1 TO NL2
  II = L2(I)
  IF A(II + 1, KP + 1) < -EPS THEN
    Q = -A(II + 1, 1) / A(II + 1, KP + 1)
    IF Q < Q1 THEN
      IP = II
      Q1 = Q
    ELSEIF Q = Q1 THEN
      FOR K = 1 TO N
        QP = -A(IP + 1, K + 1) / A(IP + 1, KP + 1)
        Q0 = -A(II + 1, K + 1) / A(II + 1, KP + 1)
        IF Q0 <> QP THEN EXIT FOR
      NEXT K
      IF Q0 < QP THEN IP = II
    END IF
  END IF
NEXT I
END SUB

