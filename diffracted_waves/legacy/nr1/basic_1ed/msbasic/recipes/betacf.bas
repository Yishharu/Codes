DECLARE FUNCTION BETACF! (A!, B!, X!)

FUNCTION BETACF (A, B, X)
ITMAX = 100
EPS = .0000003
AM = 1!
BM = 1!
AZ = 1!
QAB = A + B
QAP = A + 1!
QAM = A - 1!
BZ = 1! - QAB * X / QAP
FOR M = 1 TO ITMAX
  EM = INT(M)
  TEM = EM + EM
  D = EM * (B - M) * X / ((QAM + TEM) * (A + TEM))
  AP = AZ + D * AM
  BP = BZ + D * BM
  D = -(A + EM) * (QAB + EM) * X / ((A + TEM) * (QAP + TEM))
  APP = AP + D * AZ
  BPP = BP + D * BZ
  AOLD = AZ
  AM = AP / BPP
  BM = BP / BPP
  AZ = APP / BPP
  BZ = 1!
  IF ABS(AZ - AOLD) < EPS * ABS(AZ) THEN EXIT FOR
NEXT M
IF ABS(AZ - AOLD) >= EPS * ABS(AZ) THEN
  PRINT "A or B too big, or ITMAX too small"
ELSE
  BETACF = AZ
END IF
END FUNCTION

