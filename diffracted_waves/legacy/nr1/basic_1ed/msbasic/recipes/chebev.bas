DECLARE FUNCTION CHEBEV! (A!, B!, DUM!, M!, X!)
COMMON SHARED C()

FUNCTION CHEBEV (A, B, DUM, M, X)
IF (X - A) * (X - B) > 0! THEN PRINT "X not in range.": EXIT FUNCTION
D = 0!
DD = 0!
Y = (2! * X - A - B) / (B - A)
Y2 = 2! * Y
FOR J = M TO 2 STEP -1
  SV = D
  D = Y2 * D - DD + C(J)
  DD = SV
NEXT J
CHEBEV = Y * D - DD + .5 * C(1)
END FUNCTION

