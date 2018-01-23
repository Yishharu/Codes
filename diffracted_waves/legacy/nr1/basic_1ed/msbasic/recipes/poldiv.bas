SUB POLDIV (U(), N, V(), NV, Q(), R())
FOR J = 1 TO N
  R(J) = U(J)
  Q(J) = 0!
NEXT J
FOR K = N - NV TO 0 STEP -1
  Q(K + 1) = R(NV + K) / V(NV)
  FOR J = NV + K - 1 TO K + 1 STEP -1
    R(J) = R(J) - Q(K + 1) * V(J - K)
  NEXT J
NEXT K
FOR J = NV TO N
  R(J) = 0!
NEXT J
END SUB

