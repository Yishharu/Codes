(* BEGINENVIRON
CONST
   np =
TYPE
   IntegerArrayNP = ARRAY [1..np] OF integer;
ENDENVIRON *)
PROCEDURE rank(n: integer;
  VAR indx,irank: IntegerArrayNP);
VAR
   j: integer;
BEGIN
   FOR j := 1 TO n DO irank[indx[j]] := j
END;
