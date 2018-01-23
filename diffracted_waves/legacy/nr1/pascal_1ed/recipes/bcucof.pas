(* BEGINENVIRON
TYPE
   RealArray4 = ARRAY [1..4] OF real;
   RealArray4by4 = ARRAY [1..4,1..4] OF real;
VAR
   infile: text;
   BcucofFlag: boolean;
   BcucofWt: ARRAY [1..16,1..16] OF real;
BEGIN
   BcucofFlag := true;
ENDENVIRON *)
PROCEDURE bcucof(VAR y,y1,y2,y12: RealArray4;
                           d1,d2: real;
                           VAR c: RealArray4by4);
VAR
   l,k,j,i: integer;
   xx,d1d2: real;
   cl,x: ARRAY[1..16] OF real;
BEGIN
   IF BcucofFlag THEN BEGIN
      BcucofFlag := FALSE;
      NROpen(infile,'bcucof.dat');
      FOR i := 1 to 16 DO
         FOR k := 1 to 16 DO read(infile,BcucofWt[k,i]);
      close(infile)
   END;
   d1d2 := d1*d2;
   FOR i := 1 to 4 DO BEGIN
      x[i] := y[i];
      x[i+4] := y1[i]*d1;
      x[i+8] := y2[i]*d2;
      x[i+12] := y12[i]*d1d2
   END;
   FOR i := 1 to 16 DO BEGIN
      xx := 0.0;
      FOR k := 1 to 16 DO xx := xx+BcucofWt[i,k]*x[k];
      cl[i] := xx
   END;
   l := 0;
   FOR i := 1 to 4 DO
   FOR j := 1 to 4 DO BEGIN
      l := l+1;
      c[i,j] := cl[l]
   END
END;
