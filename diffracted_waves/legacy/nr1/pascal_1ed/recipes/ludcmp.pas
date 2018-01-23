(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNPbyNP = ARRAY [1..np,1..np] OF real;
   RealArrayNP = ARRAY [1..np] OF real;
   IntegerArrayNP = ARRAY [1..np] OF integer;
ENDENVIRON *)
PROCEDURE ludcmp(VAR a: RealArrayNPbyNP;
                     n: integer;
              VAR indx: IntegerArrayNP;
                 VAR d: real);
CONST
   tiny = 1.0e-20;
VAR
   k,j,imax,i: integer;
   sum,dum,big: real;
   vv: ^RealArrayNP;
BEGIN
   new(vv);
   d := 1.0;
   FOR i := 1 TO n DO BEGIN
      big := 0.0;
      FOR j := 1 TO n DO
         IF abs(a[i,j]) > big THEN big := abs(a[i,j]);
      IF big = 0.0 THEN BEGIN
         writeln('pause in LUDCMP - singular matrix');
         readln
      END;
      vv^[i] := 1.0/big
   END;
   FOR j := 1 TO n DO BEGIN
      FOR i := 1 TO j-1 DO BEGIN
         sum := a[i,j];
         FOR k := 1 TO i-1 DO
            sum := sum-a[i,k]*a[k,j];
         a[i,j] := sum
      END;
      big := 0.0;
      FOR i := j TO n DO BEGIN
         sum := a[i,j];
         FOR k := 1 TO j-1 DO
            sum := sum-a[i,k]*a[k,j];
         a[i,j] := sum;
         dum := vv^[i]*abs(sum);
         IF dum >= big THEN BEGIN
            big := dum;
            imax := i
         END
      END;
      IF j <> imax THEN BEGIN
         FOR k := 1 TO n DO BEGIN
            dum := a[imax,k];
            a[imax,k] := a[j,k];
            a[j,k] := dum
         END;
         d := -d;
         vv^[imax] := vv^[j]
      END;
      indx[j] := imax;
      IF a[j,j] = 0.0 THEN a[j,j] := tiny;
      IF j <> n THEN BEGIN
         dum := 1.0/a[j,j];
         FOR i := j+1 TO n DO
            a[i,j] := a[i,j]*dum
      END
   END;
   dispose(vv)
END;
