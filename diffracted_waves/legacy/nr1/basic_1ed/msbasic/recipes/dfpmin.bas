DECLARE SUB DFUNC (X!(), DF!())
DECLARE SUB LINMIN (P!(), XI!(), N!, FRET!)
DECLARE FUNCTION FUNC2! (P!(), N!)

SUB DFPMIN (P(), N, FTOL, ITER, FRET)
ITMAX = 200
EPS = 1E-10
DIM HESSIN(N, N), XI(N), G(N), DG(N), HDG(N)
FP = FUNC2(P(), N)
CALL DFUNC(P(), G())
FOR I = 1 TO N
  FOR J = 1 TO N
    HESSIN(I, J) = 0!
  NEXT J
  HESSIN(I, I) = 1!
  XI(I) = -G(I)
NEXT I
FOR ITS = 1 TO ITMAX
  ITER = ITS
  CALL LINMIN(P(), XI(), N, FRET)
  IF 2! * ABS(FRET - FP) <= FTOL * (ABS(FRET) + ABS(FP) + EPS) THEN
    ERASE HDG, DG, G, XI, HESSIN
    EXIT SUB
  END IF
  FP = FRET
  FOR I = 1 TO N
    DG(I) = G(I)
  NEXT I
  FRET = FUNC2(P(), N)
  CALL DFUNC(P(), G())
  FOR I = 1 TO N
    DG(I) = G(I) - DG(I)
  NEXT I
  FOR I = 1 TO N
    HDG(I) = 0!
    FOR J = 1 TO N
      HDG(I) = HDG(I) + HESSIN(I, J) * DG(J)
    NEXT J
  NEXT I
  FAC = 0!
  FAE = 0!
  FOR I = 1 TO N
    FAC = FAC + DG(I) * XI(I)
    FAE = FAE + DG(I) * HDG(I)
  NEXT I
  FAC = 1! / FAC
  FAD = 1! / FAE
  FOR I = 1 TO N
    DG(I) = FAC * XI(I) - FAD * HDG(I)
  NEXT I
  FOR I = 1 TO N
    FOR J = 1 TO N
      DUM = FAC * XI(I) * XI(J) - FAD * HDG(I) * HDG(J) + FAE * DG(I) * DG(J)
      HESSIN(I, J) = HESSIN(I, J) + DUM
    NEXT J
  NEXT I
  FOR I = 1 TO N
    XI(I) = 0!
    FOR J = 1 TO N
      XI(I) = XI(I) - HESSIN(I, J) * G(J)
    NEXT J
  NEXT I
NEXT ITS
PRINT "too many iterations in DFPMIN"
END SUB

