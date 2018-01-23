SUB MOMENT (DATQ(), N, AVE, ADEV, SDEV, VAR, SKEW, CURT)
IF N <= 1 THEN PRINT "N must be at least 2": EXIT SUB
S = 0!
FOR J = 1 TO N
  S = S + DATQ(J)
NEXT J
AVE = S / N
ADEV = 0!
VAR = 0!
SKEW = 0!
CURT = 0!
FOR J = 1 TO N
  S = DATQ(J) - AVE
  ADEV = ADEV + ABS(S)
  P = S * S
  VAR = VAR + P
  P = P * S
  SKEW = SKEW + P
  P = P * S
  CURT = CURT + P
NEXT J
ADEV = ADEV / N
VAR = VAR / (N - 1)
SDEV = SQR(VAR)
IF VAR <> 0! THEN
  SKEW = SKEW / (N * SDEV ^ 3)
  CURT = CURT / (N * VAR ^ 2) - 3!
ELSE
  PRINT "no skew or kurtosis when zero variance"
END IF
END SUB

