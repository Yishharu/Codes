(* BEGINENVIRON
CONST
   np =
   map =
TYPE
   RealArrayNPbyNP = ARRAY [1..np,1..np] OF real;
   RealArrayNP = ARRAY [1..np] OF real;
   RealArrayMAbyMA = ARRAY [1..map,1..map] OF real;
ENDENVIRON *)
PROCEDURE svdvar(VAR v: RealArrayNPbyNP;
                    ma: integer;
                 VAR w: RealArrayNP;
               VAR cvm: RealArrayMAbyMA);
VAR
   k,j,i: integer;
   sum: real;
   wti: ^RealArrayNP;
BEGIN
   new(wti);
   FOR i := 1 TO ma DO BEGIN
      wti^[i] := 0.0;
      IF w[i] <> 0.0 THEN
         wti^[i] := 1.0/(w[i]*w[i])
   END;
   FOR i := 1 TO ma DO BEGIN
      FOR j := 1 TO i DO BEGIN
         sum := 0.0;
         FOR k := 1 TO ma DO
            sum := sum+v[i,k]*v[j,k]*wti^[k];
         cvm[i,j] := sum;
         cvm[j,i] := sum
      END
   END;
   dispose(wti)
END;
