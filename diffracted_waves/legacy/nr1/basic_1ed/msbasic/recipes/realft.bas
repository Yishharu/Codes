DECLARE SUB FOUR1 (DATQ!(), NN!, ISIGN!)

SUB REALFT (DATQ(), N, ISIGN)
THETA# = 3.141592653589793# / CDBL(N)
C1 = .5
IF ISIGN = 1 THEN
  C2 = -.5
  CALL FOUR1(DATQ(), N, 1)
ELSE
  C2 = .5
  THETA# = -THETA#
END IF
WPR# = -2# * SIN(.5# * THETA#) ^ 2
WPI# = SIN(THETA#)
WR# = 1# + WPR#
WI# = WPI#
N2P3 = 2 * N + 3
FOR I = 2 TO INT(N / 2)
  I1 = 2 * I - 1
  I2 = I1 + 1
  I3 = N2P3 - I2
  I4 = I3 + 1
  WRS# = CSNG(WR#)
  WIS# = CSNG(WI#)
  H1R = C1 * (DATQ(I1) + DATQ(I3))
  H1I = C1 * (DATQ(I2) - DATQ(I4))
  H2R = -C2 * (DATQ(I2) + DATQ(I4))
  H2I = C2 * (DATQ(I1) - DATQ(I3))
  DATQ(I1) = H1R + WRS# * H2R - WIS# * H2I
  DATQ(I2) = H1I + WRS# * H2I + WIS# * H2R
  DATQ(I3) = H1R - WRS# * H2R + WIS# * H2I
  DATQ(I4) = -H1I + WRS# * H2I + WIS# * H2R
  WTEMP# = WR#
  WR# = WR# * WPR# - WI# * WPI# + WR#
  WI# = WI# * WPR# + WTEMP# * WPI# + WI#
NEXT I
IF ISIGN = 1 THEN
  H1R = DATQ(1)
  DATQ(1) = H1R + DATQ(2)
  DATQ(2) = H1R - DATQ(2)
ELSE
  H1R = DATQ(1)
  DATQ(1) = C1 * (H1R + DATQ(2))
  DATQ(2) = C1 * (H1R - DATQ(2))
  CALL FOUR1(DATQ(), N, -1)
END IF
END SUB

