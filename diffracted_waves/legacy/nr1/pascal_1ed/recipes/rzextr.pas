(* BEGINENVIRON
CONST
   nvar =
   RzextrImax  =  11;
   RzextrNmax  =  10;
   RzextrNcol  =  7;
TYPE
   RealArrayNVAR = ARRAY [1..nvar] OF real;
VAR
   RzextrX: ARRAY [1..RzextrImax] OF real;
   RzextrD: ARRAY [1..RzextrNmax,1..RzextrNcol] OF real;
ENDENVIRON *)
PROCEDURE rzextr(iest: integer;
                 xest: real;
       VAR yest,yz,dy: RealArrayNVAR;
               n,nuse: integer);
VAR
   m1,k,j: integer;
   yy,v,ddy,c,b1,b: real;
   fx: ARRAY [1..RzextrNcol] OF real;
BEGIN
   RzextrX[iest] := xest;
   IF iest = 1 THEN
      FOR j := 1 TO n DO BEGIN
         yz[j] := yest[j];
         RzextrD[j,1] := yest[j];
         dy[j] := yest[j]
      END
   ELSE BEGIN
      IF iest < nuse THEN
         m1 := iest
      ELSE
         m1 := nuse;
      FOR k := 1 TO m1-1 DO
         fx[k+1] := RzextrX[iest-k]/xest;
      FOR j := 1 TO n DO BEGIN
         yy := yest[j];
         v := RzextrD[j,1];
         c := yy;
         RzextrD[j,1] := yy;
         FOR k := 2 TO m1 DO BEGIN
            b1 := fx[k]*v;
            b := b1-c;
            IF b <> 0.0 THEN BEGIN
               b := (c-v)/b;
               ddy := c*b;
               c := b1*b
            END
            ELSE
               ddy := v;
            IF k <> m1 THEN
               v := RzextrD[j,k];
            RzextrD[j,k] := ddy;
            yy := yy+ddy
         END;
         dy[j] := ddy;
         yz[j] := yy
      END
   END
END;
