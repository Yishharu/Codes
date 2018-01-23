DECLARE FUNCTION PLGNDR! (L!, M!, X!)

FUNCTION PLGNDR (L, M, X)
IF M < 0 OR M > L OR ABS(X) > 1! THEN PRINT "bad arguments": EXIT FUNCTION
PMM = 1!
IF M > 0 THEN
  SOMX2 = SQR((1! - X) * (1! + X))
  FACT = 1!
  FOR I = 1 TO M
    PMM = -PMM * FACT * SOMX2
    FACT = FACT + 2!
  NEXT I
END IF
IF L = M THEN
  PLGNDR = PMM
ELSE
  PMMP1 = X * (2 * M + 1) * PMM
  IF L = M + 1 THEN
    PLGNDR = PMMP1
  ELSE
    FOR LL = M + 2 TO L
      PLL = (X * (2 * LL - 1) * PMMP1 - (LL + M - 1) * PMM) / (LL - M)
      PMM = PMMP1
      PMMP1 = PLL
    NEXT LL
    PLGNDR = PLL
  END IF
END IF
END FUNCTION

