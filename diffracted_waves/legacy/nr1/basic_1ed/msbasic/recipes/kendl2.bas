DECLARE FUNCTION ERFCC! (X!)

SUB KENDL2 (TAQ(), I, J, IP, JP, TAU, Z, PROB)
EN1 = 0!
EN2 = 0!
S = 0!
NN = I * J
POINTS = TAQ(I, J)
FOR K = 0 TO NN - 2
  KI = INT(K / J)
  KJ = K - J * KI
  POINTS = POINTS + TAQ(KI + 1, KJ + 1)
  FOR L = K + 1 TO NN - 1
    LI = INT(L / J)
    LJ = L - J * LI
    M1 = LI - KI
    M2 = LJ - KJ
    MM = M1 * M2
    PAIRS = TAQ(KI + 1, KJ + 1) * TAQ(LI + 1, LJ + 1)
    IF MM <> 0 THEN
      EN1 = EN1 + PAIRS
      EN2 = EN2 + PAIRS
      IF MM > 0 THEN
        S = S + PAIRS
      ELSE
        S = S - PAIRS
      END IF
    ELSE
      IF M1 <> 0 THEN EN1 = EN1 + PAIRS
      IF M2 <> 0 THEN EN2 = EN2 + PAIRS
    END IF
  NEXT L
NEXT K
TAU = S / SQR(EN1 * EN2)
VAR = (4! * POINTS + 10!) / (9! * POINTS * (POINTS - 1!))
Z = TAU / SQR(VAR)
PROB = ERFCC(ABS(Z) / 1.4142136#)
END SUB

