(* BEGINENVIRON
CONST
   ndatap =
   map =
TYPE
   RealArrayNDATA = ARRAY [1..ndatap] OF real;
   RealArrayMA = ARRAY [1..map] OF real;
   IntegerArrayMFIT = ARRAY [1..map] OF integer;
   RealArrayMAbyMA = ARRAY [1..map,1..map] OF real;
   RealArrayMAby1 = ARRAY [1..map,1..1] OF real;
   RealArrayNPbyNP = RealArrayMAbyMA;
   RealArrayNPbyMP = RealArrayMAby1;
   IntegerArrayNP = IntegerArrayMFIT;
VAR
   MrqminOchisq: real;
   MrqminBeta: RealArrayMA;
PROCEDURE funcs(xx: real;
             VAR a: RealArrayMA;
              yfit: real;
          VAR dyda: RealArrayMA;
                ma: integer);
ENDENVIRON *)
PROCEDURE mrqmin(VAR x,y,sig: RealArrayNDATA;
                       ndata: integer;
                       VAR a: RealArrayMA;
                          ma: integer;
                   VAR lista: IntegerArrayMFIT;
                        mfit: integer;
             VAR covar,alpha: RealArrayMAbyMA;
            VAR chisq,alamda: real);
LABEL 99;
VAR
   k,kk,j,ihit: integer;
   atry,da: ^RealArrayMA;
   oneda: ^RealArrayMAby1;

PROCEDURE mrqcof(VAR x,y,sig: RealArrayNDATA;
                       VAR a: RealArrayMA;
                   VAR lista: IntegerArrayMFIT;
                   VAR alpha: RealArrayMAbyMA;
                    VAR beta: RealArrayMA;
                   VAR chisq: real);
VAR
   k,j,i: integer;
   ymod,wt,sig2i,dy: real;
   dyda: ^RealArrayMA;
BEGIN
   new(dyda);
   FOR j := 1 TO mfit DO BEGIN
      FOR k := 1 TO j DO alpha[j,k] := 0.0;
      beta[j] := 0.0
   END;
   chisq := 0.0;
   FOR i := 1 TO ndata DO BEGIN
      funcs(x[i],a,ymod,dyda^,ma);
      sig2i := 1.0/(sig[i]*sig[i]);
      dy := y[i]-ymod;
      FOR j := 1 TO mfit DO BEGIN
         wt := dyda^[lista[j]]*sig2i;
         FOR k := 1 TO j DO
            alpha[j,k] := alpha[j,k]+wt*dyda^[lista[k]];
         beta[j] := beta[j]+dy*wt
      END;
      chisq := chisq+dy*dy*sig2i
   END;
   FOR j := 2 TO mfit DO
      FOR k := 1 TO j-1 DO alpha[k,j] := alpha[j,k];
   dispose(dyda)
END;

BEGIN
   new(da);
   new(oneda);
   new(atry);
   IF alamda < 0.0 THEN BEGIN
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
            writeln('pause 1 in routine MRQMIN');
            writeln('Improper permutation in LISTA');
            readln
         END
      END;
      IF kk <> ma+1 THEN BEGIN
         writeln('pause 2 in routine MRQMIN');
         writeln('Improper permutation in LISTA');
         readln
      END;
      alamda := 0.001;
      mrqcof(x,y,sig,a,lista,alpha,MrqminBeta,chisq);
      MrqminOchisq := chisq;
      FOR j := 1 TO ma DO atry^[j] := a[j]
   END;
   FOR j := 1 TO mfit DO BEGIN
      FOR k := 1 TO mfit DO covar[j,k] := alpha[j,k];
      covar[j,j] := alpha[j,j]*(1.0+alamda);
      oneda^[j,1] := MrqminBeta[j]
   END;
   gaussj(covar,mfit,oneda^,1);
   FOR j := 1 TO mfit DO
      da^[j] := oneda^[j,1];
   IF alamda = 0.0 THEN BEGIN
      covsrt(covar,ma,lista,mfit);
      GOTO 99
   END;
   FOR j := 1 TO mfit DO
      atry^[lista[j]] := a[lista[j]]+da^[j];
   mrqcof(x,y,sig,atry^,lista,covar,da^,chisq);
   IF chisq < MrqminOchisq THEN BEGIN
      alamda := 0.1*alamda;
      MrqminOchisq := chisq;
      FOR j := 1 TO mfit DO BEGIN
         FOR k := 1 TO mfit DO alpha[j,k] := covar[j,k];
         MrqminBeta[j] := da^[j];
         a[lista[j]] := atry^[lista[j]]
      END
   END
   ELSE BEGIN
      alamda := 10.0*alamda;
      chisq := MrqminOchisq
   END;
99:
   dispose(atry);
   dispose(oneda);
   dispose(da)
END;
