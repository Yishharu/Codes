SUB PIKSRT (N, ARR())
FOR J = 2 TO N
  A = ARR(J)
  FOR I = J - 1 TO 1 STEP -1
    IF ARR(I) <= A THEN EXIT FOR
    ARR(I + 1) = ARR(I)
  NEXT I
  IF ARR(I) > A THEN I = 0
  ARR(I + 1) = A
NEXT J
END SUB

