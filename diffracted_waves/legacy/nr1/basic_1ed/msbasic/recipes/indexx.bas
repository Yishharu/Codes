
SUB INDEXX (N, ARRIN(), INDX())
FOR J = 1 TO N
  INDX(J) = J
NEXT J
IF N = 1 THEN EXIT SUB
L = INT(N / 2 + 1)
IR = N
DO
  IF L > 1 THEN
    L = L - 1
    INDXT = INDX(L)
    Q = ARRIN(INDXT)
  ELSE
    INDXT = INDX(IR)
    Q = ARRIN(INDXT)
    INDX(IR) = INDX(1)
    IR = IR - 1
    IF IR = 1 THEN
      INDX(1) = INDXT
      EXIT SUB
    END IF
  END IF
  I = L
  J = L + L
  WHILE J <= IR
    IF J < IR THEN
      IF ARRIN(INDX(J)) < ARRIN(INDX(J + 1)) THEN J = J + 1
    END IF
    IF Q < ARRIN(INDX(J)) THEN
      INDX(I) = INDX(J)
      I = J
      J = J + J
    ELSE
      J = IR + 1
    END IF
  WEND
  INDX(I) = INDXT
LOOP
END SUB

