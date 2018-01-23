SUB SPLINT (XA(), YA(), Y2A(), N, X, Y)
KLO = 1
KHI = N
WHILE KHI - KLO > 1
  K = (KHI + KLO) / 2
  IF XA(K) > X THEN
    KHI = K
  ELSE
    KLO = K
  END IF
WEND
H = XA(KHI) - XA(KLO)
IF H = 0! THEN PRINT "Bad XA input.": EXIT SUB
A = (XA(KHI) - X) / H
B = (X - XA(KLO)) / H
Y = A * YA(KLO) + B * YA(KHI)
Y = Y + ((A ^ 3 - A) * Y2A(KLO) + (B ^ 3 - B) * Y2A(KHI)) * (H ^ 2) / 6!
END SUB

