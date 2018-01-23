DECLARE FUNCTION GAMMQ! (A!, X!)

SUB FIT (X(), Y(), NDATA, SIG(), MWT, A, B, SIGA, SIGB, CHI2, Q)
SX = 0!
SY = 0!
ST2 = 0!
B = 0!
IF MWT <> 0 THEN
  SS = 0!
  FOR I = 1 TO NDATA
    WT = 1! / SIG(I) ^ 2
    SS = SS + WT
    SX = SX + X(I) * WT
    SY = SY + Y(I) * WT
  NEXT I
ELSE
  FOR I = 1 TO NDATA
    SX = SX + X(I)
    SY = SY + Y(I)
  NEXT I
  SS = CSNG(NDATA)
END IF
SXOSS = SX / SS
IF MWT <> 0 THEN
  FOR I = 1 TO NDATA
    T = (X(I) - SXOSS) / SIG(I)
    ST2 = ST2 + T * T
    B = B + T * Y(I) / SIG(I)
  NEXT I
ELSE
  FOR I = 1 TO NDATA
    T = X(I) - SXOSS
    ST2 = ST2 + T * T
    B = B + T * Y(I)
  NEXT I
END IF
B = B / ST2
A = (SY - SX * B) / SS
SIGA = SQR((1! + SX * SX / (SS * ST2)) / SS)
SIGB = SQR(1! / ST2)
CHI2 = 0!
IF MWT = 0 THEN
  FOR I = 1 TO NDATA
    CHI2 = CHI2 + (Y(I) - A - B * X(I)) ^ 2
  NEXT I
  Q = 1!
  SIGDAT = SQR(CHI2 / (NDATA - 2))
  SIGA = SIGA * SIGDAT
  SIGB = SIGB * SIGDAT
ELSE
  FOR I = 1 TO NDATA
    CHI2 = CHI2 + ((Y(I) - A - B * X(I)) / SIG(I)) ^ 2
  NEXT I
  Q = GAMMQ(.5 * (NDATA - 2), .5 * CHI2)
END IF
END SUB

