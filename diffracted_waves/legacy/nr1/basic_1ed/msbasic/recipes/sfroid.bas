DECLARE SUB SOLVDE (ITMAX!, CONV!, SLOWC!, SCALV!(), INDEXV!(), NE!, NB!, M!, Y!(), NYJ!, NYK!, C!(), NCI!, NCJ!, NCK!, S!())
DECLARE FUNCTION PLGNDR! (L!, M!, X!)
COMMON X(), H, MM, N, C2, ANORM

'PROGRAM SFROID
CLS
NE = 3
M = 41
NB = 1
NCI = NE
NCJ = NE - NB + 1
NCK = M + 1
NSI = NE
NSJ = 2 * NE + 1
NYJ = NE
NYK = M
DIM X(M), SCALV(NE), INDEXV(NE), Y(NE, M), C(NCI, NCJ, NCK), S(NSI, NSJ)
ITMAX = 100
CONV = .000005
SLOWC = 1!
H = 1! / (M - 1)
C2 = 0!
PRINT "ENTER M,N"
INPUT MM, N
IF (N + MM) MOD 2 = 1 THEN
  INDEXV(1) = 1
  INDEXV(2) = 2
  INDEXV(3) = 3
ELSE
  INDEXV(1) = 2
  INDEXV(2) = 1
  INDEXV(3) = 3
END IF
ANORM = 1!
IF MM <> 0 THEN
  Q1 = N
  FOR I = 1 TO MM
    ANORM = -.5 * ANORM * (N + I) * (Q1 / I)
    Q1 = Q1 - 1!
  NEXT I
END IF
FOR K = 1 TO M - 1
  X(K) = (K - 1) * H
  FAC1 = 1! - X(K) ^ 2
  FAC2 = FAC1 ^ (-MM / 2!)
  Y(1, K) = PLGNDR(N, MM, X(K)) * FAC2
  DUM = (N + 1 - MM) * PLGNDR(N + 1, MM, X(K))
  DERIV = -(DUM - (N + 1) * X(K) * PLGNDR(N, MM, X(K))) / FAC1
  Y(2, K) = MM * X(K) * Y(1, K) / FAC1 + DERIV * FAC2
  Y(3, K) = N * (N + 1) - MM * (MM + 1)
NEXT K
X(M) = 1!
Y(1, M) = ANORM
Y(3, M) = N * (N + 1) - MM * (MM + 1)
Y(2, M) = (Y(3, M) - C2) * Y(1, M) / (2! * (MM + 1!))
SCALV(1) = ABS(ANORM)
IF Y(2, M) > ABS(ANORM) THEN SCALV(2) = Y(2, M) ELSE SCALV(2) = ABS(ANORM)
IF Y(3, M) > 1! THEN SCALV(3) = Y(3, M) ELSE SCALV(3) = 1!
DO
  PRINT "ENTER C^2 OR 999 TO END"
  INPUT C2
  IF C2 = 999! THEN EXIT DO
  CALL SOLVDE(ITMAX, CONV, SLOWC, SCALV(), INDEXV(), NE, NB, M, Y(), NYJ, NYK, C(), NCI, NCJ, NCK, S())
  PRINT " M = "; MM; "    N = "; N; "    C^2 = ";
  PRINT USING "#.######^^^^"; C2;
  PRINT "     LAMBDA = ";
  PRINT USING "#####.######"; Y(3, 1) + MM * (MM + 1)
LOOP
END

