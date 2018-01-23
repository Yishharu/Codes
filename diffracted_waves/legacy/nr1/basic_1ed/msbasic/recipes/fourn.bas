
SUB FOURN (DATQ(), NN(), NDIM, ISIGN)
NTOT = 1
FOR IDIM = 1 TO NDIM
  NTOT = NTOT * NN(IDIM)
NEXT IDIM
NPREV = 1
FOR IDIM = 1 TO NDIM
  N = NN(IDIM)
  NREM = NTOT / (N * NPREV)
  IP1 = 2 * NPREV
  IP2 = IP1 * N
  IP3 = IP2 * NREM
  I2REV = 1
  FOR I2 = 1 TO IP2 STEP IP1
    IF I2 < I2REV THEN
      FOR I1 = I2 TO I2 + IP1 - 2 STEP 2
        FOR I3 = I1 TO IP3 STEP IP2
          I3REV = I2REV + I3 - I2
          TEMPR = DATQ(I3)
          TEMPI = DATQ(I3 + 1)
          DATQ(I3) = DATQ(I3REV)
          DATQ(I3 + 1) = DATQ(I3REV + 1)
          DATQ(I3REV) = TEMPR
          DATQ(I3REV + 1) = TEMPI
        NEXT I3
      NEXT I1
    END IF
    IBIT = IP2 / 2
    WHILE IBIT >= IP1 AND I2REV > IBIT
      I2REV = I2REV - IBIT
      IBIT = IBIT / 2
    WEND
    I2REV = I2REV + IBIT
  NEXT I2
  IFP1 = IP1
  WHILE IFP1 < IP2
    IFP2 = 2 * IFP1
    THETA# = ISIGN * 6.28318530717959# / (IFP2 / IP1)
    WPR# = -2# * SIN(.5# * THETA#) ^ 2
    WPI# = SIN(THETA#)
    WR# = 1#
    WI# = 0#
    FOR I3 = 1 TO IFP1 STEP IP1
      FOR I1 = I3 TO I3 + IP1 - 2 STEP 2
        FOR I2 = I1 TO IP3 STEP IFP2
          K1 = I2
          K2 = K1 + IFP1
          TEMPR = CSNG(WR#) * DATQ(K2) - CSNG(WI#) * DATQ(K2 + 1)
          TEMPI = CSNG(WR#) * DATQ(K2 + 1) + CSNG(WI#) * DATQ(K2)
          DATQ(K2) = DATQ(K1) - TEMPR
          DATQ(K2 + 1) = DATQ(K1 + 1) - TEMPI
          DATQ(K1) = DATQ(K1) + TEMPR
          DATQ(K1 + 1) = DATQ(K1 + 1) + TEMPI
        NEXT I2
      NEXT I1
      WTEMP# = WR#
      WR# = WR# * WPR# - WI# * WPI# + WR#
      WI# = WI# * WPR# + WTEMP# * WPI# + WI#
    NEXT I3
    IFP1 = IFP2
  WEND
  NPREV = N * NPREV
NEXT IDIM
END SUB

