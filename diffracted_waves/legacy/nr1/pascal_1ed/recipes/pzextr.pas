(* BEGINENVIRON
CONST
   nvar =
   PzextrImax = 11;
   PzextrNmax = 10;
   PzextrNcol = 7;
TYPE
   RealArrayNVAR = ARRAY [1..nvar] OF real;
VAR
   PzextrX: ARRAY [1..PzextrImax] OF real;
   PzextrQcol: ARRAY [1..PzextrNmax,1..PzextrNcol] OF real;
ENDENVIRON *)
PROCEDURE pzextr(iest: integer;
                 xest: real;
       VAR yest,yz,dy: RealArrayNVAR;
               n,nuse: integer);
VAR
   m1,k1,j: integer;
   q,f2,f1,delta: real;
   d: ^RealArrayNVAR;
BEGIN
   new(d);
   PzextrX[iest] := xest;
   FOR j := 1 TO n DO BEGIN
      dy[j] := yest[j];
      yz[j] := yest[j]
   END;
   IF iest = 1 THEN
      FOR j := 1 TO n DO
         PzextrQcol[j,1] := yest[j]
   ELSE BEGIN
      IF iest < nuse THEN
         m1 := iest
      ELSE
         m1 := nuse;
      FOR j := 1 TO n DO
         d^[j] := yest[j];
      FOR k1 := 1 TO m1-1 DO BEGIN
         delta := 1.0/(PzextrX[iest-k1]-xest);
         f1 := xest*delta;
         f2 := PzextrX[iest-k1]*delta;
         FOR j := 1 TO n DO BEGIN
            q := PzextrQcol[j,k1];
            PzextrQcol[j,k1] := dy[j];
            delta := d^[j]-q;
            dy[j] := f1*delta;
            d^[j] := f2*delta;
            yz[j] := yz[j]+dy[j]
         END
      END;
      FOR j := 1 TO n DO
         PzextrQcol[j,m1] := dy[j]
   END;
   dispose(d)
END;
