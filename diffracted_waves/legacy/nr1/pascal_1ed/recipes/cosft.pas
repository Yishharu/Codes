(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
   RealArrayNN2 = RealArrayNP;
ENDENVIRON *)
PROCEDURE cosft(VAR y: RealArrayNP;
              n,isign: integer);
VAR
   enf0,even,odd,sum,sume,sumo,y1,y2,wrs,wis: real;
   theta,wi,wr,wpi,wpr,wtemp: double;
   jj,j,m,n2: integer;
BEGIN
   theta := 3.14159265358979/n;
   wr := 1.0;
   wi := 0.0;
   wpr := -2.0*sqr(sin(0.5*theta));
   wpi := sin(theta);
   sum := y[1];
   m := n DIV 2;
   n2 := n+2;
   FOR j := 2 TO m DO BEGIN
      wtemp := wr;
      wr := wr*wpr-wi*wpi+wr;
      wi := wi*wpr+wtemp*wpi+wi;
      wrs := wr;
      wis := wi;
      y1 := 0.5*(y[j]+y[n2-j]);
      y2 := (y[j]-y[n2-j]);
      y[j] := y1-wis*y2;
      y[n2-j] := y1+wis*y2;
      sum := sum+wrs*y2
   END;
   realft(y,m,+1);
   y[2] := sum;
   FOR jj := 2 TO m DO BEGIN
      j := 2*jj;
      sum := sum+y[j];
      y[j] := sum
   END;
   IF isign = -1 THEN BEGIN
      even := y[1];
      odd := y[2];
      FOR jj := 1 TO m-1 DO BEGIN
         j := 2*jj+1;
         even := even+y[j];
         odd := odd+y[j+1]
      END;
      enf0 := 2.0*(even-odd);
      sumo := y[1]-enf0;
      sume := (2.0*odd/n)-sumo;
      y[1] := 0.5*enf0;
      y[2] := y[2]-sume;
      FOR jj := 1 TO m-1 DO BEGIN
         j := 2*jj+1;
         y[j] := y[j]-sumo;
         y[j+1] := y[j+1]-sume
      END
   END
END;
