(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
   RealArrayNPbyNP = ARRAY [1..np,1..np] OF real;
   IntegerArrayNP = ARRAY [1..np] OF integer;
PROCEDURE usrfun(VAR x: RealArrayNP;
                     n: integer;
             VAR alpha: RealArrayNPbyNP;
              VAR beta: RealArrayNP);
ENDENVIRON *)
PROCEDURE mnewt(ntrial: integer;
                 VAR x: RealArrayNP;
                     n: integer;
             tolx,tolf: real);
LABEL 99;
VAR
   k,i: integer;
   errx,errf,d: real;
   beta: ^RealArrayNP;
   alpha: ^RealArrayNPbyNP;
   indx: ^IntegerArrayNP;
BEGIN
   new(beta);
   new(alpha);
   new(indx);
   FOR k := 1 TO ntrial DO BEGIN
      usrfun(x,n,alpha^,beta^);
      errf := 0.0;
      FOR i := 1 TO n DO
         errf := errf+abs(beta^[i]);
      IF errf <= tolf THEN GOTO 99;
      ludcmp(alpha^,n,indx^,d);
      lubksb(alpha^,n,indx^,beta^);
      errx := 0.0;
      FOR i := 1 TO n DO BEGIN
         errx := errx+abs(beta^[i]);
         x[i] := x[i]+beta^[i]
      END;
      IF errx <= tolx THEN GOTO 99
   END;
99:
   dispose(indx);
   dispose(alpha);
   dispose(beta)
END;
