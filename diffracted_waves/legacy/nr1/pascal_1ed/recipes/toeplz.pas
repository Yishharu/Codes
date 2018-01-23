(* BEGINENVIRON
CONST
   np =
   n2m1 =
   RealArrayNP = ARRAY [1..np] OF real;
   RealArray2Nm1 = ARRAY [1..n2m1] OF real;
ENDENVIRON *)
PROCEDURE toeplz(VAR r: RealArray2Nm1;
               VAR x,y: RealArrayNP;
                     n: integer);
LABEL 1,99;
VAR
   m2,m1,m,k,j: integer;
   sxn,shn,sgn,sgd,sd,qt2,qt1,qq,pt2,pt1,pp: double;
   g,h: ^RealArrayNP;
BEGIN
   new(g);
   new(h);
   IF r[n] = 0.0 THEN GOTO 1;
   x[1] := y[1]/r[n];
   IF n = 1 THEN GOTO 99;
   g^[1] := r[n-1]/r[n];
   h^[1] := r[n+1]/r[n];
   FOR m := 1 TO n DO BEGIN
      m1 := m+1;
      sxn := -y[m1];
      sd := -r[n];
      FOR j := 1 TO m DO BEGIN
         sxn := sxn+r[n+m1-j]*x[j];
         sd := sd+r[n+m1-j]*g^[m-j+1]
      END;
      IF sd = 0.0 THEN GOTO 1;
      x[m1] := sxn/sd;
      FOR j := 1 TO m DO
         x[j] := x[j]-x[m1]*g^[m-j+1];
      IF m1 = n THEN GOTO 99;
      sgn := -r[n-m1];
      shn := -r[n+m1];
      sgd := -r[n];
      FOR j := 1 TO m DO BEGIN
         sgn := sgn+r[n+j-m1]*g^[j];
         shn := shn+r[n+m1-j]*h^[j];
         sgd := sgd+r[n+j-m1]*h^[m-j+1]
      END;
      IF (sd = 0.0) OR (sgd = 0.0) THEN GOTO 1;
      g^[m1] := sgn/sgd;
      h^[m1] := shn/sd;
      k := m;
      m2 := (m+1) DIV 2;
      pp := g^[m1];
      qq := h^[m1];
      FOR j := 1 TO m2 DO BEGIN
         pt1 := g^[j];
         pt2 := g^[k];
         qt1 := h^[j];
         qt2 := h^[k];
         g^[j] := pt1-pp*qt2;
         g^[k] := pt2-pp*qt1;
         h^[j] := qt1-qq*pt2;
         h^[k] := qt2-qq*pt1;
         k := k-1
      END
   END;
   writeln('pause in TOEPLZ - should not arrive here!');
   readln;
   GOTO 99;
1: writeln('pause in TOEPLZ - Levinson method fails');
   writeln('matrix has a singular principal minor');
   readln;
99:
   dispose(h);
   dispose(g)
END;
