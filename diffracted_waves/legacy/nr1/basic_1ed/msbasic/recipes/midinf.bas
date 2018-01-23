DECLARE FUNCTION INF! (X!)
DECLARE FUNCTION FUNC! (X!)

FUNCTION INF (X)
INF = FUNC(1! / X) / X ^ 2
END FUNCTION

SUB MIDINF (DUM, AA, BB, S, N) STATIC
B = 1! / AA
A = 1! / BB
IF N = 1 THEN
  X = .5 * (A + B)
  S = (B - A) * INF(.5 * (A + B))
  IT = 1
ELSE
  TNM = IT
  DEL = (B - A) / (3! * TNM)
  DDEL = DEL + DEL
  X = A + .5 * DEL
  SUM = 0!
  FOR J = 1 TO IT
    SUM = SUM + INF(X)
    X = X + DDEL
    SUM = SUM + INF(X)
    X = X + DEL
  NEXT J
  S = (S + (B - A) * SUM / TNM) / 3!
  IT = 3 * IT
END IF
END SUB

