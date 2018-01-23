DECLARE FUNCTION EL2! (X!, QQC!, AA!, BB!)

FUNCTION EL2 (X, QQC, AA, BB)
PI = 3.14159265#
CA = .0003
CB = 1E-09
IF X = 0! THEN
  EL2 = 0!
ELSEIF QQC <> 0! THEN
  QC = QQC
  A = AA
  B = BB
  C = X ^ 2
  D = 1! + C
  P = SQR((1! + QC ^ 2 * C) / D)
  D = X / D
  C = D / (2! * P)
  Z = A - B
  EYE = A
  A = .5 * (B + A)
  Y = ABS(1! / X)
  F = 0!
  L = 0
  EM = 1!
  QC = ABS(QC)
  DO
    B = EYE * QC + B
    E = EM * QC
    G = E / P
    D = F * G + D
    F = C
    EYE = A
    P = G + P
    C = .5 * (D / P + C)
    G = EM
    EM = QC + EM
    A = .5 * (B / EM + A)
    Y = -E / Y + Y
    IF Y = 0! THEN Y = SQR(E) * CB
    IF ABS(G - QC) > CA * G THEN
      QC = SQR(E) * 2!
      L = L + L
      IF Y < 0! THEN L = L + 1
      DONE% = 0
    ELSE
      DONE% = -1
    END IF
  LOOP WHILE NOT DONE%
  IF Y < 0! THEN L = L + 1
  E = (ATN(EM / Y) + PI * L) * A / EM
  IF X < 0! THEN E = -E
  EL2 = E + C * Z
ELSE
  PRINT "failure in EL2"
  EXIT FUNCTION
END IF
END FUNCTION

