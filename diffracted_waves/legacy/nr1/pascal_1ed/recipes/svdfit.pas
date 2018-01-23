(* BEGINENVIRON
CONST
   mp =
   np =
   ndatap =
   map =
TYPE
   RealArrayNDATA = ARRAY [1..ndatap] OF real;
   RealArrayMA = ARRAY [1..map] OF real;
   RealArrayMPbyNP = ARRAY [1..mp,1..np] OF real;
   RealArrayNPbyNP = ARRAY [1..np,1..np] OF real;
   RealArrayNP = ARRAY [1..np] OF real;
   RealArrayNP = RealArrayMA;
   RealArrayMP = RealArrayNDATA;
PROCEDURE func(x: real:
           VAR p: RealArrayMA;
              ma: integer);

ENDENVIRON *)
PROCEDURE svdfit(VAR x,y,sig: RealArrayNDATA;
                       ndata: integer;
                       VAR a: RealArrayMA;
                          ma: integer;
                       VAR u: RealArrayMPbyNP;
                       VAR v: RealArrayNPbyNP;
                       VAR w: RealArrayNP;
                   VAR chisq: real);
CONST
   tol = 1.0e-5;
VAR
   j,i: integer;
   wmax,tmp,thresh,sum: real;
   b: ^RealArrayNDATA;
   afunc: ^RealArrayMA;
BEGIN
   new(b);
   new(afunc);
   FOR i := 1 TO ndata DO BEGIN
      func(x[i],afunc^,ma);
      tmp := 1.0/sig[i];
      FOR j := 1 TO ma DO
         u[i,j] := afunc^[j]*tmp;
      b^[i] := y[i]*tmp
   END;
   svdcmp(u,ndata,ma,w,v);
   wmax := 0.0;
   FOR j := 1 TO ma DO
      IF w[j] > wmax THEN wmax := w[j];
   thresh := tol*wmax;
   FOR j := 1 TO ma DO
      IF w[j] < thresh THEN w[j] := 0.0;
   svbksb(u,w,v,ndata,ma,b^,a);
   chisq := 0.0;
   FOR i := 1 TO ndata DO BEGIN
      func(x[i],afunc^,ma);
      sum := 0.0;
      FOR j := 1 TO ma DO
         sum := sum+a[j]*afunc^[j];
      chisq := chisq+sqr((y[i]-sum)/sig[i])
   END;
   dispose(afunc);
   dispose(b)
END;
