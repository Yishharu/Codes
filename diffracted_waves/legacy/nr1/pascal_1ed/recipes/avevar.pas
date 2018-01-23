(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
ENDENVIRON *)
PROCEDURE avevar(VAR data: RealArrayNP;
                        n: integer;
             VAR ave,svar: real);
VAR
   j: integer;
   s: real;
BEGIN
   ave := 0.0;
   svar := 0.0;
   FOR j := 1 TO n DO ave := ave+data[j];
   ave := ave/n;
   FOR j := 1 TO n DO BEGIN
      s := data[j]-ave;
      svar := svar+s*s
   END;
   svar := svar/(n-1)
END;
