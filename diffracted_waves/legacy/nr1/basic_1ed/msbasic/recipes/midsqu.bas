DECLARE FUNCTION SQU! (X!, BB!)
DECLARE FUNCTION FUNC! (X!)

SUB MIDSQU (DUM, AA, BB, S, N) STATIC
B = SQR(BB - AA)
A = 0!
IF N = 1 THEN
  S = (B - A) * SQU(.5 * (A + B), BB)
  IT = 1
ELSE
  TNM = IT
  DEL = (B - A) / (3! * TNM)
  DDEL = DEL + DEL
  X = A + .5 * DEL
  SUM = 0!
  FOR J = 1 TO IT
    SUM = SUM + SQU(X, BB)
    X = X + DDEL
    SUM = SUM + SQU(X, BB)
    X = X + DEL
  NEXT J
  S = (S + (B - A) * SUM / TNM) / 3!
  IT = 3 * IT
END IF
END SUB

FUNCTION SQU (X, BB)
SQU = 2! * X * FUNC(BB - X ^ 2)
END FUNCTION

