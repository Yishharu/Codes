(* BEGINENVIRON
CONST
   nip =
   njp =
TYPE
   IntegerArrayNIbyNJ = ARRAY [1..nip,1..njp] OF integer;
   RealArrayNI = ARRAY [1..nip] OF real;
   RealArrayNJ = ARRAY [1..njp] OF real;
ENDENVIRON *)
PROCEDURE cntab2(VAR nn: IntegerArrayNIbyNJ;
                  ni,nj: integer;
  VAR h,hx,hy,hygx,hxgy: real;
      VAR uygx,uxgy,uxy: real);
CONST
   tiny = 1.0e-30;
VAR
   j,i: integer;
   sum,p: real;
   sumi: ^RealArrayNI;
   sumj: ^RealArrayNJ;
BEGIN
   new(sumi);
   new(sumj);
   sum := 0;
   FOR i := 1 TO ni DO BEGIN
      sumi^[i] := 0.0;
      FOR j := 1 TO nj DO BEGIN
         sumi^[i] := sumi^[i]+nn[i,j];
         sum := sum+nn[i,j]
      END
   END;
   FOR j := 1 TO nj DO BEGIN
      sumj^[j] := 0.0;
      FOR i := 1 TO ni DO
         sumj^[j] := sumj^[j]+nn[i,j]
   END;
   hx := 0.0;
   FOR i := 1 TO ni DO BEGIN
      IF sumi^[i] <> 0.0 THEN BEGIN
         p := sumi^[i]/sum;
         hx := hx-p*ln(p)
      END
   END;
   hy := 0.0;
   FOR j := 1 TO nj DO BEGIN
      IF sumj^[j] <> 0.0 THEN BEGIN
         p := sumj^[j]/sum;
         hy := hy-p*ln(p)
      END
   END;
   h := 0.0;
   FOR i := 1 TO ni DO BEGIN
      FOR j := 1 TO nj DO BEGIN
         IF nn[i,j] <> 0 THEN BEGIN
            p := nn[i,j]/sum;
            h := h-p*ln(p)
         END
      END
   END;
   hygx := h-hx;
   hxgy := h-hy;
   uygx := (hy-hygx)/(hy+tiny);
   uxgy := (hx-hxgy)/(hx+tiny);
   uxy := 2.0*(hx+hy-h)/(hx+hy+tiny);
   dispose(sumj);
   dispose(sumi)
END;
