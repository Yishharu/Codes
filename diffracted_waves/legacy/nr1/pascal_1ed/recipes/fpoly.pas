(* BEGINENVIRON
CONST
   npp =
TYPE
   RealArrayNP = ARRAY [1..npp] OF real;
ENDENVIRON *)
PROCEDURE fpoly(x: real;
            VAR p: RealArrayNP;
               np: integer);
VAR
   j: integer;
BEGIN
   p[1] := 1.0;
   FOR j := 2 TO np DO p[j] := p[j-1]*x
END;
