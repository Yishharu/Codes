DECLARE FUNCTION GAMMLN! (X!)

SUB GCF (GAMMCF, A, X, GLN)
ITMAX = 100
EPS = .0000003
GLN = GAMMLN(A)
GOLD = 0!
A0 = 1!
A1 = X
B0 = 0!
B1 = 1!
FAC = 1!
FOR N = 1 TO ITMAX
  AN = CSNG(N)
  ANA = AN - A
  A0 = (A1 + A0 * ANA) * FAC
  B0 = (B1 + B0 * ANA) * FAC
  ANF = AN * FAC
  A1 = X * A0 + ANF * A1
  B1 = X * B0 + ANF * B1
  IF A1 <> 0! THEN
    FAC = 1! / A1
    G = B1 * FAC
    IF ABS((G - GOLD) / G) < EPS THEN EXIT FOR
    GOLD = G
  END IF
NEXT N
IF ABS((G - GOLD) / G) >= EPS THEN PRINT "A too large, ITMAX too small": EXIT SUB
IF -X + A * LOG(X) - GLN < -100 THEN
  GAMMCF = 0!
ELSE
  GAMMCF = EXP(-X + A * LOG(X) - GLN) * G
END IF
END SUB

