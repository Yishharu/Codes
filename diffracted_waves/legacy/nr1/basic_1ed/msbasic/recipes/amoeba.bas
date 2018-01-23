DECLARE FUNCTION AMOEB! (X!(), NDIM!)

SUB AMOEBA (P(), Y(), MP, NP, NDIM, FTOL, DUM, ITER)
ALPHA = 1!
BETA = .5
GAMMA = 2!
ITMAX = 500
DIM PR(NDIM), PRR(NDIM), PBAR(NDIM)
MPTS = NDIM + 1
ITER = 0
DO
  ILO = 1
  IF Y(1) > Y(2) THEN
    IHI = 1
    INHI = 2
  ELSE
    IHI = 2
    INHI = 1
  END IF
  FOR I = 1 TO MPTS
    IF Y(I) < Y(ILO) THEN ILO = I
    IF Y(I) > Y(IHI) THEN
      INHI = IHI
      IHI = I
    ELSEIF Y(I) > Y(INHI) THEN
      IF I <> IHI THEN INHI = I
    END IF
  NEXT I
  RTOL = 2! * ABS(Y(IHI) - Y(ILO)) / (ABS(Y(IHI)) + ABS(Y(ILO)))
  IF RTOL < FTOL THEN ERASE PBAR, PRR, PR: EXIT SUB
  IF ITER = ITMAX THEN PRINT "Amoeba exceeding maximum iterations.": EXIT SUB
  ITER = ITER + 1
  FOR J = 1 TO NDIM
    PBAR(J) = 0!
  NEXT J
  FOR I = 1 TO MPTS
    IF I <> IHI THEN
      FOR J = 1 TO NDIM
        PBAR(J) = PBAR(J) + P(I, J)
      NEXT J
    END IF
  NEXT I
  FOR J = 1 TO NDIM
    PBAR(J) = PBAR(J) / NDIM
    PR(J) = (1! + ALPHA) * PBAR(J) - ALPHA * P(IHI, J)
  NEXT J
  YPR = AMOEB(PR(), NDIM)
  IF YPR <= Y(ILO) THEN
    FOR J = 1 TO NDIM
      PRR(J) = GAMMA * PR(J) + (1! - GAMMA) * PBAR(J)
    NEXT J
    YPRR = AMOEB(PRR(), NDIM)
    IF YPRR < Y(ILO) THEN
      FOR J = 1 TO NDIM
        P(IHI, J) = PRR(J)
      NEXT J
      Y(IHI) = YPRR
    ELSE
      FOR J = 1 TO NDIM
        P(IHI, J) = PR(J)
      NEXT J
      Y(IHI) = YPR
    END IF
  ELSEIF YPR >= Y(INHI) THEN
    IF YPR < Y(IHI) THEN
      FOR J = 1 TO NDIM
        P(IHI, J) = PR(J)
      NEXT J
      Y(IHI) = YPR
    END IF
    FOR J = 1 TO NDIM
      PRR(J) = BETA * P(IHI, J) + (1! - BETA) * PBAR(J)
    NEXT J
    YPRR = AMOEB(PRR(), NDIM)
    IF YPRR < Y(IHI) THEN
      FOR J = 1 TO NDIM
        P(IHI, J) = PRR(J)
      NEXT J
      Y(IHI) = YPRR
    ELSE
      FOR I = 1 TO MPTS
        IF I <> ILO THEN
          FOR J = 1 TO NDIM
            PR(J) = .5 * (P(I, J) + P(ILO, J))
            P(I, J) = PR(J)
          NEXT J
          Y(I) = AMOEB(PR(), NDIM)
        END IF
      NEXT I
    END IF
  ELSE
    FOR J = 1 TO NDIM
      P(IHI, J) = PR(J)
    NEXT J
    Y(IHI) = YPR
  END IF
LOOP
END SUB

