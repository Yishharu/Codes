SUB SORT2 (N, RA(), RB())
L = INT(N / 2) + 1
IR = N
DO
  IF L > 1 THEN
    L = L - 1
    RRA = RA(L)
    RRB = RB(L)
  ELSE
    RRA = RA(IR)
    RRB = RB(IR)
    RA(IR) = RA(1)
    RB(IR) = RB(1)
    IR = IR - 1
    IF IR = 1 THEN
      RA(1) = RRA
      RB(1) = RRB
      EXIT SUB
    END IF
  END IF
  I = L
  J = L + L
  WHILE J <= IR
    IF J < IR THEN
      IF RA(J) < RA(J + 1) THEN J = J + 1
    END IF
    IF RRA < RA(J) THEN
      RA(I) = RA(J)
      RB(I) = RB(J)
      I = J
      J = J + J
    ELSE
      J = IR + 1
    END IF
  WEND
  RA(I) = RRA
  RB(I) = RRB
LOOP
END SUB

