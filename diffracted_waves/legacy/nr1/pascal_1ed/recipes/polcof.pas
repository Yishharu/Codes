(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
ENDENVIRON *)
PROCEDURE polcof(VAR xa,ya: RealArrayNP;
                         n: integer;
                   VAR cof: RealArrayNP);
VAR
   k,j,i: integer;
   xmin,dy: real;
   x,y: ^RealArrayNP;
BEGIN
   new(x);
   new(y);
   FOR j := 1 TO n DO BEGIN
      x^[j] := xa[j];
      y^[j] := ya[j]
   END;
   FOR j := 1 TO n DO BEGIN
      polint(x^,y^,n+1-j,0.0,cof[j],dy);
      xmin := 1.0E38;
      k := 0;
      FOR i := 1 TO n+1-j DO BEGIN
         IF abs(x^[i]) < xmin THEN BEGIN
            xmin := abs(x^[i]);
            k := i
         END;
         IF x^[i] <> 0.0 THEN
            y^[i] := (y^[i]-cof[j])/x^[i]
      END;
      FOR i := k+1 TO n+1-j DO BEGIN
         y^[i-1] := y^[i];
         x^[i-1] := x^[i]
      END
   END;
   dispose(y);
   dispose(x)
END;
