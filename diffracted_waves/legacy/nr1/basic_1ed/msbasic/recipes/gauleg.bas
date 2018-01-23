SUB GAULEG (X1, X2, X(), W(), N)
EPS = .00000000000003#
M = INT((N + 1) / 2)
XM = .5# * (X2 + X1)
XL = .5# * (X2 - X1)
FOR I = 1 TO M
  Z = COS(3.141592654# * (I - .25#) / (N + .5#))
  DO
    P1 = 1#
    P2 = 0#
    FOR J = 1 TO N
      P3 = P2
      P2 = P1
      P1 = ((2# * J - 1#) * Z * P2 - (J - 1#) * P3) / J
    NEXT J
    PP = N * (Z * P1 - P2) / (Z * Z - 1#)
    Z1 = Z
    Z = Z1 - P1 / PP
  LOOP WHILE ABS(Z - Z1) > EPS
  X(I) = XM - XL * Z
  X(N + 1 - I) = XM + XL * Z
  W(I) = 2# * XL / ((1# - Z * Z) * PP * PP)
  W(N + 1 - I) = W(I)
NEXT I
END SUB

