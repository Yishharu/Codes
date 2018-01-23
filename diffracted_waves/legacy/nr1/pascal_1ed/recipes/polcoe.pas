(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
ENDENVIRON *)
PROCEDURE polcoe(VAR x,y: RealArrayNP;
                       n: integer;
                 VAR cof: RealArrayNP);
VAR
   k,j,i: integer;
   phi,ff,b: real;
   s: ^RealArrayNP;
BEGIN
   new(s);
   FOR i := 1 TO n DO BEGIN
      s^[i] := 0.0;
      cof[i] := 0.0
   END;
   s^[n] := -x[1];
   FOR i := 2 TO n DO BEGIN
      FOR j := n+1-i TO n-1 DO
         s^[j] := s^[j]-x[i]*s^[j+1];
      s^[n] := s^[n]-x[i]
   END;
   FOR j := 1 TO n DO BEGIN
      phi := n;
      FOR k := n-1 DOWNTO 1 DO
         phi := k*s^[k+1]+x[j]*phi;
      ff := y[j]/phi;
      b := 1.0;
      FOR k := n DOWNTO 1 DO BEGIN
         cof[k] := cof[k]+b*ff;
         b := s^[k]+x[j]*b
      END
   END;
   dispose(s)
END;
