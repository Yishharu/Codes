DECLARE FUNCTION RAN4! (IDUM&)
DECLARE SUB DES (INPUQ&(), KEQ&(), NEWKEY!, ISW!, JOT&())

FUNCTION RAN4 (IDUM&) STATIC
IM& = 11979
IA& = 430
IC& = 2531
NACC = 24
DIM INQ&(64), JOT&(64), KEQ&(64), POW(65)
IF IDUM& < 0 OR IFF = 0 THEN
  IFF = 1
  IDUM& = IDUM& MOD IM&
  IF IDUM& < 0 THEN IDUM& = IDUM& + IM&
  POW(1) = .5
  FOR J = 1 TO 64
    IDUM& = (IDUM& * IA& + IC&) MOD IM&
    KEQ&(J) = (2 * IDUM&) \ IM&
    INQ&(J) = ((4 * IDUM&) \ IM&) MOD 2
    POW(J + 1) = .5 * POW(J)
  NEXT J
  NEWKEY = 1
END IF
ISAV& = INQ&(64)
IF ISAV& <> 0 THEN
  INQ&(4) = 1 - INQ&(4)
  INQ&(3) = 1 - INQ&(3)
  INQ&(1) = 1 - INQ&(1)
END IF
FOR J = 64 TO 2 STEP -1
  INQ&(J) = INQ&(J - 1)
NEXT J
INQ&(1) = ISAV&
CALL DES(INQ&(), KEQ&(), NEWKEY, 0, JOT&())
DUM = 0!
FOR J = 1 TO NACC
  IF JOT&(J) <> 0 THEN DUM = DUM + POW(J)
NEXT J
RAN4 = DUM
END FUNCTION

