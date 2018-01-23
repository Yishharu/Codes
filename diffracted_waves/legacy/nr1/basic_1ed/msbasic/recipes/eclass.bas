SUB ECLASS (NF(), N, LISTA(), LISTB(), M)
FOR K = 1 TO N
  NF(K) = K
NEXT K
FOR L = 1 TO M
  J = LISTA(L)
  WHILE NF(J) <> J
    J = NF(J)
  WEND
  K = LISTB(L)
  WHILE NF(K) <> K
    K = NF(K)
  WEND
  IF J <> K THEN NF(J) = K
NEXT L
FOR J = 1 TO N
  WHILE NF(J) <> NF(NF(J))
    NF(J) = NF(NF(J))
  WEND
NEXT J
END SUB

