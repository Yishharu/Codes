DECLARE SUB SIMP1 (A!(), MP!, NP!, MM!, LL!(), NLL!, IABF!, KP!, BMAX!)
DECLARE SUB SIMP2 (A!(), M!, N!, MP!, NP!, L2!(), NL2!, IP!, KP!, Q1!)
DECLARE SUB SIMP3 (A!(), MP!, NP!, I1!, K1!, IP!, KP!)

SUB SIMPLX (A(), M, N, MP, NP, M1, M2, M3, ICASE, IZROV(), IPOSV())
EPS = .000001
DIM L1(M), L2(M), L3(M)
IF M <> M1 + M2 + M3 THEN
  PRINT "Bad input constraint counts."
  EXIT SUB
END IF
NL1 = N
FOR K = 1 TO N
  L1(K) = K
  IZROV(K) = K
NEXT K
NL2 = M
FOR I = 1 TO M
  IF A(I + 1, 1) < 0! THEN
    PRINT "Bad input tableau."
    EXIT SUB
  END IF
  L2(I) = I
  IPOSV(I) = N + I
NEXT I
FOR I = 1 TO M2
  L3(I) = 1
NEXT I
IR = 0
IF M2 + M3 = 0 THEN GOTO 3
IR = 1
FOR K = 1 TO N + 1
  Q1 = 0!
  FOR I = M1 + 1 TO M
    Q1 = Q1 + A(I + 1, K)
  NEXT I
  A(M + 2, K) = -Q1
NEXT K
DO
  CALL SIMP1(A(), MP, NP, M + 1, L1(), NL1, 0, KP, BMAX)
  IF BMAX <= EPS AND A(M + 2, 1) < -EPS THEN
    ICASE = -1
    ERASE L3, L2, L1
    EXIT SUB
  ELSEIF BMAX <= EPS AND A(M + 2, 1) <= EPS THEN
    M12 = M1 + M2 + 1
    IF M12 <= M THEN
      FOR IP = M12 TO M
        IF IPOSV(IP) = IP + N THEN
          CALL SIMP1(A(), MP, NP, IP, L1(), NL1, 1, KP, BMAX)
          IF BMAX > 0! THEN GOTO 1
        END IF
      NEXT IP
    END IF
    IR = 0
    M12 = M12 - 1
    IF M1 + 1 > M12 THEN EXIT DO
    FOR I = M1 + 1 TO M12
      IF L3(I - M1) = 1 THEN
        FOR K = 1 TO N + 1
          A(I + 1, K) = -A(I + 1, K)
        NEXT K
      END IF
    NEXT I
    EXIT DO
  END IF
  CALL SIMP2(A(), M, N, MP, NP, L2(), NL2, IP, KP, Q1)
  IF IP = 0 THEN
    ICASE = -1
    ERASE L3, L2, L1
    EXIT SUB
  END IF
1 CALL SIMP3(A(), MP, NP, M + 1, N, IP, KP)
  IF IPOSV(IP) >= N + M1 + M2 + 1 THEN
    FOR K = 1 TO NL1
      IF L1(K) = KP THEN EXIT FOR
    NEXT K
    NL1 = NL1 - 1
    FOR IQ = K TO NL1
      L1(IQ) = L1(IQ + 1)
    NEXT IQ
  ELSE
    IF IPOSV(IP) < N + M1 + 1 THEN GOTO 2
    KH = IPOSV(IP) - M1 - N
    IF L3(KH) = 0 THEN GOTO 2
    L3(KH) = 0
  END IF
  A(M + 2, KP + 1) = A(M + 2, KP + 1) + 1!
  FOR I = 1 TO M + 2
    A(I, KP + 1) = -A(I, KP + 1)
  NEXT I
2 IQ = IZROV(KP)
  IZROV(KP) = IPOSV(IP)
  IPOSV(IP) = IQ
LOOP WHILE IR <> 0
3 CALL SIMP1(A(), MP, NP, 0, L1(), NL1, 0, KP, BMAX)
IF BMAX <= 0! THEN
  ICASE = 0
  ERASE L3, L2, L1
  EXIT SUB
END IF
CALL SIMP2(A(), M, N, MP, NP, L2(), NL2, IP, KP, Q1)
IF IP = 0 THEN
  ICASE = 1
  ERASE L3, L2, L1
  EXIT SUB
END IF
CALL SIMP3(A(), MP, NP, M, N, IP, KP)
GOTO 2
END SUB

