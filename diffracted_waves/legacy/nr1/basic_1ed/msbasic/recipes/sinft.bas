DECLARE SUB REALFT (DATQ!(), N!, ISIGN!)

SUB SINFT (Y(), N)
THETA# = 3.141592653589793# / CDBL(N)
WR# = 1#
WI# = 0#
WPR# = -2# * SIN(.5# * THETA#) ^ 2
WPI# = SIN(THETA#)
Y(1) = 0!
M = N / 2
FOR J = 1 TO M
  WTEMP# = WR#
  WR# = WR# * WPR# - WI# * WPI# + WR#
  WI# = WI# * WPR# + WTEMP# * WPI# + WI#
  Y1 = WI# * (Y(J + 1) + Y(N - J + 1))
  Y2 = .5 * (Y(J + 1) - Y(N - J + 1))
  Y(J + 1) = Y1 + Y2
  Y(N - J + 1) = Y1 - Y2
NEXT J
CALL REALFT(Y(), M, 1)
SUM = 0!
Y(1) = .5 * Y(1)
Y(2) = 0!
FOR J = 1 TO N - 1 STEP 2
  SUM = SUM + Y(J)
  Y(J) = Y(J + 1)
  Y(J + 1) = SUM
NEXT J
END SUB

