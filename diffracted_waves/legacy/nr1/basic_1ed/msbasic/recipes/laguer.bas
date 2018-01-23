DECLARE FUNCTION CABS! (A1!, A2!)
DECLARE FUNCTION CDIV1! (A1!, A2!, B1!, B2!)
DECLARE FUNCTION CDIV2! (A1!, A2!, B1!, B2!)
DECLARE FUNCTION CSQR1! (X!, Y!)
DECLARE FUNCTION CSQR2! (X!, Y!)

FUNCTION CABS (A1, A2)
X = ABS(A1)
Y = ABS(A2)
IF X = 0! THEN
  CABS = Y
ELSEIF Y = 0! THEN
  CABS = X
ELSEIF X > Y THEN
  CABS = X * SQR(1! + SQR(Y / X))
ELSE
  CABS = Y * SQR(1! + SQR(X / Y))
END IF
END FUNCTION

FUNCTION CDIV1 (A1, A2, B1, B2)
IF ABS(B1) >= ABS(B2) THEN
  R = B2 / B1
  DEN = B1 + R * B2
  CDIV1 = (A1 + A2 * R) / DEN
ELSE
  R = B1 / B2
  DEN = B2 + R * B1
  CDIV1 = (A1 * R + A2) / DEN
END IF
END FUNCTION

FUNCTION CDIV2 (A1, A2, B1, B2)
IF ABS(B1) >= ABS(B2) THEN
  R = B2 / B1
  DEN = B1 + R * B2
  CDIV2 = (A2 - A1 * R) / DEN
ELSE
  R = B1 / B2
  DEN = B2 + R * B1
  CDIV2 = (A2 * R - A1) / DEN
END IF
END FUNCTION

FUNCTION CSQR1 (X, Y)
IF X = 0! AND Y = 0! THEN
  U = 0!
ELSE
  IF ABS(X) >= ABS(Y) THEN
    W = SQR(ABS(X)) * SQR(.5 * (1! + SQR(1! + SQR(ABS(Y / X)))))
  ELSE
    R = ABS(X / Y)
    W = SQR(ABS(Y)) * SQR(.5 * (R + SQR(1! + SQR(R))))
  END IF
  IF X >= 0! THEN
    U = W
    V = Y / (2! * U)
  ELSE
    IF Y >= 0! THEN V = W ELSE V = -W
    U = Y / (2! * V)
  END IF
END IF
CSQR1 = U
END FUNCTION

FUNCTION CSQR2 (X, Y)
IF X = 0! AND Y = 0! THEN
  V = 0!
ELSE
  IF ABS(X) >= ABS(Y) THEN
    W = SQR(ABS(X)) * SQR(.5 * (1! + SQR(1! + SQR(ABS(Y / X)))))
  ELSE
    R = ABS(X / Y)
    W = SQR(ABS(Y)) * SQR(.5 * (R + SQR(1! + SQR(R))))
  END IF
  IF X >= 0! THEN
    U = W
    V = Y / (2! * U)
  ELSE
    IF Y >= 0! THEN V = W ELSE V = -W
    U = Y / (2! * V)
  END IF
END IF
CSQR2 = V
END FUNCTION

SUB LAGUER (A(), M, X(), EPS, POLISH%)
DIM ZERO(2), B(2), D(2), F(2), G(2), H(2)
DIM G2(2), SQ(2), GP(2), GM(2), DX(2), X1(2)
ZERO(1) = 0!
ZERO(2) = 0!
EPSS = 6E-08
MAXIT = 100
DXOLD = CABS(X(1), X(2))
FOR ITER = 1 TO MAXIT
  B(1) = A(1, M + 1)
  B(2) = A(2, M + 1)
  ERQ = CABS(B(1), B(2))
  D(1) = ZERO(1)
  D(2) = ZERO(2)
  F(1) = ZERO(1)
  F(2) = ZERO(2)
  ABX = CABS(X(1), X(2))
  FOR J = M TO 1 STEP -1
    DUM = X(1) * F(1) - X(2) * F(2) + D(1)
    F(2) = X(2) * F(1) + X(1) * F(2) + D(2)
    F(1) = DUM
    DUM = X(1) * D(1) - X(2) * D(2) + B(1)
    D(2) = X(2) * D(1) + X(1) * D(2) + B(2)
    D(1) = DUM
    DUM = X(1) * B(1) - X(2) * B(2) + A(1, J)
    B(2) = X(2) * B(1) + X(1) * B(2) + A(2, J)
    B(1) = DUM
    ERQ = CABS(B(1), B(2)) + ABX * ERQ
  NEXT J
  ERQ = EPSS * ERQ
  IF CABS(B(1), B(2)) <= ERQ THEN
    ERASE X1, DX, GM, GP, SQ, G2, H, G, F, D, B, ZERO
    EXIT SUB
  ELSE
    G(1) = CDIV1(D(1), D(2), B(1), B(2))
    G(2) = CDIV2(D(1), D(2), B(1), B(2))
    G2(1) = G(1) * G(1) - G(2) * G(2)
    G2(2) = 2! * G(1) * G(2)
    H(1) = G2(1) - 2! * CDIV1(F(1), F(2), B(1), B(2))
    H(2) = G2(2) - 2! * CDIV2(F(1), F(2), B(1), B(2))
    DUM1 = (M - 1) * (M * H(1) - G2(1))
    DUM2 = (M - 1) * (M * H(2) - G2(2))
    SQ(1) = CSQR1(DUM1, DUM2)
    SQ(2) = CSQR2(DUM1, DUM2)
    GP(1) = G(1) + SQ(1)
    GP(2) = G(2) + SQ(2)
    GM(1) = G(1) - SQ(1)
    GM(2) = G(2) - SQ(2)
    IF CABS(GP(1), GP(2)) < CABS(GM(1), GM(2)) THEN
      GP(1) = GM(1)
      GP(2) = GM(2)
    END IF
    DX(1) = CDIV1(M, 0, GP(1), GP(2))
    DX(2) = CDIV2(M, 0, GP(1), GP(2))
  END IF
  X1(1) = X(1) - DX(1)
  X1(2) = X(2) - DX(2)
  IF X(1) = X1(1) AND X(2) = X1(2) THEN
    ERASE X1, DX, GM, GP, SQ, G2, H, G, F, D, B, ZERO
    EXIT SUB
  END IF
  X(1) = X1(1)
  X(2) = X1(2)
  CDX = CABS(DX(1), DX(2))
  DXOLD = CDX
  IF NOT POLISH% THEN
    IF CDX <= EPS * CABS(X(1), X(2)) THEN
      ERASE X1, DX, GM, GP, SQ, G2, H, G, F, D, B, ZERO
      EXIT SUB
    END IF
  END IF
NEXT ITER
PRINT "too many iterations"
END SUB

