(* BEGINENVIRON
CONST
   np =
   mp =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
   RealArrayMP = ARRAY [1..mp] OF real;
ENDENVIRON *)
PROCEDURE memcof(VAR data: RealArrayNP;
                      n,m: integer;
                   VAR pm: real;
                  VAR cof: RealArrayMP);
LABEL 99;
VAR
   k,j,i: integer;
   num,p,denom: real;
   wk1,wk2: ^RealArrayNP;
   wkm: ^RealArrayMP;
BEGIN
   new(wk1);
   new(wk2);
   new(wkm);
   p := 0.0;
   FOR j := 1 TO n DO
      p := p+sqr(data[j]);
   pm := p/n;
   wk1^[1] := data[1];
   wk2^[n-1] := data[n];
   FOR j := 2 TO n-1 DO BEGIN
      wk1^[j] := data[j];
      wk2^[j-1] := data[j]
   END;
   FOR k := 1 TO m DO BEGIN
      num := 0.0;
      denom := 0.0;
      FOR j := 1 TO n-k DO BEGIN
         num := num+wk1^[j]*wk2^[j];
         denom := denom+sqr(wk1^[j])+sqr(wk2^[j])
      END;
      cof[k] := 2.0*num/denom;
      pm := pm*(1.0-sqr(cof[k]));
      FOR i := 1 TO k-1 DO
         cof[i] := wkm^[i]-cof[k]*wkm^[k-i];
      IF k = m THEN GOTO 99;
      FOR i := 1 TO k DO wkm^[i] := cof[i];
      FOR j := 1 TO n-k-1 DO BEGIN
         wk1^[j] := wk1^[j]-wkm^[k]*wk2^[j];
         wk2^[j] := wk2^[j+1]-wkm^[k]*wk1^[j+1]
      END
   END;
99:
   dispose(wkm);
   dispose(wk2);
   dispose(wk1)
END;
