DECLARE SUB DIFEQ (K!, K1!, K2!, JSF!, IS1!, ISF!, INDEXV!(), NE!, S!(), NSI!, NSJ!, Y!(), NYJ!, NYK!)
DECLARE SUB PINVS (IE1!, IE2!, JE1!, JSF!, JC1!, K!, C!(), NCI!, NCJ!, NCK!, S!(), NSI!, NSJ!)
DECLARE SUB RED (IZ1!, IZ2!, JZ1!, JZ2!, JM1!, JM2!, JMF!, IC1!, JC1!, JCF!, KC!, C!(), NCI!, NCJ!, NCK!, S!())
DECLARE SUB BKSUB (NE!, NB!, JF!, K1!, K2!, C!(), NCI!, NCJ!, NCK!)

SUB SOLVDE (ITMAX, CONV, SLOWC, SCALV(), INDEXV(), NE, NB, M, Y(), NYJ, NYK, C(), NCI, NCJ, NCK, S())
DIM ERMAX(NE), KMAX(NE)
K1 = 1
K2 = M
NVARS = NE * M
J1 = 1
J2 = NB
J3 = NB + 1
J4 = NE
J5 = J4 + J1
J6 = J4 + J2
J7 = J4 + J3
J8 = J4 + J4
J9 = J8 + J1
IC1 = 1
IC2 = NE - NB
IC3 = IC2 + 1
IC4 = NE
JC1 = 1
JCF = IC3
FOR IT = 1 TO ITMAX
  K = K1
  CALL DIFEQ(K, K1, K2, J9, IC3, IC4, INDEXV(), NE, S(), NSI, NSJ, Y(), NYJ, NYK)
  CALL PINVS(IC3, IC4, J5, J9, JC1, K1, C(), NCI, NCJ, NCK, S(), NSI, NSJ)
  FOR K = K1 + 1 TO K2
    KP = K - 1
    CALL DIFEQ(K, K1, K2, J9, IC1, IC4, INDEXV(), NE, S(), NSI, NSJ, Y(), NYJ, NYK)
    CALL RED(IC1, IC4, J1, J2, J3, J4, J9, IC3, JC1, JCF, KP, C(), NCI, NCJ, NCK, S())
    CALL PINVS(IC1, IC4, J3, J9, JC1, K, C(), NCI, NCJ, NCK, S(), NSI, NSJ)
  NEXT K
  K = K2 + 1
  CALL DIFEQ(K, K1, K2, J9, IC1, IC2, INDEXV(), NE, S(), NSI, NSJ, Y(), NYJ, NYK)
  CALL RED(IC1, IC2, J5, J6, J7, J8, J9, IC3, JC1, JCF, K2, C(), NCI, NCJ, NCK, S())
  CALL PINVS(IC1, IC2, J7, J9, JCF, K2 + 1, C(), NCI, NCJ, NCK, S(), NSI, NSJ)
  CALL BKSUB(NE, NB, JCF, K1, K2, C(), NCI, NCJ, NCK)
  ERQ = 0!
  FOR J = 1 TO NE
    JV = INDEXV(J)
    ERRJ = 0!
    KM = 0
    VMAX = 0!
    FOR K = K1 TO K2
      VZ = ABS(C(J, 1, K))
      IF VZ > VMAX THEN
        VMAX = VZ
        KM = K
      END IF
      ERRJ = ERRJ + VZ
    NEXT K
    IF SCALV(JV) <> 0! THEN
      ERQ = ERQ + ERRJ / SCALV(JV)
      ERMAX(J) = C(J, 1, KM) / SCALV(JV)
    END IF
    KMAX(J) = KM
  NEXT J
  ERQ = ERQ / NVARS
  IF ERQ > SLOWC THEN DUM = ERQ ELSE DUM = SLOWC
  FAC = SLOWC / DUM
  FOR JV = 1 TO NE
    J = INDEXV(JV)
    FOR K = K1 TO K2
      Y(J, K) = Y(J, K) - FAC * C(JV, 1, K)
    NEXT K
  NEXT JV
  PRINT USING "####"; IT;
  PRINT USING "#####.######"; ERQ; FAC
  FOR J = 1 TO NE
    PRINT USING "#########"; KMAX(J);
    PRINT USING "#####.######"; ERMAX(J)
    PRINT
  NEXT J
  IF ERQ < CONV THEN ERASE KMAX, ERMAX: EXIT FOR
NEXT IT
PRINT "ITMAX exceeded"
END SUB

