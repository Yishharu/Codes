(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
   RealArrayNN2 = RealArrayNP;
ENDENVIRON *)
PROCEDURE sinft(VAR y: RealArrayNP;
                    n: integer);
VAR
   jj,j,m,n2: integer;
   sum,y1,y2,wis: real;
   theta,wi,wr,wpi,wpr,wtemp: double;
BEGIN
   theta := 3.14159265358979/n;
   wr := 1.0;
   wi := 0.0;
   wpr := -2.0*sqr(sin(0.5*theta));
   wpi := sin(theta);
   y[1] := 0.0;
   m := n DIV 2;
   n2 := n+2;
   FOR j := 2 TO m+1 DO BEGIN
      wtemp := wr;
      wr := wr*wpr-wi*wpi+wr;
      wi := wi*wpr+wtemp*wpi+wi;
      wis := wi;
      y1 := wis*(y[j]+y[n2-j]);
      y2 := 0.5*(y[j]-y[n2-j]);
      y[j] := y1+y2;
      y[n2-j] := y1-y2
   END;
   realft(y,m,+1);
   sum := 0.0;
   y[1] := 0.5*y[1];
   y[2] := 0.0;
   FOR jj := 0 TO m-1 DO BEGIN
      j := 2*jj+1;
      sum := sum+y[j];
      y[j] := y[j+1];
      y[j+1] := sum
   END
END;
