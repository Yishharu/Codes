SUB FGAUSS (X, A(), Y, DYDA(), NA)
Y = 0!
FOR I = 1 TO NA - 1 STEP 3
  ARG = (X - A(I + 1)) / A(I + 2)
  EX = EXP(-ARG ^ 2)
  FAC = A(I) * EX * 2! * ARG
  Y = Y + A(I) * EX
  DYDA(I) = EX
  DYDA(I + 1) = FAC / A(I + 2)
  DYDA(I + 2) = FAC * ARG / A(I + 2)
NEXT I
END SUB

