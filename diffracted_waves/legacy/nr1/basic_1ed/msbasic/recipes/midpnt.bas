DECLARE FUNCTION FUNC! (X!)

SUB MIDPNT (DUM, A, B, S, N) STATIC
IF N = 1 THEN
  S = (B - A) * FUNC(.5 * (A + B))
  IT = 1
ELSE
  TNM = IT
  DEL = (B - A) / (3! * TNM)
  DDEL = DEL + DEL
  X = A + .5 * DEL
  SUM = 0!
  FOR J = 1 TO IT
    SUM = SUM + FUNC(X)
    X = X + DDEL
    SUM = SUM + FUNC(X)
    X = X + DEL
  NEXT J
  S = (S + (B - A) * SUM / TNM) / 3!
  IT = 3 * IT
END IF
END SUB

