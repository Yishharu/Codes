SUB SVBKSB (U(), W(), V(), M, N, MP, NP, B(), X())
DIM TMP(N)
FOR J = 1 TO N
  S = 0!
  IF W(J) <> 0! THEN
    FOR I = 1 TO M
      S = S + U(I, J) * B(I)
    NEXT I
    S = S / W(J)
  END IF
  TMP(J) = S
NEXT J
FOR J = 1 TO N
  S = 0!
  FOR JJ = 1 TO N
    S = S + V(J, JJ) * TMP(JJ)
  NEXT JJ
  X(J) = S
NEXT J
ERASE TMP
END SUB

