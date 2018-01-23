SUB DDPOLY (C(), NC, X, PD(), ND)
PD(1) = C(NC)
FOR J = 2 TO ND
  PD(J) = 0!
NEXT J
FOR I = NC - 1 TO 1 STEP -1
  IF NC + 1 - I < ND THEN NND = NC + 1 - I ELSE NND = ND
  FOR J = NND TO 2 STEP -1
    PD(J) = PD(J) * X + PD(J - 1)
  NEXT J
  PD(1) = PD(1) * X + C(I)
NEXT I
CONSQ = 2!
FOR I = 3 TO ND
  PD(I) = CONSQ * PD(I)
  CONSQ = CONSQ * I
NEXT I
END SUB

