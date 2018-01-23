SUB AVEVAR (DATQ(), N, AVE, VAR)
AVE = 0!
VAR = 0!
FOR J = 1 TO N
  AVE = AVE + DATQ(J)
NEXT J
AVE = AVE / N
FOR J = 1 TO N
  S = DATQ(J) - AVE
  VAR = VAR + S * S
NEXT J
VAR = VAR / (N - 1)
END SUB

