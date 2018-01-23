DECLARE FUNCTION FUNC! (X!)

SUB TRAPZD (DUM, A, B, S, N) STATIC
IF N = 1 THEN
  S = .5 * (B - A) * (FUNC(A) + FUNC(B))
  IT = 1
ELSE
  TNM = IT
  DEL = (B - A) / TNM
  X = A + .5 * DEL
  SUM = 0!
  FOR J = 1 TO IT
    SUM = SUM + FUNC(X)
    X = X + DEL
  NEXT J
  S = .5 * (S + (B - A) * SUM / TNM)
  IT = 2 * IT
END IF
END SUB

