(* BEGINENVIRON
CONST
   ndat2 =
   ndimp =
TYPE
   RealArrayNDAT2 = ARRAY [1..ndat2] OF real;
   IntegerArrayNDIM = ARRAY [1..ndimp] OF integer;
ENDENVIRON *)
PROCEDURE fourn(VAR data: RealArrayNDAT2;
                  VAR nn: IntegerArrayNDIM;
              ndim,isign: integer);
VAR
   i1,i2,i3,i2rev,i3rev,ibit,idim: integer;
   ip1,ip2,ip3,ifp1,ifp2,k1,k2,n: integer;
   ii1,ii2,ii3: integer;
   nprev,nrem,ntot: integer;
   tempi,tempr,wrs,wis: real;
   theta,wi,wpi,wpr,wr,wtemp: double;
BEGIN
   ntot := 1;
   FOR idim := 1 TO ndim DO
      ntot := ntot*nn[idim];
   nprev := 1;
   FOR idim := ndim DOWNTO 1 DO BEGIN
      n := nn[idim];
      nrem := ntot DIV (n*nprev);
      ip1 := 2*nprev;
      ip2 := ip1*n;
      ip3 := ip2*nrem;
      i2rev := 1;
      FOR ii2 := 0 TO (ip2-1) DIV ip1 DO BEGIN
         i2 := 1+ii2*ip1;
         IF i2 < i2rev THEN BEGIN
            FOR ii1 := 0 TO (ip1-2) DIV 2 DO BEGIN
               i1 := i2+ii1*2;
               FOR ii3 := 0 TO (ip3-i1) DIV ip2 DO BEGIN
                  i3 := i1+ii3*ip2;
                  i3rev := i2rev+i3-i2;
                  tempr := data[i3];
                  tempi := data[i3+1];
                  data[i3] := data[i3rev];
                  data[i3+1] := data[i3rev+1];
                  data[i3rev] := tempr;
                  data[i3rev+1] := tempi
               END
            END
         END;
         ibit := ip2 DIV 2;
         WHILE (ibit >= ip1) AND (i2rev > ibit) DO BEGIN
            i2rev := i2rev-ibit;
            ibit := ibit DIV 2
         END;
         i2rev := i2rev+ibit
      END;
      ifp1 := ip1;
      WHILE ifp1 < ip2 DO BEGIN
         ifp2 := 2*ifp1;
         theta := isign*6.28318530717959/(ifp2 DIV ip1);
         wpr := -2.0*sqr(sin(0.5*theta));
         wpi := sin(theta);
         wr := 1.0;
         wi := 0.0;
         FOR ii3 := 0 TO (ifp1-1) DIV ip1 DO BEGIN
            i3 := 1+ii3*ip1;
            wrs := wr;
            wis := wi;
            FOR ii1 := 0 TO (ip1-2) DIV 2 DO BEGIN
               i1 := i3+ii1*2;
               FOR ii2 := 0 TO (ip3-i1) DIV ifp2 DO BEGIN
                  i2 := i1+ii2*ifp2;
                  k1 := i2;
                  k2 := k1+ifp1;
                  tempr := wrs*data[k2]-wis*data[k2+1];
                  tempi := wrs*data[k2+1]+wis*data[k2];
                  data[k2] := data[k1]-tempr;
                  data[k2+1] := data[k1+1]-tempi;
                  data[k1] := data[k1]+tempr;
                  data[k1+1] := data[k1+1]+tempi
               END
            END;
            wtemp := wr;
            wr := wr*wpr-wi*wpi+wr;
            wi := wi*wpr+wtemp*wpi+wi
         END;
         ifp1 := ifp2
      END;
      nprev := n*nprev
   END
END;
