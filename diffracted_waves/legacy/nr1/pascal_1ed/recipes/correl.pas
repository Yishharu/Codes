(* BEGINENVIRON
CONST
   np =
   n2 =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
   RealArray2tN = ARRAY [1..n2] OF real;
ENDENVIRON *)
PROCEDURE correl(VAR data1,data2: RealArrayNP;
                               n: integer;
                         VAR ans: RealArray2tN);
VAR
   no2,i,ii: integer;
   dum: real;
   fft: ^RealArray2tN;
BEGIN
   new(fft);
   twofft(data1,data2,fft^,ans,n);
   no2 := n DIV 2;
   FOR i := 1 TO no2+1 DO BEGIN
      ii := 2*i;
      dum := ans[ii-1];
      ans[ii-1] := (fft^[ii-1]*ans[ii-1]+fft^[ii]*ans[ii])/no2;
      ans[ii] := (fft^[ii]*dum-fft^[ii-1]*ans[ii])/no2
   END;
   ans[2] := ans[n+1];
   realft(ans,no2,-1);
   dispose(fft)
END;
