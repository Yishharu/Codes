DECLARE SUB POLINT (XA!(), YA!(), N!, X!, Y!, DY!)

SUB POLCOF (XA(), YA(), N, COF())
DIM X(N), Y(N)
FOR J = 1 TO N
  X(J) = XA(J)
  Y(J) = YA(J)
NEXT J
FOR J = 1 TO N
  CALL POLINT(X(), Y(), N + 1 - J, 0!, COF(J), DY)
  XMIN = 1E+38
  K = 0
  FOR I = 1 TO N + 1 - J
    IF ABS(X(I)) < XMIN THEN
      XMIN = ABS(X(I))
      K = I
    END IF
    IF X(I) <> 0! THEN Y(I) = (Y(I) - COF(J)) / X(I)
  NEXT I
  FOR I = K + 1 TO N + 1 - J
    Y(I - 1) = Y(I)
    X(I - 1) = X(I)
  NEXT I
NEXT J
ERASE Y, X
END SUB

