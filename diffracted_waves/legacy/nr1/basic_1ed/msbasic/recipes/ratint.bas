SUB RATINT (XA(), YA(), N, X, Y, DY)
TINY = 1E-25
DIM C(N), D(N)
NS = 1
HH = ABS(X - XA(1))
FOR I = 1 TO N
  H = ABS(X - XA(I))
  IF H = 0! THEN
    Y = YA(I)
    DY = 0!
    ERASE D, C
    EXIT SUB
  ELSEIF H < HH THEN
    NS = I
    HH = H
  END IF
  C(I) = YA(I)
  D(I) = YA(I) + TINY
NEXT I
Y = YA(NS)
NS = NS - 1
FOR M = 1 TO N - 1
  FOR I = 1 TO N - M
    W = C(I + 1) - D(I)
    H = XA(I + M) - X
    T = (XA(I) - X) * D(I) / H
    DD = T - C(I + 1)
    IF DD = 0! THEN PRINT "Abnormal exit": EXIT SUB
    DD = W / DD
    D(I) = C(I + 1) * DD
    C(I) = T * DD
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

