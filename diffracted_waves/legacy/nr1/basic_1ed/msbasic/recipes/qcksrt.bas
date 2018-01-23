SUB QCKSRT (N, ARR())
M = 7
NSTACK = 50
FM = 7875!
FA = 211!
FC = 1663!
FMI = .00012698413#
DIM ISTACK(NSTACK)
JSTACK = 0
L = 1
IR = N
FX = 0!
DO
  IF IR - L < M THEN
    FOR J = L + 1 TO IR
      A = ARR(J)
      FOR I = J - 1 TO 1 STEP -1
        IF ARR(I) <= A THEN EXIT FOR
        ARR(I + 1) = ARR(I)
      NEXT I
      IF ARR(I) > A THEN I = 0
      ARR(I + 1) = A
    NEXT J
    IF JSTACK = 0 THEN ERASE ISTACK: EXIT SUB
    IR = ISTACK(JSTACK)
    L = ISTACK(JSTACK - 1)
    JSTACK = JSTACK - 2
  ELSE
    I = L
    J = IR
    FX = FX * FA + FC - FM * INT((FX * FA + FC) / FM)
    IQ = L + (IR - L + 1) * (FX * FMI)
    A = ARR(IQ)
    ARR(IQ) = ARR(L)
    DO
      DO
        IF J > 0 THEN
          IF A < ARR(J) THEN
            J = J - 1
            DONE% = 0
          ELSE
            DONE% = -1
          END IF
        END IF
      LOOP WHILE NOT DONE%
      IF J <= I THEN
        ARR(I) = A
        EXIT DO
      END IF
      ARR(I) = ARR(J)
      I = I + 1
      DO
        IF I <= N THEN
          IF A > ARR(I) THEN
            I = I + 1
            DONE% = 0
          ELSE
            DONE% = -1
          END IF
        END IF
      LOOP WHILE NOT DONE%
      IF J <= I THEN
        ARR(J) = A
        I = J
        EXIT DO
      END IF
      ARR(J) = ARR(I)
      J = J - 1
    LOOP
    JSTACK = JSTACK + 2
    IF JSTACK > NSTACK THEN PRINT "NSTACK must be made larger.": EXIT SUB
    IF IR - I >= I - L THEN
      ISTACK(JSTACK) = IR
      ISTACK(JSTACK - 1) = I + 1
      IR = I - 1
    ELSE
      ISTACK(JSTACK) = I - 1
      ISTACK(JSTACK - 1) = L
      L = I + 1
    END IF
  END IF
LOOP
END SUB

