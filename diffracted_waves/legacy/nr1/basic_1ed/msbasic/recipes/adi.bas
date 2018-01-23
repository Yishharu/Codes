DECLARE SUB TRIDAG (A#(), B#(), C#(), R#(), U#(), N!)

SUB ADI (A#(), B#(), C#(), D#(), E#(), F#(), G#(), U#(), JMAX!, K!, ALPHA#, BETA#, EPS#)
DEFDBL A-H, O-Z
JJ = 50
KK = 6
NRR = 32
MAXITS = 100
ZERO = 0#
TWO = 2#
HALF = .5#
DIM AA(JJ), BB(JJ), CC(JJ), RR(JJ), UU(JJ), PSI(JJ, JJ)
DIM ALPH(KK), BET(KK), R(NRR), S(NRR, KK)
IF JMAX > JJ THEN PRINT "Increase JJ": EXIT SUB
IF K > KK - 1 THEN PRINT "Increase KK": EXIT SUB
K1 = K + 1
NR = 2 ^ K
ALPH(1) = ALPHA
BET(1) = BETA
FOR J = 1 TO K
  ALPH(J + 1) = SQR(ALPH(J) * BET(J))
  BET(J + 1) = HALF * (ALPH(J) + BET(J))
NEXT J
S(1, 1) = SQR(ALPH(K1) * BET(K1))
FOR J = 1 TO K
  AB = ALPH(K1 - J) * BET(K1 - J)
  FOR N = 1 TO 2 ^ (J - 1)
    DISC = SQR(S(N, J) ^ 2 - AB)
    S(2 * N, J + 1) = S(N, J) + DISC
    S(2 * N - 1, J + 1) = AB / S(2 * N, J + 1)
  NEXT N
NEXT J
FOR N = 1 TO NR
  R(N) = S(N, K1)
NEXT N
ANORMG = ZERO
FOR J = 2 TO JMAX - 1
  FOR L = 2 TO JMAX - 1
    ANORMG = ANORMG + ABS(G(J, L))
    DUM = -D(J, L) * U(J, L - 1)
    PSI(J, L) = DUM + (R(1) - E(J, L)) * U(J, L) - F(J, L) * U(J, L + 1)
  NEXT L
NEXT J
NITS = MAXITS / NR
FOR KITS = 1 TO NITS
  FOR N = 1 TO NR
    IF N = NR THEN
      NEXQ = 1
    ELSE
      NEXQ = N + 1
    END IF
    RFACT = R(N) + R(NEXQ)
    FOR L = 2 TO JMAX - 1
      FOR J = 2 TO JMAX - 1
        AA(J - 1) = A(J, L)
        BB(J - 1) = B(J, L) + R(N)
        CC(J - 1) = C(J, L)
        RR(J - 1) = PSI(J, L) - G(J, L)
      NEXT J
      CALL TRIDAG(AA(), BB(), CC(), RR(), UU(), JMAX - 2)
      FOR J = 2 TO JMAX - 1
        PSI(J, L) = -PSI(J, L) + TWO * R(N) * UU(J - 1)
      NEXT J
    NEXT L
    FOR J = 2 TO JMAX - 1
      FOR L = 2 TO JMAX - 1
        AA(L - 1) = D(J, L)
        BB(L - 1) = E(J, L) + R(N)
        CC(L - 1) = F(J, L)
        RR(L - 1) = PSI(J, L)
      NEXT L
      CALL TRIDAG(AA(), BB(), CC(), RR(), UU(), JMAX - 2)
      FOR L = 2 TO JMAX - 1
        U(J, L) = UU(L - 1)
        PSI(J, L) = -PSI(J, L) + RFACT * UU(L - 1)
      NEXT L
    NEXT J
  NEXT N
  ANORM = ZERO
  FOR J = 2 TO JMAX - 1
    FOR L = 2 TO JMAX - 1
      RESID = A(J, L) * U(J - 1, L) + (B(J, L) + E(J, L)) * U(J, L)
      RESID = RESID + C(J, L) * U(J + 1, L) + D(J, L) * U(J, L - 1)
      RESID = RESID + F(J, L) * U(J, L + 1) + G(J, L)
      ANORM = ANORM + ABS(RESID)
    NEXT L
  NEXT J
  IF ANORM < EPS * ANORMG THEN
    ERASE S, R, BET, ALPH, PSI, UU, RR, CC, BB, AA
    EXIT SUB
  END IF
NEXT KITS
PRINT "MAXITS exceeded"
END SUB

