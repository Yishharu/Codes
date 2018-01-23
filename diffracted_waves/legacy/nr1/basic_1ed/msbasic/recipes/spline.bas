SUB SPLINE (X(), Y(), N, YP1, YPN, Y2())
DIM U(N)
IF YP1 > 9.9E+29 THEN
  Y2(1) = 0!
  U(1) = 0!
ELSE
  Y2(1) = -.5
  U(1) = (3! / (X(2) - X(1))) * ((Y(2) - Y(1)) / (X(2) - X(1)) - YP1)
END IF
FOR I = 2 TO N - 1
  SIG = (X(I) - X(I - 1)) / (X(I + 1) - X(I - 1))
  P = SIG * Y2(I - 1) + 2!
  Y2(I) = (SIG - 1!) / P
  DUM1 = (Y(I + 1) - Y(I)) / (X(I + 1) - X(I))
  DUM2 = (Y(I) - Y(I - 1)) / (X(I) - X(I - 1))
  U(I) = (6! * (DUM1 - DUM2) / (X(I + 1) - X(I - 1)) - SIG * U(I - 1)) / P
NEXT I
IF YPN > 9.9E+29 THEN
  QN = 0!
  UN = 0!
ELSE
  QN = .5
  UN = (3! / (X(N) - X(N - 1))) * (YPN - (Y(N) - Y(N - 1)) / (X(N) - X(N - 1)))
END IF
Y2(N) = (UN - QN * U(N - 1)) / (QN * Y2(N - 1) + 1!)
FOR K = N - 1 TO 1 STEP -1
  Y2(K) = Y2(K) * Y2(K + 1) + U(K)
NEXT K
ERASE U
END SUB

