DECLARE SUB REALFT (DATQ!(), N!, ISIGN!)

SUB SMOOFT (Y(), N, PTS)
M = 2
NMIN = N + INT(2! * PTS)
WHILE M < NMIN
  M = 2 * M
WEND
IF M > 1024 THEN PRINT "M too small": EXIT SUB
CONSQ = (PTS / M) ^ 2
Y1 = Y(1)
YN = Y(N)
RN1 = 1! / (N - 1!)
FOR J = 1 TO N
  Y(J) = Y(J) - RN1 * (Y1 * (N - J) + YN * (J - 1))
NEXT J
FOR J = N + 1 TO M
  Y(J) = 0!
NEXT J
MO2 = INT(M / 2)
CALL REALFT(Y(), MO2, 1)
Y(1) = Y(1) / MO2
FAC = 1!
FOR J = 1 TO MO2 - 1
  K = 2 * J + 1
  IF FAC <> 0! THEN
    FAC = (1! - CONSQ * J ^ 2) / MO2
    IF FAC < 0! THEN FAC = 0!
    Y(K) = FAC * Y(K)
    Y(K + 1) = FAC * Y(K + 1)
  ELSE
    Y(K) = 0!
    Y(K + 1) = 0!
  END IF
NEXT J
FAC = (1! - .25 * PTS ^ 2) / MO2
IF FAC < 0! THEN FAC = 0!
Y(2) = FAC * Y(2)
CALL REALFT(Y(), MO2, -1)
FOR J = 1 TO N
  Y(J) = RN1 * (Y1 * (N - J) + YN * (J - 1)) + Y(J)
NEXT J
END SUB

