SUB PIKSR2 (N, ARR(), BRR())
FOR J = 2 TO N
  A = ARR(J)
  B = BRR(J)
  FOR I = J - 1 TO 1 STEP -1
    IF ARR(I) <= A THEN EXIT FOR
    ARR(I + 1) = ARR(I)
    BRR(I + 1) = BRR(I)
  NEXT I
  IF ARR(I) > A THEN I = 0
  ARR(I + 1) = A
  BRR(I + 1) = B
NEXT J
END SUB

