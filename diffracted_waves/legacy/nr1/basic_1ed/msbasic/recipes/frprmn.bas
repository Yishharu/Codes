DECLARE SUB DFUNC (X!(), DF!())
DECLARE SUB LINMIN (P!(), XI!(), N!, FRET!)
DECLARE FUNCTION FUNC2! (P!(), N!)

SUB FRPRMN (P(), N, FTOL, ITER, FRET)
ITMAX = 200
EPS = 1E-10
DIM G(N), H(N), XI(N)
FP = FUNC2(P(), N)
CALL DFUNC(P(), XI())
FOR J = 1 TO N
  G(J) = -XI(J)
  H(J) = G(J)
  XI(J) = H(J)
NEXT J
FOR ITS = 1 TO ITMAX
  ITER = ITS
  CALL LINMIN(P(), XI(), N, FRET)
  IF 2! * ABS(FRET - FP) <= FTOL * (ABS(FRET) + ABS(FP) + EPS) THEN EXIT FOR
  FP = FUNC2(P(), N)
  CALL DFUNC(P(), XI())
  GG = 0!
  DGG = 0!
  FOR J = 1 TO N
    GG = GG + G(J) ^ 2
'   DGG = DGG + XI(J) ^ 2
    DGG = DGG + (XI(J) + G(J)) * XI(J)
  NEXT J
  IF GG = 0! THEN EXIT FOR
  GAM = DGG / GG
  FOR J = 1 TO N
    G(J) = -XI(J)
    H(J) = G(J) + GAM * H(J)
    XI(J) = H(J)
  NEXT J
NEXT ITS
IF ITS > ITMAX THEN PRINT "FRPR maximum iterations exceeded"
ERASE XI, H, G
END SUB

