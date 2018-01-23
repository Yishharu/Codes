DECLARE FUNCTION ROFUNC! (B!)
COMMON SHARED NPT, X(), Y(), ARR(), AA, ABDEV

SUB MEDFIT (XD(), YD(), NDATA, A, B, ABDEVD)
SX = 0!
SY = 0!
SXY = 0!
SXX = 0!
FOR J = 1 TO NDATA
  X(J) = XD(J)
  Y(J) = YD(J)
  SX = SX + XD(J)
  SY = SY + YD(J)
  SXY = SXY + XD(J) * YD(J)
  SXX = SXX + XD(J) ^ 2
NEXT J
NPT = NDATA
DEQ = NDATA * SXX - SX ^ 2
AA = (SXX * SY - SX * SXY) / DEQ
BB = (NDATA * SXY - SX * SY) / DEQ
CHISQ = 0!
FOR J = 1 TO NDATA
  CHISQ = CHISQ + (YD(J) - (AA + BB * XD(J))) ^ 2
NEXT J
SIGB = SQR(CHISQ / DEQ)
B1 = BB
F1 = ROFUNC(B1)
B2 = BB + ABS(3! * SIGB) * SGN(F1)
F2 = ROFUNC(B2)
WHILE F1 * F2 > 0!
  BB = 2! * B2 - B1
  B1 = B2
  F1 = F2
  B2 = BB
  F2 = ROFUNC(B2)
WEND
SIGB = .01 * SIGB
DO WHILE ABS(B2 - B1) > SIGB
  BB = .5 * (B1 + B2)
  IF BB = B1 OR BB = B2 THEN EXIT DO
  F = ROFUNC(BB)
  IF F * F1 >= 0! THEN
    F1 = F
    B1 = BB
  ELSE
    F2 = F
    B2 = BB
  END IF
LOOP
A = AA
B = BB
ABDEVD = ABDEV / NDATA
END SUB

