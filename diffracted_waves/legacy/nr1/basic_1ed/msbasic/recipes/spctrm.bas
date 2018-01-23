DECLARE FUNCTION WINDOQ! (J!, FACM!, FACP!)
DECLARE SUB FOUR1 (DATQ!(), NN!, ISIGN!)

SUB SPCTRM (P(), M, K, OVRLAP%, W1(), W2()) STATIC
MM = M + M
M4 = MM + MM
M44 = M4 + 4
M43 = M4 + 3
DEN = 0!
FACM = M - .5
FACP = 1! / (M + .5)
SUMW = 0!
FOR J = 1 TO MM
  SUMW = SUMW + WINDOQ(J, FACM, FACP) ^ 2
NEXT J
FOR J = 1 TO M
  P(J) = 0!
NEXT J
IF OVRLAP% THEN
  FOR J = 1 TO M
    W2(J) = VAL(INPUT$(12, #1))
    IF J MOD 4 = 0 THEN DUM$ = INPUT$(2, #1)
  NEXT J
END IF
JN& = 0
FOR KK = 1 TO K
  FOR JOFF = -1 TO 0
    IF OVRLAP% THEN
      FOR J = 1 TO M
        W1(JOFF + J + J) = W2(J)
      NEXT J
      FOR J = 1 TO M
        W2(J) = VAL(INPUT$(12, #1))
        IF J MOD 4 = 0 THEN DUM$ = INPUT$(2, #1)
      NEXT J
      JOFFN = JOFF + MM
      FOR J = 1 TO M
        W1(JOFFN + J + J) = W2(J)
      NEXT J
    ELSE
      FOR J = JOFF + 2 TO M4 STEP 2
        W1(J) = VAL(INPUT$(12, #1))
        JN& = JN& + 1
        IF JN& MOD 4 = 0 THEN DUM$ = INPUT$(2, #1)
      NEXT J
    END IF
  NEXT JOFF
  FOR J = 1 TO MM
    J2 = J + J
    W = WINDOQ(J, FACM, FACP)
    W1(J2) = W1(J2) * W
    W1(J2 - 1) = W1(J2 - 1) * W
  NEXT J
  CALL FOUR1(W1(), MM, 1)
  P(1) = P(1) + W1(1) ^ 2 + W1(2) ^ 2
  FOR J = 2 TO M
    J2 = J + J
    P(J) = P(J) + W1(J2) ^ 2 + W1(J2 - 1) ^ 2 + W1(M44 - J2) ^ 2
    P(J) = P(J) + W1(M43 - J2) ^ 2
  NEXT J
  DEN = DEN + SUMW
NEXT KK
DEN = M4 * DEN
FOR J = 1 TO M
  P(J) = P(J) / DEN
NEXT J
END SUB

FUNCTION WINDOQ (J, FACM, FACP)
WINDOQ = 1! - ABS(((J - 1) - FACM) * FACP)
'WINDOQ = 1!
'WINDOQ = 1! - (((J - 1) * FACM) * FACP) ^ 2
END FUNCTION

