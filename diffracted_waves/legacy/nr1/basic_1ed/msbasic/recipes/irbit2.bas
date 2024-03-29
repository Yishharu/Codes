DECLARE FUNCTION IRBIT2! (ISEED!)

FUNCTION IRBIT2 (ISEED) STATIC
IB1 = 1
IB3 = 4
IB5 = 16
IB14 = 8192
MASK = 21
IF (ISEED AND IB14) <> 0 THEN
  ISEED = ISEED XOR MASK
  IF ISEED > 2 ^ 14 THEN ISEED = ISEED - 2 ^ 14
  ISEED = 2 * ISEED OR IB1
  IRBIT2 = 1
ELSE
  IF ISEED > 2 ^ 14 THEN ISEED = ISEED - 2 ^ 14
  ISEED = 2 * ISEED AND (NOT IB1)
  IRBIT2 = 0
END IF
END FUNCTION

