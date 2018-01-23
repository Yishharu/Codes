(* BEGINENVIRON
CONST
   ndatap =
   npolesp =
   nfutp =
TYPE
   RealArrayNDATA = ARRAY [1..ndatap] OF real;
   RealArrayNPOLES = ARRAY [1..npolesp] OF real;
   RealArrayNFUT = ARRAY [1..nfutp] OF real;
ENDENVIRON *)
PROCEDURE predic(VAR data: RealArrayNDATA;
                    ndata: integer;
                    VAR d: RealArrayNPOLES;
                   npoles: integer;
               VAR future: RealArrayNFUT;
                     nfut: integer);
VAR
   k,j: integer;
   sum,discrp: real;
   reg: ^RealArrayNPOLES;
BEGIN
   new(reg);
   FOR j := 1 TO npoles DO reg^[j] := data[ndata+1-j];
   FOR j := 1 TO nfut DO BEGIN
      discrp := 0.0;
      sum := discrp;
      FOR k := 1 TO npoles DO
         sum := sum+d[k]*reg^[k];
      FOR k := npoles DOWNTO 2 DO
         reg^[k] := reg^[k-1];
      reg^[1] := sum;
      future[j] := sum
   END;
   dispose(reg)
END;
