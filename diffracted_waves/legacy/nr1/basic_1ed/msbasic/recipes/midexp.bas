DECLARE FUNCTION FEXP! (X!)
DECLARE FUNCTION FUNC! (X!)

FUNCTION FEXP (X)
FEXP = FUNC(1! / X) / X ^ 2
END FUNCTION

SUB MIDEXP (DUM, AA, BB, S, N) STATIC
B = EXP(-AA)
A = 0!
IF N = 1 THEN
  S = (B - A) * FEXP(.5 * (A + B))
  IT = 1
ELSE
  TNM = IT
  DEL = (B - A) / (3! * TNM)
  DDEL = DEL + DEL
  X = A + .5 * DEL
  SUM = 0!
  FOR J = 1 TO IT
    SUM = SUM + FEXP(X)
    X = X + DDEL
    SUM = SUM + FEXP(X)
    X = X + DEL
  NEXT J
  S = (S + (B - A) * SUM / TNM) / 3!
  IT = 3 * IT
END IF
END SUB

