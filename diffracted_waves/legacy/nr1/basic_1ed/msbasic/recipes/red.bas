SUB RED (IZ1, IZ2, JZ1, JZ2, JM1, JM2, JMF, IC1, JC1, JCF, KC, C(), NCI, NCJ, NCK, S())
LOFF = JC1 - JM1
IC = IC1
FOR J = JZ1 TO JZ2
  FOR L = JM1 TO JM2
    VX = C(IC, L + LOFF, KC)
    FOR I = IZ1 TO IZ2
      S(I, L) = S(I, L) - S(I, J) * VX
    NEXT I
  NEXT L
  VX = C(IC, JCF, KC)
  FOR I = IZ1 TO IZ2
    S(I, JMF) = S(I, JMF) - S(I, J) * VX
  NEXT I
  IC = IC + 1
NEXT J
END SUB

