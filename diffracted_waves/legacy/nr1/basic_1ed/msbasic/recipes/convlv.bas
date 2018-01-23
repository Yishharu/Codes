DECLARE SUB TWOFFT (DATA1!(), DATA2!(), FFT1!(), FFT2!(), N!)
DECLARE SUB REALFT (DATQ!(), N!, ISIGN!)

SUB CONVLV (DATQ(), N, RESPNS(), M, ISIGN, ANS())
DIM FFT(2 * N)
FOR I = 1 TO INT((M - 1) / 2)
  RESPNS(N + 1 - I) = RESPNS(M + 1 - I)
NEXT I
FOR I = INT((M + 3) / 2) TO N - INT((M - 1) / 2)
  RESPNS(I) = 0!
NEXT I
CALL TWOFFT(DATQ(), RESPNS(), FFT(), ANS(), N)
NO2 = INT(N / 2)
FOR I = 1 TO NO2 + 1
  IF ISIGN = 1 THEN
    DUM = ANS(2 * I - 1)
    ANS(2 * I - 1) = (FFT(2 * I - 1) * DUM - FFT(2 * I) * ANS(2 * I)) / NO2
    ANS(2 * I) = (FFT(2 * I - 1) * ANS(2 * I) + FFT(2 * I) * DUM) / NO2
  ELSEIF ISIGN = -1 THEN
    IF DUM = 0! AND ANS(2 * I) = 0! THEN
      PRINT "deconvolving at a response zero"
      EXIT SUB
    END IF
    ANS = FFT(2 * I - 1) * DUM + FFT(2 * I) * ANS(2 * I)
    ANS(2 * I - 1) = ANS / (DUM * DUM + ANS(2 * I) * ANS(2 * I)) / NO2
    ANS = FFT(2 * I) * DUM - FFT(2 * I - 1) * ANS(2 * I)
    ANS(2 * I) = ANS / (DUM * DUM + ANS(2 * I) * ANS(2 * I)) / NO2
  ELSE
    PRINT "no meaning for ISIGN"
    EXIT SUB
  END IF
NEXT I
ANS(2) = ANS(2 * NO2 + 1)
CALL REALFT(ANS(), NO2, -1)
ERASE FFT
END SUB

