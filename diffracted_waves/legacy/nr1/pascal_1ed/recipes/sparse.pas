(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
PROCEDURE asub(VAR x,y: RealArrayNP;
                     n: integer);
PROCEDURE atsub(VAR x,y: RealArrayNP;
                      n: integer);
ENDENVIRON *)
PROCEDURE sparse(VAR b: RealArrayNP;
                     n: integer;
                 VAR x: RealArrayNP;
               VAR rsq: real);
LABEL 1,99;
CONST
   eps = 1.0e-6;
VAR
   j,iter,irst: integer;
   rp,gg,gam,eps2,dgg,bsq,anum,aden: real;
   g,h,xi,xj: ^RealArrayNP;
BEGIN
   new(g);
   new(h);
   new(xi);
   new(xj);
   eps2 := n*sqr(eps);
   irst := 0;
1: irst := irst+1;
   asub(x,xi^,n);
   rp := 0.0;
   bsq := 0.0;
   FOR j := 1 TO n DO BEGIN
      bsq := bsq+sqr(b[j]);
      xi^[j] := xi^[j]-b[j];
      rp := rp+sqr(xi^[j])
   END;
   atsub(xi^,g^,n);
   FOR j := 1 TO n DO BEGIN
      g^[j] := -g^[j];
      h^[j] := g^[j]
   END;
   FOR iter := 1 TO 10*n DO BEGIN
      asub(h^,xi^,n);
      anum := 0.0;
      aden := 0.0;
      FOR j := 1 TO n DO BEGIN
         anum := anum+g^[j]*h^[j];
         aden := aden+sqr(xi^[j])
      END;
      IF aden = 0.0 THEN BEGIN
         writeln('pause in routine SPARSE');
         writeln('very singular matrix');
         readln
      END;
      anum := anum/aden;
      FOR j := 1 TO n DO BEGIN
         xi^[j] := x[j];
         x[j] := x[j]+anum*h^[j]
      END;
      asub(x,xj^,n);
      rsq := 0.0;
      FOR j := 1 TO n DO BEGIN
         xj^[j] := xj^[j]-b[j];
         rsq := rsq+sqr(xj^[j])
      END;
      IF (rsq = rp) OR (rsq <= bsq*eps2) THEN
         GOTO 99;
      IF rsq > rp THEN BEGIN
         FOR j := 1 TO n DO x[j] := xi^[j];
         IF irst >= 3 THEN GOTO 99;
         GOTO 1
      END;
      rp := rsq;
      atsub(xj^,xi^,n);
      gg := 0.0;
      dgg := 0.0;
      FOR j := 1 TO n DO BEGIN
         gg := gg+sqr(g^[j]);
         dgg := dgg+(xi^[j]+g^[j])*xi^[j]
      END;
      IF gg = 0.0 THEN GOTO 99;
      gam := dgg/gg;
      FOR j := 1 TO n DO BEGIN
         g^[j] := -xi^[j];
         h^[j] := g^[j]+gam*h^[j]
      END
   END;
   writeln('pause in routine SPARSE');
   writeln('too many iterations');
   readln;
99:
   dispose(xj);
   dispose(xi);
   dispose(h);
   dispose(g)
END;
