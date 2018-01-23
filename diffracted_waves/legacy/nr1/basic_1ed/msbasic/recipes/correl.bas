DECLARE SUB TWOFFT (DATA1!(), DATA2!(), FFT1!(), FFT2!(), N!)
DECLARE SUB REALFT (DATQ!(), N!, ISIGN!)

SUB CORREL (DATA1(), DATA2(), N, ANS())
DIM FFT(2 * N)
CALL TWOFFT(DATA1(), DATA2(), FFT(), ANS(), N)
NO2 = INT(N / 2)
FOR I = 1 TO NO2 + 1
  DUM = ANS(2 * I - 1)
  ANS(2 * I - 1) = (FFT(2 * I - 1) * DUM + FFT(2 * I) * ANS(2 * I)) / CSNG(NO2)
  ANS(2 * I) = (FFT(2 * I) * DUM - FFT(2 * I - 1) * ANS(2 * I)) / CSNG(NO2)
NEXT I
ANS(2) = ANS(N + 1)
CALL REALFT(ANS(), NO2, -1)
ERASE FFT
END SUB

