DECLARE SUB TRAPZD (DUM!, A!, B!, S!, N!)

SUB QSIMP (DUM, A, B, S)
EPS = .000001
JMAX = 20
OST = -1E+30
OS = -1E+30
FOR J = 1 TO JMAX
  CALL TRAPZD(DUM, A, B, ST, J)
  S = (4! * ST - OST) / 3!
  IF ABS(S - OS) < EPS * ABS(OS) THEN EXIT SUB
  OS = S
  OST = ST
NEXT J
PRINT "Too many steps."
END SUB

