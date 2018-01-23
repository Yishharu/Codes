DECLARE FUNCTION CEL! (QQC!, PP!, AA!, BB!)

FUNCTION CEL (QQC, PP, AA, BB)
CA = .0003
PIO2 = 1.5707963268#
IF QQC = 0! THEN PRINT "failure in CEL": EXIT FUNCTION
QC = ABS(QQC)
A = AA
B = BB
P = PP
E = QC
EM = 1!
IF P > 0! THEN
  P = SQR(P)
  B = B / P
ELSE
  F = QC * QC
  Q = 1! - F
  G = 1! - P
  F = F - P
  Q = Q * (B - A * P)
  P = SQR(F / G)
  A = (A - B) / G
  B = -Q / (G * G * P) + A * P
END IF
DO
  F = A
  A = A + B / P
  G = E / P
  B = B + F * G
  B = B + B
  P = G + P
  G = EM
  EM = QC + EM
  IF ABS(G - QC) > G * CA THEN
    QC = SQR(E)
    QC = QC + QC
    E = QC * EM
    DONE% = 0
  ELSE
    DONE% = -1
  END IF
LOOP WHILE NOT DONE%
CEL = PIO2 * (B + A * EM) / (EM * (EM + P))
END FUNCTION

