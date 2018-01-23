DECLARE SUB ASUB (XIN!(), XOUT!())
DECLARE SUB ATSUB (XIN!(), XOUT!())

SUB SPARSE (B(), N, DUM1, DUM2, X(), RSQ)
EPS = .000001
DIM G(N), H(N), XI(N), XJ(N)
EPS2 = N * EPS ^ 2
IRST = 0
DO
  DONE% = -1
  IRST = IRST + 1
  CALL ASUB(X(), XI())
  RP = 0!
  BSQ = 0!
  FOR J = 1 TO N
    BSQ = BSQ + B(J) ^ 2
    XI(J) = XI(J) - B(J)
    RP = RP + XI(J) ^ 2
  NEXT J
  CALL ATSUB(XI(), G())
  FOR J = 1 TO N
    G(J) = -G(J)
    H(J) = G(J)
  NEXT J
  FOR ITER = 1 TO 10 * N
    CALL ASUB(H(), XI())
    ANUM = 0!
    ADEN = 0!
    FOR J = 1 TO N
      ANUM = ANUM + G(J) * H(J)
      ADEN = ADEN + XI(J) ^ 2
    NEXT J
    IF ADEN = 0! THEN PRINT "very singular matrix": EXIT SUB
    ANUM = ANUM / ADEN
    FOR J = 1 TO N
      XI(J) = X(J)
      X(J) = X(J) + ANUM * H(J)
    NEXT J
    CALL ASUB(X(), XJ())
    RSQ = 0!
    FOR J = 1 TO N
      XJ(J) = XJ(J) - B(J)
      RSQ = RSQ + XJ(J) ^ 2
    NEXT J
    IF RSQ = RP OR RSQ <= BSQ * EPS2 THEN ERASE XJ, XI, H, G: EXIT SUB
    IF RSQ > RP THEN
      FOR J = 1 TO N
        X(J) = XI(J)
      NEXT J
      IF IRST >= 3 THEN ERASE XJ, XI, H, G: EXIT SUB
      DONE% = 0
    END IF
    IF NOT DONE% THEN EXIT FOR
    RP = RSQ
    CALL ATSUB(XJ(), XI())
    GG = 0!
    DGG = 0!
    FOR J = 1 TO N
      GG = GG + G(J) ^ 2
      DGG = DGG + (XI(J) + G(J)) * XI(J)
    NEXT J
    IF GG = 0! THEN ERASE XJ, XI, H, G: EXIT SUB
    GAM = DGG / GG
    FOR J = 1 TO N
      G(J) = -XI(J)
      H(J) = G(J) + GAM * H(J)
    NEXT J
  NEXT ITER
LOOP WHILE NOT DONE%
IF ITER = 10 * N THEN PRINT "too many iterations"
END SUB

