(* BEGINENVIRON
CONST
   mp =
TYPE
   RealArrayMP = ARRAY [1..mp] OF real;
ENDENVIRON *)
PROCEDURE smooft(VAR y: RealArrayMP;
                     n: integer;
                   pts: real);
VAR
   nmin,m,mo2,k,j: integer;
   yn,y1,rn1,fac,cnst: real;
BEGIN
   m := 2;
   nmin := n+round(2.0*pts);
   WHILE m < nmin DO m := 2*m;
   cnst := sqr(pts/m);
   y1 := y[1];
   yn := y[n];
   rn1 := 1.0/(n-1.0);
   FOR j := 1 TO n DO
      y[j] := y[j]-rn1*(y1*(n-j)+yn*(j-1));
   FOR j := n+1 TO m DO y[j] := 0.0;
   mo2 := m DIV 2;
   realft(y,mo2,1);
   y[1] := y[1]/mo2;
   fac := 1.0;
   FOR j := 1 TO mo2-1 DO BEGIN
      k := 2*j+1;
      IF fac <> 0.0 THEN BEGIN
         fac := (1.0-cnst*j*j)/mo2;
         IF fac < 0.0 THEN fac := 0.0;
         y[k] := fac*y[k];
         y[k+1] := fac*y[k+1]
      END
      ELSE BEGIN
         y[k] := 0.0;
         y[k+1] := 0.0
      END
   END;
   fac := (1.0-0.25*pts*pts)/mo2;
   IF fac < 0.0 THEN fac := 0.0;
   y[2] := fac*y[2];
   realft(y,mo2,-1);
   FOR j := 1 TO n DO
      y[j] := rn1*(y1*(n-j)+yn*(j-1))+y[j]
END;
