DECLARE FUNCTION BESSJ! (N!, X!)
DECLARE FUNCTION BESSJ0! (X!)
DECLARE FUNCTION BESSJ1! (X!)

FUNCTION BESSJ (N, X)
IACC = 40
BIGNO = 1E+10
BIGNI = 1E-10
IF N < 2 THEN PRINT "bad argument N in BESSJ": EXIT FUNCTION
AX = ABS(X)
IF AX = 0! THEN
  BESSJ = 0!
ELSEIF AX > CSNG(N) THEN
  TOX = 2! / AX
  BJM = BESSJ0(AX)
  BJ = BESSJ1(AX)
  FOR J = 1 TO N - 1
    BJP = J * TOX * BJ - BJM
    BJM = BJ
    BJ = BJP
  NEXT J
  BESSJ = BJ
ELSE
  TOX = 2! / AX
  M = 2 * INT((N + INT(SQR(CSNG(IACC * N)))) / 2)
  BESJ = 0!
  JSUM = 0
  SUM = 0!
  BJP = 0!
  BJ = 1!
  FOR J = M TO 1 STEP -1
    BJM = J * TOX * BJ - BJP
    BJP = BJ
    BJ = BJM
    IF ABS(BJ) > BIGNO THEN
      BJ = BJ * BIGNI
      BJP = BJP * BIGNI
      BESJ = BESJ * BIGNI
      SUM = SUM * BIGNI
    END IF
    IF JSUM <> 0 THEN SUM = SUM + BJ
    JSUM = 1 - JSUM
    IF J = N THEN BESJ = BJP
  NEXT J
  SUM = 2! * SUM - BJ
  BESSJ = BESJ / SUM
END IF
END FUNCTION

