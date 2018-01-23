SUB TOEPLZ (R(), X(), Y(), N)
DIM G(N), H(N)
IF R(N) <> 0! THEN
  X(1) = Y(1) / R(N)
  IF N = 1 THEN ERASE H, G: EXIT SUB
  G(1) = R(N - 1) / R(N)
  H(1) = R(N + 1) / R(N)
  FOR M = 1 TO N
    M1 = M + 1
    SXN = -Y(M1)
    SD = -R(N)
    FOR J = 1 TO M
      SXN = SXN + R(N + M1 - J) * X(J)
      SD = SD + R(N + M1 - J) * G(M - J + 1)
    NEXT J
    IF SD = 0! THEN
      PRINT "Levinson method fails:  singular principal minor"
      EXIT SUB
    END IF
    X(M1) = SXN / SD
    FOR J = 1 TO M
      X(J) = X(J) - X(M1) * G(M - J + 1)
    NEXT J
    IF M1 = N THEN ERASE H, G: EXIT SUB
    SGQ = -R(N - M1)
    SHN = -R(N + M1)
    SGD = -R(N)
    FOR J = 1 TO M
      SGQ = SGQ + R(N + J - M1) * G(J)
      SHN = SHN + R(N + M1 - J) * H(J)
      SGD = SGD + R(N + J - M1) * H(M - J + 1)
    NEXT J
    IF SD = 0! OR SGD = 0! THEN
      PRINT "Levinson method fails:  singular principal minor"
      EXIT SUB
    END IF
    G(M1) = SGQ / SGD
    H(M1) = SHN / SD
    K = M
    M2 = INT((M + 1) / 2)
    PP = G(M1)
    QQ = H(M1)
    FOR J = 1 TO M2
      PT1 = G(J)
      PT2 = G(K)
      QT1 = H(J)
      QT2 = H(K)
      G(J) = PT1 - PP * QT2
      G(K) = PT2 - PP * QT1
      H(J) = QT1 - QQ * PT2
      H(K) = QT2 - QQ * PT1
      K = K - 1
    NEXT J
  NEXT M
  PRINT "never get here"
  EXIT SUB
END IF
PRINT "Levinson method fails:  singular principal minor"
END SUB

