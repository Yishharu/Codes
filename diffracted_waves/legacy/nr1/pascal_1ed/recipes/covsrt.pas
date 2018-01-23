(* BEGINENVIRON
CONST
   map =
   mfitp =
TYPE
   RealArrayMAbyMA = ARRAY [1..map,1..map] OF real;
   IntegerArrayMFIT = ARRAY [1..mfitp] OF integer;
ENDENVIRON *)
PROCEDURE covsrt(VAR covar: RealArrayMAbyMA;
                        ma: integer;
                 VAR lista: IntegerArrayMFIT;
                      mfit: integer);
VAR
   j,i: integer;
   swap: real;
BEGIN
   FOR j := 1 TO ma-1 DO
      FOR i := j+1 TO ma DO covar[i,j] := 0.0;
   FOR i := 1 TO mfit-1 DO BEGIN
      FOR j := i+1 TO mfit DO
         IF lista[j] > lista[i] THEN
            covar[lista[j],lista[i]] := covar[i,j]
         ELSE
            covar[lista[i],lista[j]] := covar[i,j]
   END;
   swap := covar[1,1];
   FOR j := 1 TO ma DO BEGIN
      covar[1,j] := covar[j,j];
      covar[j,j] := 0.0
   END;
   covar[lista[1],lista[1]] := swap;
   FOR j := 2 TO mfit DO
      covar[lista[j],lista[j]] := covar[1,j];
   FOR j := 2 TO ma DO
      FOR i := 1 TO j-1 DO
         covar[i,j] := covar[j,i]
END;
