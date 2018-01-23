DECLARE FUNCTION GAMDEV! (IA!, IDUM&)
DECLARE FUNCTION RAN1! (IDUM&)

FUNCTION GAMDEV (IA, IDUM&)
IF IA < 1 THEN PRINT "Abnormal exit": EXIT FUNCTION
IF IA < 6 THEN
  X = 1!
  FOR J = 1 TO IA
    X = X * RAN1(IDUM&)
  NEXT J
  X = -LOG(X)
ELSE
  DO
    DO
      DO
        V1 = 2! * RAN1(IDUM&) - 1!
        V2 = 2! * RAN1(IDUM&) - 1!
      LOOP WHILE V1 ^ 2 + V2 ^ 2 > 1!
      Y = V2 / V1
      AM = IA - 1
      S = SQR(2! * AM + 1!)
      X = S * Y + AM
    LOOP WHILE X <= 0!
    E = (1! + Y ^ 2) * EXP(AM * LOG(X / AM) - S * Y)
  LOOP WHILE RAN1(IDUM&) > E
END IF
GAMDEV = X
END FUNCTION

