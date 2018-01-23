DECLARE FUNCTION ZBRENT! (DUM!, X1!, X2!, TOL!)
DECLARE FUNCTION FUNC! (X!)

FUNCTION ZBRENT (DUM, X1, X2, TOL)
ITMAX = 100
EPS = 3E-08
A = X1
B = X2
FA = FUNC(A)
FB = FUNC(B)
IF FB * FA > 0! THEN
  PRINT "Root must be bracketed for ZBRENT."
  EXIT FUNCTION
END IF
FC = FB
FOR ITER = 1 TO ITMAX
  IF FB * FC > 0! THEN
    C = A
    FC = FA
    D = B - A
    E = D
  END IF
  IF ABS(FC) < ABS(FB) THEN
    A = B
    B = C
    C = A
    FA = FB
    FB = FC
    FC = FA
  END IF
  TOL1 = 2! * EPS * ABS(B) + .5 * TOL
  XM = .5 * (C - B)
  IF ABS(XM) <= TOL1 OR FB = 0! THEN
    ZBRENT = B
    EXIT FUNCTION
  END IF
  IF ABS(E) >= TOL1 AND ABS(FA) > ABS(FB) THEN
    S = FB / FA
    IF A = C THEN
      P = 2! * XM * S
      Q = 1! - S
    ELSE
      Q = FA / FC
      R = FB / FC
      P = S * (2! * XM * Q * (Q - R) - (B - A) * (R - 1!))
      Q = (Q - 1!) * (R - 1!) * (S - 1!)
    END IF
    IF P > 0! THEN Q = -Q
    P = ABS(P)
    DUM = 3! * XM * Q - ABS(TOL1 * Q)
    IF DUM > ABS(E * Q) THEN DUM = E * Q
    IF 2! * P < DUM THEN
      E = D
      D = P / Q
    ELSE
      D = XM
      E = D
    END IF
  ELSE
    D = XM
    E = D
  END IF
  A = B
  FA = FB
  IF ABS(D) > TOL1 THEN
    B = B + D
  ELSE
    B = B + ABS(TOL1) * SGN(XM)
  END IF
  FB = FUNC(B)
NEXT ITER
PRINT "ZBRENT exceeding maximum iterations."
ZBRENT = B
END FUNCTION

