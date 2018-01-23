(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
   IntegerArrayNP = ARRAY [1..np] OF integer;
ENDENVIRON *)
PROCEDURE sort3(n: integer;
     VAR ra,rb,rc: RealArrayNP);
VAR
   j: integer;
   wksp: ^RealArrayNP;
   iwksp: ^IntegerArrayNP;
BEGIN
   new(wksp);
   new(iwksp);
   indexx(n,ra,iwksp^);
   FOR j := 1 TO n DO wksp^[j] := ra[j];
   FOR j := 1 TO n DO ra[j] := wksp^[iwksp^[j]];
   FOR j := 1 TO n DO wksp^[j] := rb[j];
   FOR j := 1 TO n DO rb[j] := wksp^[iwksp^[j]];
   FOR j := 1 TO n DO wksp^[j] := rc[j];
   FOR j := 1 TO n DO rc[j] := wksp^[iwksp^[j]];
   dispose(iwksp);
   dispose(wksp)
END;
