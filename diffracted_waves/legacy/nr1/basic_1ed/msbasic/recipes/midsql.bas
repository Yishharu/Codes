DECLARE FUNCTION SQL! (X!, AA!)
DECLARE FUNCTION FUNC! (X!)

SUB MIDSQL (DUM, AA, BB, S, N) STATIC
B = SQR(BB - AA)
A = 0!
IF N = 1 THEN
  S = (B - A) * SQL(.5 * (A + B), AA)
  IT = 1
ELSE
  TNM = IT
  DEL = (B - A) / (3! * TNM)
  DDEL = DEL + DEL
  X = A + .5 * DEL
  SUM = 0!
  FOR J = 1 TO IT
    SUM = SUM + SQL(X, AA)
    X = X + DDEL
    SUM = SUM + SQL(X, AA)
    X = X + DEL
  NEXT J
  S = (S + (B - A) * SUM / TNM) / 3!
  IT = 3 * IT
END IF
END SUB

FUNCTION SQL (X, AA)
SQL = 2 * X * FUNC(AA + X ^ 2)
END FUNCTION

