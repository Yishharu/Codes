DECLARE SUB SORT (N!, RA!())

SUB MDIAN1 (X(), N, XMED)
CALL SORT(N, X())
N2 = INT(N / 2)
IF 2 * N2 = N THEN
  XMED = .5 * (X(N2) + X(N2 + 1))
ELSE
  XMED = X(N2 + 1)
END IF
END SUB

