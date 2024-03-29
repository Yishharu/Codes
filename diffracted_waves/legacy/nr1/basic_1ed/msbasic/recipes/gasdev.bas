DECLARE FUNCTION GASDEV! (IDUM&)
DECLARE FUNCTION RAN1! (IDUM&)

FUNCTION GASDEV (IDUM&)
STATIC ISET, GSET
IF ISET = 0 THEN
  DO
    V1 = 2! * RAN1(IDUM&) - 1!
    V2 = 2! * RAN1(IDUM&) - 1!
    R = V1 ^ 2 + V2 ^ 2
  LOOP WHILE R >= 1! OR R = 0!
  FAC = SQR(-2! * LOG(R) / R)
  GSET = V1 * FAC
  GASDEV = V2 * FAC
  ISET = 1
ELSE
  GASDEV = GSET
  ISET = 0
END IF
END FUNCTION

