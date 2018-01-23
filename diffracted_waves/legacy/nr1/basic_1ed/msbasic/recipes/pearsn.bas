DECLARE FUNCTION BETAI! (A!, B!, X!)

SUB PEARSN (X(), Y(), N, R, PROB, Z)
TINY = 1E-20
AX = 0!
AY = 0!
FOR J = 1 TO N
  AX = AX + X(J)
  AY = AY + Y(J)
NEXT J
AX = AX / N
AY = AY / N
SXX = 0!
SYY = 0!
SXY = 0!
FOR J = 1 TO N
  XT = X(J) - AX
  YT = Y(J) - AY
  SXX = SXX + XT ^ 2
  SYY = SYY + YT ^ 2
  SXY = SXY + XT * YT
NEXT J
R = SXY / SQR(SXX * SYY)
Z = .5 * LOG(((1! + R) + TINY) / ((1! - R) + TINY))
DF = N - 2
T = R * SQR(DF / (((1! - R) + TINY) * ((1! + R) + TINY)))
PROB = BETAI(.5 * DF, .5, DF / (DF + T ^ 2))
'PROB = ERFCC(ABS(Z * SQR(N - 1!)) / 1.4142136#)
END SUB

