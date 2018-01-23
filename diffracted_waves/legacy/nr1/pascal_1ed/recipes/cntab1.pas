(* BEGINENVIRON
CONST
   nip =
   njp =
TYPE
   IntegerArrayNIbyNJ = ARRAY [1..nip,1..njp] OF integer;
   RealArrayNI = ARRAY [1..nip] OF real;
   RealArrayNJ = ARRAY [1..njp] OF real;
ENDENVIRON *)
PROCEDURE cntab1(VAR nn: IntegerArrayNIbyNJ;
                  ni,nj: integer;
      VAR chisq,df,prob: real;
         VAR cramrv,ccc: real);
CONST
   tiny = 1.0e-30;
VAR
   nnj,nni,j,i,min: integer;
   sum,expctd: real;
   sumi: ^RealArrayNI;
   sumj: ^RealArrayNJ;
BEGIN
   new(sumi);
   new(sumj);
   sum := 0;
   nni := ni;
   nnj := nj;
   FOR i := 1 TO ni DO BEGIN
      sumi^[i] := 0.0;
      FOR j := 1 TO nj DO BEGIN
         sumi^[i] := sumi^[i]+nn[i,j];
         sum := sum+nn[i,j];
      END;
      IF sumi^[i] = 0.0 THEN nni := nni-1;
   END;
   FOR j := 1 TO nj DO BEGIN
      sumj^[j] := 0.0;
      FOR i := 1 TO ni DO
         sumj^[j] := sumj^[j]+nn[i,j];
      IF sumj^[j] = 0.0 THEN nnj := nnj-1;
   END;
   df := nni*nnj-nni-nnj+1;
   chisq := 0.0;
   FOR i := 1 TO ni DO
      FOR j := 1 TO nj DO BEGIN
         expctd := sumj^[j]*sumi^[i]/sum;
         chisq := chisq+sqr(nn[i,j]-expctd)/(expctd+tiny)
      END;
   prob := gammq(0.5*df,0.5*chisq);
   IF nni-1 < nnj-1 THEN
      min := nni-1
   ELSE
      min := nnj-1;
   cramrv := sqrt(chisq/(sum*min));
   ccc := sqrt(chisq/(chisq+sum));
   dispose(sumj);
   dispose(sumi)
END;
