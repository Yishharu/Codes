DECLARE FUNCTION GAMMQ! (A!, X!)

SUB CHSTWO (BINS1(), BINS2(), NBINS, KNSTRN, DF, CHSQ, PROB)
DF = NBINS - 1 - KNSTRN
CHSQ = 0!
FOR J = 1 TO NBINS
  IF BINS1(J) = 0! AND BINS2(J) = 0! THEN
    DF = DF - 1!
  ELSE
    CHSQ = CHSQ + (BINS1(J) - BINS2(J)) ^ 2 / (BINS1(J) + BINS2(J))
  END IF
NEXT J
PROB = GAMMQ(.5 * DF, .5 * CHSQ)
END SUB

