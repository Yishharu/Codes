DECLARE SUB INDEXX (N!, ARRIN!(), INDX!())

SUB SORT3 (N, RA(), RB(), RC(), WKSP(), IWKSP())
CALL INDEXX(N, RA(), IWKSP())
FOR J = 1 TO N
  WKSP(J) = RA(J)
NEXT J
FOR J = 1 TO N
  RA(J) = WKSP(IWKSP(J))
NEXT J
FOR J = 1 TO N
  WKSP(J) = RB(J)
NEXT J
FOR J = 1 TO N
  RB(J) = WKSP(IWKSP(J))
NEXT J
FOR J = 1 TO N
  WKSP(J) = RC(J)
NEXT J
FOR J = 1 TO N
  RC(J) = WKSP(IWKSP(J))
NEXT J
END SUB

