(* BEGINENVIRON
CONST
   nbinsp =
TYPE
   RealArrayNBINS = ARRAY [1..nbinsp] OF real;
ENDENVIRON *)
PROCEDURE chstwo(VAR bins1,bins2: RealArrayNBINS;
                    nbins,knstrn: integer;
                VAR df,chsq,prob: real);
VAR
   j: integer;
BEGIN
   df := nbins-1-knstrn;
   chsq := 0.0;
   FOR j := 1 TO nbins DO BEGIN
      IF (bins1[j] = 0.0) AND (bins2[j] = 0.0) THEN
         df := df-1.0
      ELSE
         chsq := chsq+sqr(bins1[j]-bins2[j])/(bins1[j]+bins2[j])
   END;
   prob := gammq(0.5*df,0.5*chsq)
END;
