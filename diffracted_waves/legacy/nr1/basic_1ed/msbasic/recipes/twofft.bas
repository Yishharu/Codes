DECLARE SUB FOUR1 (DATQ!(), NN!, ISIGN!)

SUB TWOFFT (DATA1(), DATA2(), FFT1(), FFT2(), N)
C1R = .5
C1I = 0!
C2R = 0!
C2I = -.5
FOR J = 1 TO N
  FFT1(2 * J - 1) = DATA1(J)
  FFT1(2 * J) = DATA2(J)
NEXT J
CALL FOUR1(FFT1(), N, 1)
FFT2(1) = FFT1(2)
FFT2(2) = 0!
FFT1(2) = 0!
N2 = 2 * (N + 2)
FOR J = 2 TO N / 2 + 1
  J2 = 2 * J
  CONJR = FFT1(N2 - J2 - 1)
  CONJI = -FFT1(N2 - J2)
  H1R = C1R * (FFT1(J2 - 1) + CONJR) - C1I * (FFT1(J2) + CONJI)
  H1I = C1I * (FFT1(J2 - 1) + CONJR) + C1R * (FFT1(J2) + CONJI)
  H2R = C2R * (FFT1(J2 - 1) - CONJR) - C2I * (FFT1(J2) - CONJI)
  H2I = C2I * (FFT1(J2 - 1) - CONJR) + C2R * (FFT1(J2) - CONJI)
  FFT1(J2 - 1) = H1R
  FFT1(J2) = H1I
  FFT1(N2 - J2 - 1) = H1R
  FFT1(N2 - J2) = -H1I
  FFT2(J2 - 1) = H2R
  FFT2(J2) = H2I
  FFT2(N2 - J2 - 1) = H2R
  FFT2(N2 - J2) = -H2I
NEXT J
END SUB

