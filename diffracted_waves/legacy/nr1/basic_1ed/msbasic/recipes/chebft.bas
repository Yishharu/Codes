DECLARE FUNCTION FUNC! (X!)

SUB CHEBFT (A, B, C(), N, DUM)
PI# = 3.141592653589793#
DIM F(N)
BMA = .5 * (B - A)
BPA = .5 * (B + A)
FOR K = 1 TO N
  Y = COS(PI# * (K - .5) / N)
  F(K) = FUNC(Y * BMA + BPA)
NEXT K
FAC = 2! / N
FOR J = 1 TO N
  SUM# = 0#
  FOR K = 1 TO N
    SUM# = SUM# + F(K) * COS((PI# * (J - 1)) * ((K - .5#) / N))
  NEXT K
  C(J) = FAC * SUM#
NEXT J
ERASE F
END SUB

