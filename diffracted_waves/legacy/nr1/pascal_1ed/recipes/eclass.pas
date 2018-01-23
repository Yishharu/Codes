(* BEGINENVIRON
CONST
   np =
   mp =
TYPE
   IntegerArrayNP = ARRAY [1..np] OF integer;
   IntegerArrayMP = ARRAY [1..mp] OF integer;
ENDENVIRON *)
PROCEDURE eclass(VAR nf: IntegerArrayNP;
                      n: integer;
        VAR lista,listb: IntegerArrayMP;
                      m: integer);
VAR
   l,k,j: integer;
BEGIN
   FOR k := 1 TO n DO nf[k] := k;
   FOR l := 1 TO m DO BEGIN
      j := lista[l];
      WHILE nf[j] <> j DO j := nf[j];
      k := listb[l];
      WHILE nf[k] <> k DO k := nf[k];
      IF j <> k THEN nf[j] := k
   END;
   FOR j := 1 TO n DO
      WHILE nf[j] <> nf[nf[j]] DO nf[j] := nf[nf[j]];
END;
