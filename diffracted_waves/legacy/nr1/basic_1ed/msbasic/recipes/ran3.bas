DECLARE FUNCTION RAN3! (IDUM&)

FUNCTION RAN3 (IDUM&) STATIC
MBIG& = 1000000000
MSEED& = 161803398
MZ& = 0
FAC = 1E-09
DIM MA&(55)
IF IDUM& < 0 OR IFF = 0 THEN
  IFF = 1
  MJ& = MSEED& - ABS(IDUM&)
  MJ& = MJ& - MBIG& * INT(MJ& / MBIG&)
  MA&(55) = MJ&
  MK& = 1
  FOR I = 1 TO 54
    II = 21 * I - 55 * INT((21 * I) / 55)
    MA&(II) = MK&
    MK& = MJ& - MK&
    IF MK& < MZ& THEN MK& = MK& + MBIG&
    MJ& = MA&(II)
  NEXT I
  FOR K = 1 TO 4
    FOR I = 1 TO 55
      MA&(I) = MA&(I) - MA&(1 + I + 30 - 55 * INT((I + 30) / 55))
      IF MA&(I) < MZ& THEN MA&(I) = MA&(I) + MBIG&
    NEXT I
  NEXT K
  INEXT = 0
  INEXTP = 31
  IDUM& = 1
END IF
INEXT = INEXT + 1
IF INEXT = 56 THEN INEXT = 1
INEXTP = INEXTP + 1
IF INEXTP = 56 THEN INEXTP = 1
MJ& = MA&(INEXT) - MA&(INEXTP)
IF MJ& < MZ& THEN MJ& = MJ& + MBIG&
MA&(INEXT) = MJ&
RAN3 = MJ& * FAC
END FUNCTION

