DECLARE SUB AVEVAR (DATQ!(), N!, AVE!, VAR!)
DECLARE FUNCTION BETAI! (A!, B!, X!)

SUB FTEST (DATA1(), N1, DATA2(), N2, F, PROB)
CALL AVEVAR(DATA1(), N1, AVE1, VAR1)
CALL AVEVAR(DATA2(), N2, AVE2, VAR2)
IF VAR1 > VAR2 THEN
  F = VAR1 / VAR2
  DF1 = N1 - 1
  DF2 = N2 - 1
ELSE
  F = VAR2 / VAR1
  DF1 = N2 - 1
  DF2 = N1 - 1
END IF
PROB = 2! * BETAI(.5 * DF2, .5 * DF1, DF2 / (DF2 + DF1 * F))
IF PROB > 1! THEN PROB = 2! - PROB
END SUB

