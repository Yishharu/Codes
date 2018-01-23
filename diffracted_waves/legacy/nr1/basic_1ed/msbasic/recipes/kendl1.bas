DECLARE FUNCTION ERFCC! (X!)

SUB KENDL1 (DATA1(), DATA2(), N, TAU, Z, PROB)
N1 = 0
N2 = 0
IQ = 0
FOR J = 1 TO N - 1
  FOR K = J + 1 TO N
    A1 = DATA1(J) - DATA1(K)
    A2 = DATA2(J) - DATA2(K)
    AA = A1 * A2
    IF AA <> 0! THEN
      N1 = N1 + 1
      N2 = N2 + 1
      IF AA > 0! THEN
        IQ = IQ + 1
      ELSE
        IQ = IQ - 1
      END IF
    ELSE
      IF A1 <> 0! THEN N1 = N1 + 1
      IF A2 <> 0! THEN N2 = N2 + 1
    END IF
  NEXT K
NEXT J
TAU = CSNG(IQ) / SQR(CSNG(N1) * CSNG(N2))
VAR = (4! * N + 10!) / (9! * N * (N - 1!))
Z = TAU / SQR(VAR)
PROB = ERFCC(ABS(Z) / 1.4142136#)
END SUB

