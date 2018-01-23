(* BEGINENVIRON
CONST
   n12 =
TYPE
   RealArrayN12 = ARRAY [1..n12] OF real;
   RealArrayNP = RealArrayN12;
ENDENVIRON *)
PROCEDURE tutest(VAR data1: RealArrayN12;
                        n1: integer;
                 VAR data2: RealArrayN12;
                        n2: integer;
                VAR t,prob: real);
VAR
   var1,var2,df,ave1,ave2: real;
   i: integer;
BEGIN
   avevar(data1,n1,ave1,var1);
   avevar(data2,n2,ave2,var2);
   t := (ave1-ave2)/sqrt(var1/n1+var2/n2);
   df := sqr(var1/n1+var2/n2)/(sqr(var1/n1)/(n1-1)+sqr(var2/n2)/(n2-1));
   prob := betai(0.5*df,0.5,df/(df+sqr(t)))
END;
