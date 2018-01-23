DECLARE FUNCTION FUNC! (X!)

SUB ZBRAK (DUM, X1, X2, N, XB1(), XB2(), NB)
NBB = NB
NB = 0
X = X1
DX = (X2 - X1) / N
FP = FUNC(X)
FOR I = 1 TO N
  X = X + DX
  FC = FUNC(X)
  IF FC * FP < 0! THEN
    NB = NB + 1
    XB1(NB) = X - DX
    XB2(NB) = X
  END IF
  FP = FC
  IF NBB = NB THEN EXIT SUB
NEXT I
END SUB

