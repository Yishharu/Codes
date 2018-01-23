SUB LOCATQ (XX(), N, X, J)
JL = 0
JU = N + 1
WHILE JU - JL > 1
  JM = INT((JU + JL) / 2)
  IF XX(N) > XX(1) EQV X > XX(JM) THEN
    JL = JM
  ELSE
    JU = JM
  END IF
WEND
J = JL
END SUB

