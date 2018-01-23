DECLARE FUNCTION RAN2! (IDUM&)

FUNCTION RAN2 (IDUM&) STATIC
M& = 714025
IA& = 1366
IC& = 150889
RM = .0000014005112#
DIM IR&(97)
IF IDUM& < 0 OR IFF = 0 THEN
  IFF = 1
  IDUM& = (IC& - IDUM&) MOD M&
  FOR J = 1 TO 97
    IDUM& = (IA& * IDUM& + IC&) MOD M&
    IR&(J) = IDUM&
  NEXT J
  IDUM& = (IA& * IDUM& + IC&) MOD M&
  IY& = IDUM&
END IF
J = 1 + INT((97 * IY&) / M&)
IF J > 97 OR J < 1 THEN PRINT "Abnormal exit": EXIT FUNCTION
IY& = IR&(J)
RAN2 = IY& * RM
IDUM& = (IA& * IDUM& + IC&) MOD M&
IR&(J) = IDUM&
END FUNCTION

