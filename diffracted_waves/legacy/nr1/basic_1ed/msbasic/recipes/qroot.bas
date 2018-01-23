DECLARE SUB POLDIV (U!(), N!, V!(), NV!, Q!(), R!())

SUB QROOT (P(), N, B, C, EPS)
ITMAX = 20
TINY = .000001
DIM Q(N), D(3), REQ(N), QQ(N)
D(3) = 1!
FOR ITER = 1 TO ITMAX
  D(2) = B
  D(1) = C
  CALL POLDIV(P(), N, D(), 3, Q(), REQ())
  S = REQ(1)
  R = REQ(2)
  CALL POLDIV(Q(), N - 1, D(), 3, QQ(), REQ())
  SC = -REQ(1)
  RC = -REQ(2)
  FOR I = N - 1 TO 1 STEP -1
    Q(I + 1) = Q(I)
  NEXT I
  Q(1) = 0!
  CALL POLDIV(Q(), N, D(), 3, QQ(), REQ())
  SB = -REQ(1)
  RB = -REQ(2)
  DIV = 1! / (SB * RC - SC * RB)
  DELB = (R * SC - S * RC) * DIV
  DELC = (-R * SB + S * RB) * DIV
  B = B + DELB
  C = C + DELC
  DB = ABS(DELB) - EPS * ABS(B)
  DC = ABS(DELC) - EPS * ABS(C)
  IF (DB <= 0 OR ABS(B) < TINY) AND (DC <= 0 OR ABS(C) < TINY) THEN
    ERASE QQ, REQ, D, Q
    EXIT SUB
  END IF
NEXT ITER
PRINT "too many iterations in QROOT"
END SUB

