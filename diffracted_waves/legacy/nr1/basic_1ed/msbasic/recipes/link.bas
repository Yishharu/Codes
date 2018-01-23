DECLARE FUNCTION ALEN! (X1!, X2!, X3!, X4!)
DECLARE FUNCTION RAN3! (IDUM&)

SUB METROP (DE, T, ANS%)
JDUM& = 1
ANS% = (DE < 0!) OR (RAN3(JDUM&) < EXP(-DE / T))
END SUB

SUB REVCST (X(), Y(), IORDER(), NCITY, N(), DE)
DIM XX(4), YY(4)
N(3) = 1 + N(1) + NCITY - 2 - NCITY * INT((N(1) + NCITY - 2) / NCITY)
N(4) = 1 + N(2) - NCITY * INT(N(2) / NCITY)
FOR J = 1 TO 4
  II = IORDER(N(J))
  XX(J) = X(II)
  YY(J) = Y(II)
NEXT J
DE = -ALEN(XX(1), XX(3), YY(1), YY(3))
DE = DE - ALEN(XX(2), XX(4), YY(2), YY(4))
DE = DE + ALEN(XX(1), XX(4), YY(1), YY(4))
DE = DE + ALEN(XX(2), XX(3), YY(2), YY(3))
ERASE YY, XX
END SUB

SUB REVERS (IORDER(), NCITY, N())
NN = (1 + (N(2) - N(1) + NCITY) MOD NCITY) / 2
FOR J = 1 TO NN
  K = 1 + N(1) + J - 2 - NCITY * INT((N(1) + J - 2) / NCITY)
  L = 1 + (N(2) - J + NCITY) MOD NCITY
  ITMP = IORDER(K)
  IORDER(K) = IORDER(L)
  IORDER(L) = ITMP
NEXT J
END SUB

SUB TRNCST (X(), Y(), IORDER(), NCITY, N(), DE)
DIM XX(6), YY(6)
N(4) = 1 + N(3) - NCITY * INT(N(3) / NCITY)
N(5) = 1 + N(1) + NCITY - 2 - NCITY * INT((N(1) + NCITY - 2) / NCITY)
N(6) = 1 + N(2) - NCITY * INT(N(2) / NCITY)
FOR J = 1 TO 6
  II = IORDER(N(J))
  XX(J) = X(II)
  YY(J) = Y(II)
NEXT J
DE = -ALEN(XX(2), XX(6), YY(2), YY(6))
DE = DE - ALEN(XX(1), XX(5), YY(1), YY(5))
DE = DE - ALEN(XX(3), XX(4), YY(3), YY(4))
DE = DE + ALEN(XX(1), XX(3), YY(1), YY(3))
DE = DE + ALEN(XX(2), XX(4), YY(2), YY(4))
DE = DE + ALEN(XX(5), XX(6), YY(5), YY(6))
ERASE YY, XX
END SUB

SUB TRNSPT (IORDER(), NCITY, N())
DIM JORDER(NCITY)
M1 = 1 + N(2) - N(1) + NCITY - NCITY * INT((N(2) - N(1) + NCITY) / NCITY)
M2 = 1 + N(5) - N(4) + NCITY - NCITY * INT((N(5) - N(4) + NCITY) / NCITY)
M3 = 1 + N(3) - N(6) + NCITY - NCITY * INT((N(3) - N(6) + NCITY) / NCITY)
NN = 1
FOR J = 1 TO M1
  JJ = 1 + J + N(1) - 2 - NCITY * INT((J + N(1) - 2) / NCITY)
  JORDER(NN) = IORDER(JJ)
  NN = NN + 1
NEXT J
IF M2 > 0 THEN
  FOR J = 1 TO M2
    JJ = 1 + J + N(4) - 2 - NCITY * INT((J + N(4) - 2) / NCITY)
    JORDER(NN) = IORDER(JJ)
    NN = NN + 1
  NEXT J
END IF
IF M3 > 0 THEN
  FOR J = 1 TO M3
    JJ = 1 + J + N(6) - 2 - NCITY * INT((J + N(6) - 2) / NCITY)
    JORDER(NN) = IORDER(JJ)
    NN = NN + 1
  NEXT J
END IF
FOR J = 1 TO NCITY
  IORDER(J) = JORDER(J)
NEXT J
ERASE JORDER
END SUB

