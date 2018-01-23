
SUB MDIAN2 (X(), N, XMED)
BIG = 1E+30
AFAC = 1.5
AMP = 1.5
A = .5 * (X(1) + X(N))
EPS = ABS(X(N) - X(1))
AP = BIG
AM = -BIG
1 SUM = 0!
SUMX = 0!
NP = 0
NM = 0
XP = BIG
XM = -BIG
FOR J = 1 TO N
  XX = X(J)
  IF XX <> A THEN
    IF XX > A THEN
      NP = NP + 1
      IF XX < XP THEN XP = XX
    ELSEIF XX < A THEN
      NM = NM + 1
      IF XX > XM THEN XM = XX
    END IF
    DUM = 1! / (EPS + ABS(XX - A))
    SUM = SUM + DUM
    SUMX = SUMX + XX * DUM
  END IF
NEXT J
IF NP - NM >= 2 THEN
  AM = A
  DUM = 0!
  IF SUMX / SUM - A > DUM THEN DUM = SUMX / SUM - A
  AA = XP + DUM * AMP
  IF AA > AP THEN AA = .5 * (A + AP)
  EPS = AFAC * ABS(AA - A)
  A = AA
  GOTO 1
ELSEIF NM - NP >= 2 THEN
  AP = A
  DUM = 0!
  IF SUMX / SUM - A < DUM THEN DUM = SUMX / SUM - A
  AA = XM + DUM * AMP
  IF AA < AM THEN AA = .5 * (A + AM)
  EPS = AFAC * ABS(AA - A)
  A = AA
  GOTO 1
ELSE
  IF N MOD 2 = 0 THEN
    IF NP = NM THEN
      XMED = .5 * (XP + XM)
    ELSEIF NP > NM THEN
      XMED = .5 * (A + XP)
    ELSE
      XMED = .5 * (XM + A)
    END IF
  ELSE
    IF NP = NM THEN
      XMED = A
    ELSEIF NP > NM THEN
      XMED = XP
    ELSE
      XMED = XM
    END IF
  END IF
END IF
END SUB

