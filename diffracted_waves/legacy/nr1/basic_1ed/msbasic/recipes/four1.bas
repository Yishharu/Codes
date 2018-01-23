
SUB FOUR1 (DATQ(), NN, ISIGN)
N = 2 * NN
J = 1
FOR I = 1 TO N STEP 2
  IF J > I THEN
    TEMPR = DATQ(J)
    TEMPI = DATQ(J + 1)
    DATQ(J) = DATQ(I)
    DATQ(J + 1) = DATQ(I + 1)
    DATQ(I) = TEMPR
    DATQ(I + 1) = TEMPI
  END IF
  M = INT(N / 2)
  WHILE M >= 2 AND J > M
    J = J - M
    M = INT(M / 2)
  WEND
  J = J + M
NEXT I
MMAX = 2
WHILE N > MMAX
  ISTEP = 2 * MMAX
  THETA# = 6.28318530717959# / (ISIGN * MMAX)
  WPR# = -2# * SIN(.5# * THETA#) ^ 2
  WPI# = SIN(THETA#)
  WR# = 1#
  WI# = 0#
  FOR M = 1 TO MMAX STEP 2
    FOR I = M TO N STEP ISTEP
      J = I + MMAX
      TEMPR = CSNG(WR#) * DATQ(J) - CSNG(WI#) * DATQ(J + 1)
      TEMPI = CSNG(WR#) * DATQ(J + 1) + CSNG(WI#) * DATQ(J)
      DATQ(J) = DATQ(I) - TEMPR
      DATQ(J + 1) = DATQ(I + 1) - TEMPI
      DATQ(I) = DATQ(I) + TEMPR
      DATQ(I + 1) = DATQ(I + 1) + TEMPI
    NEXT I
    WTEMP# = WR#
    WR# = WR# * WPR# - WI# * WPI# + WR#
    WI# = WI# * WPR# + WTEMP# * WPI# + WI#
  NEXT M
  MMAX = ISTEP
WEND
END SUB

