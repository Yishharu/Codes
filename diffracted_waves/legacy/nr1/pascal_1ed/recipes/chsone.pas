(* BEGINENVIRON
CONST
   nbinsp =
TYPE
   RealArrayNBINS = ARRAY [1..nbinsp] OF real;
ENDENVIRON *)
PROCEDURE chsone(VAR bins,ebins: RealArrayNBINS;
                   nbins,knstrn: integer;
               VAR df,chsq,prob: real);
VAR
   j: integer;
BEGIN
   df := nbins-1-knstrn;
   chsq := 0.0;
   FOR j := 1 TO nbins DO BEGIN
      IF ebins[j] <= 0.0 THEN
         writeln('pause in CHSONE - bad expected number');
      chsq := chsq+sqr(bins[j]-ebins[j])/ebins[j]
   END;
   prob := gammq(0.5*df,0.5*chsq)
END;
