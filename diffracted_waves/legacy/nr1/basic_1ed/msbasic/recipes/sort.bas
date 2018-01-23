SUB SORT (N, RA())
L = INT(N / 2) + 1
IR = N
DO
  IF L > 1 THEN
    L = L - 1
    RRA = RA(L)
  ELSE
    RRA = RA(IR)
    RA(IR) = RA(1)
    IR = IR - 1
    IF IR = 1 THEN
      RA(1) = RRA
      EXIT SUB
    END IF
  END IF
  I = L
  J = L + L
  WHILE J <= IR
    IF J < IR THEN IF RA(J) < RA(J + 1) THEN J = J + 1
    IF RRA < RA(J) THEN
      RA(I) = RA(J)
      I = J
      J = J + J
    ELSE
      J = IR + 1
    END IF
  WEND
  RA(I) = RRA
LOOP
END SUB

