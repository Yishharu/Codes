(* BEGINENVIRON
CONST
   n12 =
TYPE
   RealArrayN12 = ARRAY [1..n12] OF real;
   RealArrayNP = RealArrayN12;
ENDENVIRON *)
PROCEDURE ttest(VAR data1: RealArrayN12;
                       n1: integer;
                VAR data2: RealArrayN12;
                       n2: integer;
               VAR t,prob: real);
VAR
   i: integer;
   var1,var2,svar,df,ave1,ave2: real;
BEGIN
   avevar(data1,n1,ave1,var1);
   avevar(data2,n2,ave2,var2);
   df := n1+n2-2;
   svar := ((n1-1)*var1+(n2-1)*var2)/df;
   t := (ave1-ave2)/sqrt(svar*(1.0/n1+1.0/n2));
   prob := betai(0.5*df,0.5,df/(df+sqr(t)))
END;
