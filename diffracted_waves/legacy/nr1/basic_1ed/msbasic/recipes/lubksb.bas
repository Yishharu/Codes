SUB LUBKSB (A(), N, NP, INDX(), B())
II = 0
FOR I = 1 TO N
  LL = INDX(I)
  SUM = B(LL)
  B(LL) = B(I)
  IF II <> 0 THEN
    FOR J = II TO I - 1
      SUM = SUM - A(I, J) * B(J)
    NEXT J
  ELSEIF SUM <> 0! THEN
    II = I
  END IF
  B(I) = SUM
NEXT I
FOR I = N TO 1 STEP -1
  SUM = B(I)
  FOR J = I + 1 TO N
    SUM = SUM - A(I, J) * B(J)
  NEXT J
  B(I) = SUM / A(I, I)
NEXT I
END SUB

