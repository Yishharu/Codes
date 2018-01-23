SUB HUNT (XX(), N, X, JLO)
ASCND% = XX(N) > XX(1)
IF JLO <= 0 OR JLO > N THEN
  JLO = 0
  JHI = N + 1
ELSE
  INC = 1
  IF X >= XX(JLO) EQV ASCND% THEN
1   JHI = JLO + INC
    IF JHI > N THEN
      JHI = N + 1
    ELSEIF X >= XX(JHI) EQV ASCND% THEN
      JLO = JHI
      INC = INC + INC
      GOTO 1
    END IF
  ELSE
    JHI = JLO
2   JLO = JHI - INC
    IF JLO < 1 THEN
      JLO = 0
    ELSEIF X < XX(JLO) EQV ASCND% THEN
      JHI = JLO
      INC = INC + INC
      GOTO 2
    END IF
  END IF
END IF
DO
  IF JHI - JLO = 1 THEN EXIT SUB
  JM = INT((JHI + JLO) / 2)
  IF X > XX(JM) EQV ASCND% THEN
    JLO = JM
  ELSE
    JHI = JM
  END IF
LOOP
END SUB

