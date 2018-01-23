DECLARE SUB FUNCS (X!, A!(), Y!, DYDA!(), NA!)
DECLARE SUB FGAUSS (X!, A!(), Y!, DYDA!(), NA!)

SUB FUNCS (X, A(), Y, DYDA(), NA)
CALL FGAUSS(X, A(), Y, DYDA(), NA)
END SUB

SUB MRQCOF (X(), Y(), SIG(), NDATA, A(), MA, LISTA(), MFIT, ALPHA(), BETA(), NALP, CHISQ, DUM)
DIM DYDA(MA)
FOR J = 1 TO MFIT
  FOR K = 1 TO J
    ALPHA(J, K) = 0!
  NEXT K
  BETA(J, 1) = 0!
NEXT J
CHISQ = 0!
FOR I = 1 TO NDATA
  CALL FUNCS(X(I), A(), YMOD, DYDA(), MA)
  SIG2I = 1! / (SIG(I) * SIG(I))
  DY = Y(I) - YMOD
  FOR J = 1 TO MFIT
    WT = DYDA(LISTA(J)) * SIG2I
    FOR K = 1 TO J
      ALPHA(J, K) = ALPHA(J, K) + WT * DYDA(LISTA(K))
    NEXT K
    BETA(J, 1) = BETA(J, 1) + DY * WT
  NEXT J
  CHISQ = CHISQ + DY * DY * SIG2I
NEXT I
FOR J = 2 TO MFIT
  FOR K = 1 TO J - 1
    ALPHA(K, J) = ALPHA(J, K)
  NEXT K
NEXT J
ERASE DYDA
END SUB

