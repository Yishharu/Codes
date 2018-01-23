(* BEGINENVIRON
CONST
   np =
   n2 =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
   RealArrayN2 = ARRAY [1..n2] OF real;
   RealArrayNN2 = RealArrayN2;
   RealArray2tN = RealArrayN2;
ENDENVIRON *)
PROCEDURE convlv(VAR data: RealArrayNP;
                        n: integer;
               VAR respns: RealArrayNP;
                  m,isign: integer;
                  VAR ans: RealArrayN2);
VAR
   no2,i,ii: integer;
   dum,mag2: real;
   fft: ^RealArrayN2;
BEGIN
   new(fft);
   FOR i := 1 TO (m-1) DIV 2 DO
      respns[n+1-i] := respns[m+1-i];
   FOR i := (m+3) DIV 2 TO n-((m-1) DIV 2) DO
      respns[i] := 0.0;
   twofft(data,respns,fft^,ans,n);
   no2 := n DIV 2;
   FOR i := 1 TO no2+1 DO BEGIN
      ii := 2*i;
      IF isign = 1 THEN BEGIN
         dum := ans[ii-1];
         ans[ii-1] := (fft^[ii-1]*ans[ii-1]-fft^[ii]*ans[ii])/no2;
         ans[ii] := (fft^[ii]*dum+fft^[ii-1]*ans[ii])/no2
      END
      ELSE IF isign = -1 THEN BEGIN
         IF sqr(ans[ii-1])+sqr(ans[ii]) = 0.0 THEN BEGIN
            writeln('pause in routine CONVLV');
            writeln('deconvolving at response zero');
            readln
         END;
         dum := ans[ii-1];
         mag2 := sqr(ans[ii-1])+sqr(ans[ii]);
         ans[ii-1] := (fft^[ii-1]*ans[ii-1]+fft^[ii]*ans[ii])/(mag2*no2);
         ans[ii] := (fft^[ii]*dum-fft^[ii-1]*ans[ii])/(mag2*no2)
      END
      ELSE BEGIN
         writeln('pause in routine CONVLV');
         writeln('no meaning for ISIGN');
         readln
      END
   END;
   ans[2] := ans[n+1];
   realft(ans,no2,-1);
   dispose(fft)
END;
