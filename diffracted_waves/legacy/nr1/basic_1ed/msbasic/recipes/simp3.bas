SUB SIMP3 (A(), MP, NP, I1, K1, IP, KP)
PIV = 1! / A(IP + 1, KP + 1)
FOR II = 1 TO I1 + 1
  IF II - 1 <> IP THEN
    A(II, KP + 1) = A(II, KP + 1) * PIV
    FOR KK = 1 TO K1 + 1
      IF KK - 1 <> KP THEN
        A(II, KK) = A(II, KK) - A(IP + 1, KK) * A(II, KP + 1)
      END IF
    NEXT KK
  END IF
NEXT II
FOR KK = 1 TO K1 + 1
  IF KK - 1 <> KP THEN A(IP + 1, KK) = -A(IP + 1, KK) * PIV
NEXT KK
A(IP + 1, KP + 1) = PIV
END SUB

