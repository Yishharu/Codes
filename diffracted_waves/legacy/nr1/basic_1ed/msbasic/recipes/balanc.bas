SUB BALANC (A(), N, NP)
RADIX = 2!
SQRDX = 4!
DO
  LAST = 1
  FOR I = 1 TO N
    C = 0!
    R = 0!
    FOR J = 1 TO N
      IF J <> I THEN
        C = C + ABS(A(J, I))
        R = R + ABS(A(I, J))
      END IF
    NEXT J
    IF C <> 0! AND R <> 0! THEN
      G = R / RADIX
      F = 1!
      S = C + R
      WHILE C < G
        F = F * RADIX
        C = C * SQRDX
      WEND
      G = R * RADIX
      WHILE C > G
        F = F / RADIX
        C = C / SQRDX
      WEND
      IF (C + R) / F < .95 * S THEN
        LAST = 0
        G = 1! / F
        FOR J = 1 TO N
          A(I, J) = A(I, J) * G
        NEXT J
        FOR J = 1 TO N
          A(J, I) = A(J, I) * F
        NEXT J
      END IF
    END IF
  NEXT I
LOOP WHILE LAST = 0
END SUB

