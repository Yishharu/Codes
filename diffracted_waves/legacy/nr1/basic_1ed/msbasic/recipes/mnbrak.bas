DECLARE FUNCTION FUNC! (X!)

SUB MNBRAK (AX, BX, CX, FA, FB, FC, DUM)
GOLD = 1.618034
GLIMIT = 100!
TINY = 1E-20
FA = FUNC(AX)
FB = FUNC(BX)
IF FB > FA THEN
  DUM = AX
  AX = BX
  BX = DUM
  DUM = FB
  FB = FA
  FA = DUM
END IF
CX = BX + GOLD * (BX - AX)
FC = FUNC(CX)
DO
  IF FB < FC THEN EXIT DO
  DONE% = -1
  R = (BX - AX) * (FB - FC)
  Q = (BX - CX) * (FB - FA)
  DUM = Q - R
  IF ABS(DUM) < TINY THEN DUM = TINY
  U = BX - ((BX - CX) * Q - (BX - AX) * R) / (2! * DUM)
  ULIM = BX + GLIMIT * (CX - BX)
  IF (BX - U) * (U - CX) > 0! THEN
    FU = FUNC(U)
    IF FU < FC THEN
      AX = BX
      FA = FB
      BX = U
      FB = FU
      EXIT SUB
    ELSEIF FU > FB THEN
      CX = U
      FC = FU
      EXIT SUB
    END IF
    U = CX + GOLD * (CX - BX)
    FU = FUNC(U)
  ELSEIF (CX - U) * (U - ULIM) > 0! THEN
    FU = FUNC(U)
    IF FU < FC THEN
      BX = CX
      CX = U
      U = CX + GOLD * (CX - BX)
      FB = FC
      FC = FU
      FU = FUNC(U)
    END IF
  ELSEIF (U - ULIM) * (ULIM - CX) >= 0! THEN
    U = ULIM
    FU = FUNC(U)
  ELSE
    U = CX + GOLD * (CX - BX)
    FU = FUNC(U)
  END IF
  IF DONE% THEN
    AX = BX
    BX = CX
    CX = U
    FA = FB
    FB = FC
    FC = FU
  ELSE
    DONE% = 0
  END IF
LOOP WHILE NOT DONE%
END SUB

