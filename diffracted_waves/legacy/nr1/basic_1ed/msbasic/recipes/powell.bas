DECLARE SUB LINMIN (P!(), XI!(), N!, FRET!)
DECLARE FUNCTION FUNC2! (X!(), N!)

SUB POWELL (P(), XI(), N, NP, FTOL, ITER, FRET)
ITMAX = 200
DIM PT(N), PTT(N), XIT(N)
FRET = FUNC2(P(), N)
FOR J = 1 TO N
  PT(J) = P(J)
NEXT J
ITER = 0
DO
  DO
    DO
      ITER = ITER + 1
      FP = FRET
      IBIG = 0
      DEL = 0!
      FOR I = 1 TO N
        FOR J = 1 TO N
          XIT(J) = XI(J, I)
        NEXT J
        FPTT = FRET
        CALL LINMIN(P(), XIT(), N, FRET)
        IF ABS(FPTT - FRET) > DEL THEN
          DEL = ABS(FPTT - FRET)
          IBIG = I
        END IF
      NEXT I
      IF 2! * ABS(FP - FRET) <= FTOL * (ABS(FP) + ABS(FRET)) THEN
        ERASE XIT, PTT, PT
        EXIT SUB
      END IF
      IF ITER = ITMAX THEN
        PRINT "Powell exceeding maximum iterations."
        EXIT SUB
      END IF
      FOR J = 1 TO N
        PTT(J) = 2! * P(J) - PT(J)
        XIT(J) = P(J) - PT(J)
        PT(J) = P(J)
      NEXT J
      FPTT = FUNC2(PTT(), N)
    LOOP WHILE FPTT >= FP
    DUM = FP - 2! * FRET + FPTT
    T = 2! * DUM * (FP - FRET - DEL) ^ 2 - DEL * (FP - FPTT) ^ 2
  LOOP WHILE T >= 0!
  CALL LINMIN(P(), XIT(), N, FRET)
  FOR J = 1 TO N
    XI(J, IBIG) = XIT(J)
  NEXT J
LOOP
END SUB

