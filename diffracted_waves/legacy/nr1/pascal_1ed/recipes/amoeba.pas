(* BEGINENVIRON
CONST
   np =
   mp =
TYPE
   RealArrayMPbyNP = ARRAY [1..mp,1..np] OF real;
   RealArrayMP = ARRAY [1..mp] OF real;
   RealArrayNP = ARRAY [1..np] OF real;
FUNCTION func(VAR pr: RealArrayNP): real;
ENDENVIRON *)
PROCEDURE amoeba(VAR p: RealArrayMPbyNP;
                 VAR y: RealArrayMP;
                  ndim: integer;
                  ftol: real;
             VAR nfunc: integer);
LABEL 99;
CONST
   nfuncmax = 5000;
   alpha = 1.0;
   beta = 0.5;
   gamma = 2.0;
VAR
   mpts,j,inhi,ilo,ihi,i: integer;
   ytry,ysave,sum,rtol: real;
   psum: ^RealArrayNP;

FUNCTION amotry(VAR p: RealArrayMPbyNP;
                VAR y: RealArrayMP;
              VAR sum: RealArrayNP;
             ndim,ihi: integer;
            VAR nfunc: integer;
                  fac: real): real;
VAR
   j: integer;
   fac1,fac2,ytry: real;
   ptry: ^RealArrayNP;
BEGIN
   new(ptry);
   fac1 := (1.0-fac)/ndim;
   fac2 := fac1-fac;
   FOR j := 1 TO ndim DO
      ptry^[j] := sum[j]*fac1-p[ihi,j]*fac2;
   ytry := func(ptry^);
   nfunc := nfunc+1;
   IF ytry < y[ihi] THEN BEGIN
      y[ihi] := ytry;
      FOR j := 1 TO ndim DO BEGIN
         sum[j] := sum[j]+ptry^[j]-p[ihi,j];
         p[ihi,j] := ptry^[j]
      END
   END;
   amotry := ytry;
   dispose(ptry)
END;

BEGIN
   new(psum);
   mpts := ndim+1;
   nfunc := 0;
   FOR j := 1 TO ndim DO BEGIN
      sum := 0.0;
      FOR i := 1 TO mpts DO
         sum := sum+p[i,j];
      psum^[j] := sum
   END;
   WHILE true DO BEGIN
      ilo := 1;
      IF y[1] > y[2] THEN BEGIN
         ihi := 1;
         inhi := 2
      END
      ELSE BEGIN
         ihi := 2;
         inhi := 1
      END;
      FOR i := 1 TO mpts DO BEGIN
         IF y[i] < y[ilo] THEN ilo := i;
         IF y[i] > y[ihi] THEN BEGIN
            inhi := ihi;
            ihi := i
         END
         ELSE IF y[i] > y[inhi] THEN
            IF i <> ihi THEN inhi := i
      END;
      rtol := 2.0*abs(y[ihi]-y[ilo])/(abs(y[ihi])+abs(y[ilo]));
      IF rtol < ftol THEN GOTO 99;
      IF nfunc >= nfuncmax THEN BEGIN
         writeln('pause in AMOEBA - too many iterations');
         readln
      END;
      ytry := amotry(p,y,psum^,ndim,ihi,nfunc,-alpha);
      IF ytry <= y[ilo] THEN
         ytry := amotry(p,y,psum^,ndim,ihi,nfunc,gamma)
      ELSE IF ytry >= y[inhi] THEN BEGIN
         ysave := y[ihi];
         ytry := amotry(p,y,psum^,ndim,ihi,nfunc,beta);
         IF ytry >= ysave THEN BEGIN
            FOR i := 1 TO mpts DO
               IF i <> ilo THEN BEGIN
                  FOR j := 1 TO ndim DO BEGIN
                     psum^[j] := 0.5*(p[i,j]+p[ilo,j]);
                     p[i,j] := psum^[j]
                  END;
                  y[i] := func(psum^)
               END;
            nfunc := nfunc+ndim;
            FOR j := 1 TO ndim DO BEGIN
               sum := 0.0;
               FOR i := 1 TO mpts DO
                  sum := sum+p[i,j];
               psum^[j] := sum
            END
         END
      END
   END;
99:
   dispose(psum)
END;
