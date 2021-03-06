DECLARE SUB CYFUN (TITMP&(), K&(), IOUT&())
DECLARE SUB KS (KEQ&(), N, KN&())
DATA 58,50,42,34,26,18,10,2,60,52,44,36,28,20,12,4,62,54,46,38,30,22,14,6,64
DATA 56,48,40,32,24,16,8,57,49,41,33,25,17,9,1,59,51,43,35,27,19,11,3,61,53,45
DATA 37,29,21,13,5,63,55,47,39,31,23,15,7
DATA 40,8,48,16,56,24,64,32,39,7,47,15,55,23,63,31,38,6,46,14,54,22,62,30,37
DATA 5,45,13,53,21,61,29,36,4,44,12,52,20,60,28,35,3,43,11,51,19,59,27,34,2,42
DATA 10,50,18,58,26,33,1,41,9,49,17,57,25

SUB DES (INPUQ&(), KEQ&(), NEWKEY, ISW, JOTPUT&()) STATIC
DIM ITMP&(64), TITMP&(32), IP(64), IPM(64), ICF&(32), TKNS&(48), KNS&(48, 16)
RESTORE
FOR I = 1 TO 64
  READ IP(I)
NEXT I
FOR I = 1 TO 64
  READ IPM(I)
NEXT I
IF NEWKEY <> 0 THEN
  NEWKEY = 0
  FOR I = 1 TO 16
    CALL KS(KEQ&(), I, TKNS&())
    FOR J = 1 TO 48
      KNS&(J, I) = TKNS&(J)
    NEXT J
  NEXT I
END IF
FOR J = 1 TO 64
  ITMP&(J) = INPUQ&(IP(J))
NEXT J
FOR I = 1 TO 16
  II = I
  IF ISW = 1 THEN II = 17 - I
  FOR J = 1 TO 48
    TKNS&(J) = KNS&(J, II)
  NEXT J
  FOR J = 1 TO 32
    TITMP&(J) = ITMP&(32 + J)
  NEXT J
  CALL CYFUN(TITMP&(), TKNS&(), ICF&())
  FOR J = 1 TO 32
    IC& = ICF&(J) + ITMP&(J)
    ITMP&(J) = ITMP&(J + 32)
    ITMP&(J + 32) = ABS(IC& MOD 2)
  NEXT J
NEXT I
FOR J = 1 TO 32
  IC& = ITMP&(J)
  ITMP&(J) = ITMP&(J + 32)
  ITMP&(J + 32) = IC&
NEXT J
FOR J = 1 TO 64
  JOTPUT&(J) = ITMP&(IPM(J))
NEXT J
END SUB

