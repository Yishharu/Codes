(* BEGINENVIRON
CONST
   n2 =
TYPE
   RealArrayNN2 = ARRAY [1..n2] OF real;
ENDENVIRON *)
PROCEDURE realft(VAR data: RealArrayNN2;
                  n,isign: integer);
VAR
   wr,wi,wpr,wpi,wtemp,theta: double;
   i,i1,i2,i3,i4: integer;
   c1,c2,h1r,h1i,h2r,h2i,wrs,wis: real;
BEGIN
   theta := 6.28318530717959/(2.0*n);
   c1 := 0.5;
   IF isign = 1 THEN BEGIN
      c2 := -0.5;
      four1(data,n,1);
   END
   ELSE BEGIN
      c2 := 0.5;
      theta := -theta;
   END;
   wpr := -2.0*sqr(sin(0.5*theta));
   wpi := sin(theta);
   wr := 1.0+wpr;
   wi := wpi;
   FOR i := 2 TO n DIV 2 DO BEGIN
      i1 := i+i-1;
      i2 := i1+1;
      i3 := n+n+3-i2;
      i4 := i3+1;
      wrs := wr;
      wis := wi;
      h1r := c1*(data[i1]+data[i3]);
      h1i := c1*(data[i2]-data[i4]);
      h2r := -c2*(data[i2]+data[i4]);
      h2i := c2*(data[i1]-data[i3]);
      data[i1] := h1r+wrs*h2r-wis*h2i;
      data[i2] := h1i+wrs*h2i+wis*h2r;
      data[i3] := h1r-wrs*h2r+wis*h2i;
      data[i4] := -h1i+wrs*h2i+wis*h2r;
      wtemp := wr;
      wr := wr*wpr-wi*wpi+wr;
      wi := wi*wpr+wtemp*wpi+wi
   END;
   IF isign = 1 THEN BEGIN
      h1r := data[1];
      data[1] := h1r+data[2];
      data[2] := h1r-data[2]
   END
   ELSE BEGIN
      h1r := data[1];
      data[1] := c1*(h1r+data[2]);
      data[2] := c1*(h1r-data[2]);
      four1(data,n,-1)
   END
END;
