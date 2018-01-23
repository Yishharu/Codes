DECLARE SUB TRNCST (X!(), Y!(), IORDER!(), NCITY!, N!(), DE!)
DECLARE SUB METROP (DE!, T!, ANS%)
DECLARE SUB TRNSPT (IORDER!(), NCITY!, N!())
DECLARE SUB REVCST (X!(), Y!(), IORDER!(), NCITY!, N!(), DE!)
DECLARE SUB REVERS (IORDER!(), NCITY!, N!())
DECLARE FUNCTION ALEN! (X1!, X2!, Y1!, Y2!)
DECLARE FUNCTION RAN3! (IDUM&)
DECLARE FUNCTION IRBIT1! (ISEED!)

FUNCTION ALEN (X1, X2, Y1, Y2)
ALEN = SQR((X2 - X1) ^ 2 + (Y2 - Y1) ^ 2)
END FUNCTION

SUB ANNEAL (X(), Y(), IORDER(), NCITY)
DIM N(6)
NOVER = 100 * NCITY
NLIMIT = 10 * NCITY
TFACTR = .9
PATH = 0!
T = .5
FOR I = 1 TO NCITY - 1
  I1 = IORDER(I)
  I2 = IORDER(I + 1)
  PATH = PATH + ALEN(X(I1), X(I2), Y(I1), Y(I2))
NEXT I
I1 = IORDER(NCITY)
I2 = IORDER(1)
PATH = PATH + ALEN(X(I1), X(I2), Y(I1), Y(I2))
IDUM& = -1
ISEED = 111
FOR J = 1 TO 100
  NSUCC = 0
  FOR K = 1 TO NOVER
    DO
      N(1) = 1 + INT(NCITY * RAN3(IDUM&))
      N(2) = 1 + INT((NCITY - 1) * RAN3(IDUM&))
      IF N(2) >= N(1) THEN N(2) = N(2) + 1
      IDEC = IRBIT1(ISEED)
      NN = 1 + (N(1) - N(2) + NCITY - 1) MOD NCITY
    LOOP WHILE NN < 3
    IF IDEC = 0 THEN
      N(3) = N(2) + INT(ABS(NN - 2) * RAN3(IDUM&)) + 1
      N(3) = 1 + N(3) - 1 - NCITY * INT((N(3) - 1) / NCITY)
      CALL TRNCST(X(), Y(), IORDER(), NCITY, N(), DE)
      CALL METROP(DE, T, ANS%)
      IF ANS% THEN
        NSUCC = NSUCC + 1
        PATH = PATH + DE
        CALL TRNSPT(IORDER(), NCITY, N())
      END IF
    ELSE
      CALL REVCST(X(), Y(), IORDER(), NCITY, N(), DE)
      CALL METROP(DE, T, ANS%)
      IF ANS% THEN
        NSUCC = NSUCC + 1
        PATH = PATH + DE
        CALL REVERS(IORDER(), NCITY, N())
      END IF
    END IF
    IF NSUCC >= NLIMIT THEN EXIT FOR
  NEXT K
  PRINT
  PRINT "T =";
  PRINT USING "####.######"; T;
  PRINT "   Path Length =";
  PRINT USING "####.######"; PATH
  PRINT "Successful Moves: "; NSUCC
  T = T * TFACTR
  IF NSUCC = 0 THEN EXIT FOR
NEXT J
ERASE N
END SUB

