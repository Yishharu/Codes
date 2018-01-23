
SUB CRANK (N, W(), S)
S = 0!
J = 1
WHILE J < N
  IF W(J + 1) <> W(J) THEN
    W(J) = J
    J = J + 1
  ELSE
    FOR JT = J + 1 TO N
      IF W(JT) <> W(J) THEN GOTO 2
    NEXT JT
    JT = N + 1
2   RANK = .5 * (J + JT - 1)
    FOR JI = J TO JT - 1
      W(JI) = RANK
    NEXT JI
    T = JT - J
    S = S + T ^ 3 - T
    J = JT
  END IF
WEND
IF J = N THEN W(N) = N
END SUB

