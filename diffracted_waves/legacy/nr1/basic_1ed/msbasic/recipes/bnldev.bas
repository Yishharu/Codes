DECLARE FUNCTION BNLDEV! (PP!, N!, IDUM&)
DECLARE FUNCTION GAMMLN! (X!)
DECLARE FUNCTION RAN1! (IDUM&)

FUNCTION BNLDEV (PP, N, IDUM&) STATIC
PI = 3.141592654#
IF PP <= .5 THEN
  P = PP
ELSE
  P = 1! - PP
END IF
AM = N * P
IF N < 25 THEN
  BNL = 0!
  FOR J = 1 TO N
    IF RAN1(IDUM&) < P THEN BNL = BNL + 1!
  NEXT J
ELSEIF AM < 1! THEN
  G = EXP(-AM)
  T = 1!
  FOR J = 0 TO N
    T = T * RAN1(IDUM&)
    IF T < G THEN EXIT FOR
  NEXT J
  IF T >= G THEN J = N
  BNL = J
ELSE
  IF N <> NOLD THEN
    EN = N
    OLDG = GAMMLN(EN + 1!)
    NOLD = N
  END IF
  IF P <> POLD THEN
    PC = 1! - P
    PLOG = LOG(P)
    PCLOG = LOG(PC)
    POLD = P
  END IF
  SQ = SQR(2! * AM * PC)
  DO
    DO
      Y = TAN(PI * RAN1(IDUM&))
      EM = SQ * Y + AM
    LOOP WHILE EM < 0! OR EM >= EN + 1!
    EM = INT(EM)
    T = EN - EM
    T = EXP(OLDG - GAMMLN(EM + 1!) - GAMMLN(T + 1!) + EM * PLOG + T * PCLOG)
    T = 1.2 * SQ * (1! + Y ^ 2) * T
  LOOP WHILE RAN1(IDUM&) > T
  BNL = EM
END IF
IF P <> PP THEN BNL = N - BNL
BNLDEV = BNL
END FUNCTION

