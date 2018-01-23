(* BEGINENVIRON
CONST
   ndatap =
   map =
TYPE
   RealArrayNDATA = ARRAY [1..ndatap] OF real;
   RealArrayMA = ARRAY [1..map] OF real;
   IntegerArrayMFIT = ARRAY [1..map] OF integer;
   RealArrayMAbyMA = ARRAY [1..map,1..map] OF real;
   RealArrayNPbyMP = ARRAY [1..map,1..1] OF real;
PROCEDURE funcs(x: real;
        VAR afunc: RealArrayMA;
               ma: integer);
ENDENVIRON *)
PROCEDURE lfit(VAR x,y,sig: RealArrayNDATA;
                     ndata: integer;
                     VAR a: RealArrayMA;
                        ma: integer;
                 VAR lista: IntegerArrayMFIT;
                      mfit: integer;
                 VAR covar: RealArrayMAbyMA;
                 VAR chisq: real);
VAR
   k,kk,j,ihit,i: integer;
   ym,wt,sum,sig2i: real;
   beta: ^RealArrayNPbyMP;
   afunc: ^RealArrayMA;
BEGIN
   new(beta);
   new(afunc);
   kk := mfit+1;
   FOR j := 1 TO ma DO BEGIN
      ihit := 0;
      FOR k := 1 TO mfit DO
         IF lista[k] = j THEN ihit := ihit+1;
      IF ihit = 0 THEN BEGIN
         lista[kk] := j;
         kk := kk+1
      END
      ELSE IF ihit > 1 THEN BEGIN
         writeln('pause in routine LFIT');
         writeln('improper permutation in LISTA');
         readln
      END
   END;
   IF kk <> ma+1 THEN BEGIN
      writeln('pause in routine LFIT');
      writeln('improper permutation in LISTA');
      readln
   END;
   FOR j := 1 TO mfit DO BEGIN
      FOR k := 1 TO mfit DO covar[j,k] := 0.0;
      beta^[j,1] := 0.0
   END;
   FOR i := 1 TO ndata DO BEGIN
      funcs(x[i],afunc^,ma);
      ym := y[i];
      IF mfit < ma THEN
         FOR j := mfit+1 TO ma DO
            ym := ym-a[lista[j]]*afunc^[lista[j]];
      sig2i := 1.0/sqr(sig[i]);
      FOR j := 1 TO mfit DO BEGIN
         wt := afunc^[lista[j]]*sig2i;
         FOR k := 1 TO j DO
            covar[j,k] := covar[j,k]+wt*afunc^[lista[k]];
         beta^[j,1] := beta^[j,1]+ym*wt
      END
   END;
   IF mfit > 1 THEN BEGIN
      FOR j := 2 TO mfit DO
         FOR k := 1 TO j-1 DO covar[k,j] := covar[j,k]
   END;
   gaussj(covar,mfit,beta^,1);
   FOR j := 1 TO mfit DO
      a[lista[j]] := beta^[j,1];
   chisq := 0.0;
   FOR i := 1 TO ndata DO BEGIN
      funcs(x[i],afunc^,ma);
      sum := 0.0;
      FOR j := 1 TO ma DO
         sum := sum+a[j]*afunc^[j];
      chisq := chisq+sqr((y[i]-sum)/sig[i])
   END;
   covsrt(covar,ma,lista,mfit);
   dispose(afunc);
   dispose(beta)
END;
