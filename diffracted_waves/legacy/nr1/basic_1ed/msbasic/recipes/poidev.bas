DECLARE FUNCTION POIDEV! (XM!, IDUM&)
DECLARE FUNCTION GAMMLN! (X!)
DECLARE FUNCTION RAN1! (IDUM&)

FUNCTION POIDEV (XM, IDUM&) STATIC
PI = 3.141592654#
IF XM < 12! THEN
  IF XM <> OLDM THEN
    OLDM = XM
    G = EXP(-XM)
  END IF
  EM = -1
  T = 1!
  DO
    EM = EM + 1!
    T = T * RAN1(IDUM&)
  LOOP WHILE T > G
ELSE
  IF XM <> OLDM THEN
    OLDM = XM
    SQ = SQR(2! * XM)
    ALXM = LOG(XM)
    G = XM * ALXM - GAMMLN(XM + 1!)
  END IF
  DO
    DO
      Y = TAN(PI * RAN1(IDUM&))
      EM = SQ * Y + XM
    LOOP WHILE EM < 0!
    EM = INT(EM)
    DUM = EM * ALXM - GAMMLN(EM + 1!) - G
    T = .9 * (1! + Y ^ 2) * EXP(DUM)
  LOOP WHILE RAN1(IDUM&) > T
END IF
POIDEV = EM
END FUNCTION

