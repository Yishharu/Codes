(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
ENDENVIRON *)
PROCEDURE chebpc(VAR c,d: RealArrayNP;
                       n: integer);
VAR
   k,j: integer;
   sv: real;
   dd: ^RealArrayNP;
BEGIN
   new(dd);
   FOR j := 1 TO n DO BEGIN
      d[j] := 0.0;
      dd^[j] := 0.0
   END;
   d[1] := c[n];
   FOR j := n-1 DOWNTO 2 DO BEGIN
      FOR k := n-j+1 DOWNTO 2 DO BEGIN
         sv := d[k];
         d[k] := 2.0*d[k-1]-dd^[k];
         dd^[k] := sv
      END;
      sv := d[1];
      d[1] := -dd^[1]+c[j];
      dd^[1] := sv
   END;
   FOR j := n DOWNTO 2 DO
      d[j] := d[j-1]-dd^[j];
   d[1] := -dd^[1]+0.5*c[1];
   dispose(dd)
END;
