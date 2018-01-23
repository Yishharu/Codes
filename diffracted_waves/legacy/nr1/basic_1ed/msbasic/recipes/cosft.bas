DECLARE SUB REALFT (DATQ!(), N!, ISIGN!)

SUB COSFT (Y(), N, ISIGN)
THETA# = 3.141592653589793# / CDBL(N)
WR# = 1#
WI# = 0#
WPR# = -2# * SIN(.5# * THETA#) ^ 2
WPI# = SIN(THETA#)
SUM = Y(1)
M = N / 2
FOR J = 1 TO M - 1
  WTEMP# = WR#
  WR# = WR# * WPR# - WI# * WPI# + WR#
  WI# = WI# * WPR# + WTEMP# * WPI# + WI#
  Y1 = .5 * (Y(J + 1) + Y(N - J + 1))
  Y2 = Y(J + 1) - Y(N - J + 1)
  Y(J + 1) = Y1 - WI# * Y2
  Y(N - J + 1) = Y1 + WI# * Y2
  SUM = SUM + WR# * Y2
NEXT J
CALL REALFT(Y(), M, 1)
Y(2) = SUM
FOR J = 4 TO N STEP 2
  SUM = SUM + Y(J)
  Y(J) = SUM
NEXT J
IF ISIGN = -1 THEN
  EVEN = Y(1)
  ODD = Y(2)
  FOR I = 3 TO N - 1 STEP 2
    EVEN = EVEN + Y(I)
    ODD = ODD + Y(I + 1)
  NEXT I
  ENF0 = 2! * (EVEN - ODD)
  SUMO = Y(1) - ENF0
  SUME = 2! * ODD / CSNG(N) - SUMO
  Y(1) = .5 * ENF0
  Y(2) = Y(2) - SUME
  FOR I = 3 TO N - 1 STEP 2
    Y(I) = Y(I) - SUMO
    Y(I + 1) = Y(I + 1) - SUME
  NEXT I
END IF
END SUB

