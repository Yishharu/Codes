(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
ENDENVIRON *)
PROCEDURE chder(a,b: real;
         VAR c,cder: RealArrayNP;
                  n: integer);
VAR
   j: integer;
   con: real;
BEGIN
   cder[n] := 0.0;
   cder[n-1] := 2*(n-1)*c[n];
   IF n >= 3 THEN
      FOR j := n-2 DOWNTO 1 DO
         cder[j] := cder[j+2]+2*j*c[j+1];
   con := 2.0/(b-a);
   FOR j := 1 TO n DO
      cder[j] := cder[j]*con
END;
