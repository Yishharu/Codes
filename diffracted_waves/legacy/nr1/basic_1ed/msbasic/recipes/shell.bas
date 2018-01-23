SUB SHELQ (N, ARR())
ALN2I = 1.442695#
TINY = .00001
M = N
LOGNB2 = INT(LOG(CSNG(N)) * ALN2I + TINY)
FOR NN = 1 TO LOGNB2
  M = INT(M / 2)
  K = N - M
  FOR J = 1 TO K
    I = J
    DO
      DONE% = -1
      L = I + M
      IF ARR(L) < ARR(I) THEN
        T = ARR(I)
        ARR(I) = ARR(L)
        ARR(L) = T
        I = I - M
        IF I >= 1 THEN DONE% = 0
      END IF
    LOOP WHILE NOT DONE%
  NEXT J
NEXT NN
END SUB

