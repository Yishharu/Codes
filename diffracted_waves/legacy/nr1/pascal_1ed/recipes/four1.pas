(* BEGINENVIRON
CONST
   nn2 =
TYPE
   RealArrayNN2 = ARRAY [1..nn2] OF real;
ENDENVIRON *)
PROCEDURE four1(VAR data: RealArrayNN2;
                nn,isign: integer);
VAR
   ii,jj,n,mmax,m,j,istep,i: integer;
   wtemp,wr,wpr,wpi,wi,theta: double;
   tempr,tempi,wrs,wis: real;
BEGIN
   n := 2*nn;
   j := 1;
   FOR ii := 1 TO nn DO BEGIN
      i := 2*ii-1;
      IF j > i THEN BEGIN
         tempr := data[j];
         tempi := data[j+1];
         data[j] := data[i];
         data[j+1] := data[i+1];
         data[i] := tempr;
         data[i+1] := tempi
      END;
      m := n DIV 2;
      WHILE (m >= 2) AND (j > m) DO BEGIN
         j := j-m;
         m := m DIV 2
      END;
      j := j+m
   END;
   mmax := 2;
   WHILE n > mmax DO BEGIN
      istep := 2*mmax;
      theta := 6.28318530717959/(isign*mmax);
      wpr := -2.0*sqr(sin(0.5*theta));
      wpi := sin(theta);
      wr := 1.0;
      wi := 0.0;
      FOR ii := 1 TO mmax DIV 2 DO BEGIN
         m := 2*ii-1;
         wrs := wr;
         wis := wi;
         FOR jj := 0 TO (n-m) DIV istep DO BEGIN
            i := m + jj*istep;
            j := i+mmax;
            tempr := wrs*data[j]-wis*data[j+1];
            tempi := wrs*data[j+1]+wis*data[j];
            data[j] := data[i]-tempr;
            data[j+1] := data[i+1]-tempi;
            data[i] := data[i]+tempr;
            data[i+1] := data[i+1]+tempi
         END;
         wtemp := wr;
         wr := wr*wpr-wi*wpi+wr;
         wi := wi*wpr+wtemp*wpi+wi
      END;
      mmax := istep
   END
END;
