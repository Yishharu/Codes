(* BEGINENVIRON
CONST
   np =
TYPE
   EulsumWksp: ARRAY [1..np] OF real;
VAR
   EulsumNterm: integer;
ENDENVIRON *)
PROCEDURE eulsum(VAR sum: real;
                    term: real;
                   jterm: integer);
VAR
   j: integer;
   tmp,dum: real;
BEGIN
   IF jterm = 1 THEN BEGIN
      EulsumNterm := 1;
      EulsumWksp[1] := term;
      sum := 0.5*term
   END
   ELSE BEGIN
      tmp := EulsumWksp[1];
      EulsumWksp[1] := term;
      FOR j := 1 TO EulsumNterm-1 DO BEGIN
         dum := EulsumWksp[j+1];
         EulsumWksp[j+1] := 0.5*(EulsumWksp[j]+tmp);
         tmp := dum
      END;
      EulsumWksp[EulsumNterm+1]
         := 0.5*(EulsumWksp[EulsumNterm]+tmp);
      IF abs(EulsumWksp[EulsumNterm+1])
         <= abs(EulsumWksp[EulsumNterm]) THEN BEGIN
         sum := sum+0.5*EulsumWksp[EulsumNterm+1];
         EulsumNterm := EulsumNterm+1
      END
      ELSE sum := sum
         +EulsumWksp[EulsumNterm+1]
   END
END;
