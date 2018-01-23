DECLARE FUNCTION FUNC! (X!)

SUB SCRSHO (DUM)
ISCR = 60
JSCR = 21
DIM Y(ISCR), SCR$(ISCR, JSCR)
BLANK$ = " "
ZERO$ = "-"
YY$ = "l"
XX$ = "-"
FF$ = "x"
DO
  PRINT " Enter X1,X2 (= to stop)"
  INPUT X1, X2
  IF X1 = X2 THEN ERASE SCR$, Y: EXIT SUB
  FOR J = 1 TO JSCR
    SCR$(1, J) = YY$
    SCR$(ISCR, J) = YY$
  NEXT J
  FOR I = 2 TO ISCR - 1
    SCR$(I, 1) = XX$
    SCR$(I, JSCR) = XX$
    FOR J = 2 TO JSCR - 1
      SCR$(I, J) = BLANK$
    NEXT J
  NEXT I
  DX = (X2 - X1) / CSNG(ISCR - 1)
  X = X1
  YBIG = 0!
  YSML = YBIG
  FOR I = 1 TO ISCR
    Y(I) = FUNC(X)
    IF Y(I) < YSML THEN YSML = Y(I)
    IF Y(I) > YBIG THEN YBIG = Y(I)
    X = X + DX
  NEXT I
  IF YBIG = YSML THEN YBIG = YSML + 1!
  DYJ = CSNG(JSCR - 1) / (YBIG - YSML)
  JZ = 1 - YSML * DYJ
  FOR I = 1 TO ISCR
    SCR$(I, JZ) = ZERO$
    J = 1 + (Y(I) - YSML) * DYJ
    SCR$(I, J) = FF$
  NEXT I
  PRINT USING "##.###^^^^"; YBIG;
  PRINT " ";
  FOR I = 1 TO ISCR
    PRINT SCR$(I, JSCR);
  NEXT I
  PRINT
  FOR J = JSCR - 1 TO 2 STEP -1
    PRINT "           ";
    FOR I = 1 TO ISCR
      PRINT SCR$(I, J);
    NEXT I
    PRINT
  NEXT J
  PRINT USING "##.###^^^^"; YSML;
  PRINT " ";
  FOR I = 1 TO ISCR
    PRINT SCR$(I, 1);
  NEXT I
  PRINT
  PRINT "           ";
  PRINT USING "##.###^^^^"; X1;
  PRINT SPACE$(40);
  PRINT USING "##.###^^^^"; X2
LOOP
END SUB

