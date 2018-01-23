SUB POLINT (XA(), YA(), N, X, Y, DY)
DIM C(N), D(N)
NS = 1
DIF = ABS(X - XA(1))
FOR I = 1 TO N
  DIFT = ABS(X - XA(I))
  IF DIFT < DIF THEN
    NS = I
    DIF = DIFT
  END IF
  C(I) = YA(I)
  D(I) = YA(I)
NEXT I
Y = YA(NS)
NS = NS - 1
FOR M = 1 TO N - 1
  FOR I = 1 TO N - M
    HO = XA(I) - X
    HP = XA(I + M) - X
    W = C(I + 1) - D(I)
    DEN = HO - HP
    IF DEN = 0! THEN PRINT "Abnormal exit": EXIT SUB
    DEN = W / DEN
    D(I) = HP * DEN
    C(I) = HO * DEN
  NEXT I
  IF 2 * NS < N - M THEN
    DY = C(NS + 1)
  ELSE
    DY = D(NS)
    NS = NS - 1
  END IF
  Y = Y + DY
NEXT M
ERASE D, C
END SUB

