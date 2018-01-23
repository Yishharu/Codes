(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
ENDENVIRON *)
PROCEDURE pcshft(a,b: real;
               VAR d: RealArrayNP;
                   n: integer);
VAR
   k,j: integer;
   fac,cnst: real;
BEGIN
   cnst := 2.0/(b-a);
   fac := cnst;
   FOR j := 2 TO n DO BEGIN
      d[j] := d[j]*fac;
      fac := fac*cnst
   END;
   cnst := 0.5*(a+b);
   FOR j := 1 TO n-1 DO
      FOR k := n-1 DOWNTO j DO
         d[k] := d[k]-cnst*d[k+1]
END;
