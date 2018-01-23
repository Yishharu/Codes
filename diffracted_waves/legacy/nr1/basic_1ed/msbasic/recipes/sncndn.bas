DECLARE FUNCTION COSH! (U!)
DECLARE FUNCTION TANH! (U!)

FUNCTION COSH (U)
COSH = .5 * (EXP(U) + EXP(-U))
END FUNCTION

SUB SNCNDN (UU, EMMC, SN, CN, DN)
CA = .0003
DIM EM(13), EN(13)
EMC = EMMC
U = UU
IF EMC <> 0! THEN
  BO& = EMC < 0!
  IF BO& THEN
    D = 1! - EMC
    EMC = -EMC / D
    D = SQR(D)
    U = D * U
  END IF
  A = 1!
  DN = 1!
  FOR I = 1 TO 13
    L = I
    EM(I) = A
    EMC = SQR(EMC)
    EN(I) = EMC
    C = .5 * (A + EMC)
    IF ABS(A - EMC) <= CA * A THEN EXIT FOR
    EMC = A * EMC
    A = C
  NEXT I
  U = C * U
  SN = SIN(U)
  CN = COS(U)
  IF SN <> 0! THEN
    A = CN / SN
    C = A * C
    FOR II = L TO 1 STEP -1
      B = EM(II)
      A = C * A
      C = DN * C
      DN = (EN(II) + A) / (B + A)
      A = C / B
    NEXT II
    A = 1! / SQR(C ^ 2 + 1!)
    IF SN < 0! THEN
      SN = -A
    ELSE
      SN = A
    END IF
    CN = C * SN
  END IF
  IF BO& THEN
    A = DN
    DN = CN
    CN = A
    SN = SN / D
  END IF
ELSE
  CN = 1! / COSH(U)
  DN = CN
  SN = TANH(U)
END IF
ERASE EN, EM
END SUB

FUNCTION TANH (U)
EPU = EXP(U)
EMU = 1! / EPU
IF ABS(U) < .3 THEN
  U2 = U * U
  DUM = 1! + U2 / 6! * (1! + U2 / 20! * (1! + U2 / 42! * (1! + U2 / 72!)))
  TANH = 2! * U * DUM / (EPU + EMU)
ELSE
  TANH = (EPU - EMU) / (EPU + EMU)
END IF
END FUNCTION

